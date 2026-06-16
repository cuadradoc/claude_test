suppressMessages({library(fixest); library(did)})
has_dcdh <- requireNamespace("DIDmultiplegt", quietly=TRUE)
options(width=200)
eda <- read.csv("panel_eventstudy.csv"); eda$Cluster <- as.integer(factor(eda$Cluster))
hp  <- read.csv("panel_hp.csv");         hp$Cluster  <- as.integer(factor(hp$Cluster))

Gfun <- function(df, treated_logical){
  tn <- treated_logical & df$pidx>=2
  f <- tapply(ifelse(tn, df$pidx, NA), df$Cluster, function(x) suppressWarnings(min(x,na.rm=TRUE)))
  f[is.infinite(f)] <- 0
  as.integer(f[as.character(df$Cluster)])
}
Dfun <- function(G,pidx) as.integer(G>0 & pidx>=G)

cat("##################################################################\n")
cat("#  PARTE 1 — RAMA EDA: SENSIBILIDAD AL UMBRAL + ESTIMADORES ALTERNATIVOS\n")
cat("##################################################################\n")

cat("\n=== 1a. Sensibilidad del umbral de 'expansión' (CS-DiD, ATT simple, outcome=tasa mortalidad/100k) ===\n")
for(thr in c(1.25, 1.5, 2.0)){
  eda$G <- Gfun(eda, eda$EndoPerCap > thr*eda$EndoBase)
  ncoh <- sum(tapply(eda$G, eda$Cluster, max)>0); nctrl <- sum(tapply(eda$G, eda$Cluster, max)==0)
  cs <- tryCatch(att_gt(yname="mortrate", tname="pidx", idname="Cluster", gname="G",
            xformla=~PorcRural+PorcPobreza, data=eda, control_group="notyettreated",
            est_method="reg", base_period="universal"), error=function(e) NULL)
  if(!is.null(cs)){ s <- aggte(cs, type="simple", na.rm=TRUE)
    cat(sprintf("  umbral %.2fx | tratadas=%d controles=%d | ATT=%+.3f SE=%.3f IC95=[%+.2f,%+.2f]\n",
        thr, ncoh, nctrl, s$overall.att, s$overall.se, s$overall.att-1.96*s$overall.se, s$overall.att+1.96*s$overall.se)) }
}

cat("\n=== 1b. Estimador alternativo Sun & Abraham (fixest::sunab), EDA expansión 1.5x, outcome=tasa mort/100k ===\n")
eda$G <- Gfun(eda, eda$EndoPerCap > 1.5*eda$EndoBase)
eda$coh <- ifelse(eda$G==0, 10000, eda$G)
m_sa_eda <- feols(mortrate ~ sunab(coh, pidx) + PorcRural + PorcPobreza | Cluster + pidx, cluster=~Cluster, data=eda)
print(summary(m_sa_eda, agg="att"))
cat("Coeficientes por tiempo-evento (Sun-Abraham):\n"); print(round(coef(m_sa_eda)[grepl("pidx",names(coef(m_sa_eda)))],4))

if(has_dcdh){ cat("\n=== 1c. de Chaisemartin-D'Haultfoeuille estático (DIDmultiplegt::did_multiplegt), EDA ===\n")
  eda$D <- Dfun(eda$G, eda$pidx)
  dm <- tryCatch(DIDmultiplegt::did_multiplegt(df=eda, Y="mortrate", G="Cluster", T="pidx", D="D",
          placebo=2, dynamic=2, brep=50, cluster="Cluster"), error=function(e){cat("ERR:",conditionMessage(e),"\n");NULL})
  if(!is.null(dm)) print(dm)
}

cat("\n\n##################################################################\n")
cat("#  PARTE 2 — RAMA HP -> INCIDENCIA: BATERÍA COMPLETA\n")
cat("##################################################################\n")
cat("(Outcome = incidencia CG /100k, denom poblacional. Tratamiento = cobertura HP > mediana nacional post-2013)\n")

cat("\n=== 2a. CS-DiD escalonado (Callaway-Sant'Anna), control = not-yet-treated, outcome=incidencia ===\n")
cs_hp <- att_gt(yname="incidence", tname="pidx", idname="Cluster", gname="G",
                xformla=~PorcRural+PorcPobreza, data=hp, control_group="notyettreated",
                est_method="reg", base_period="universal")
ad <- aggte(cs_hp, type="dynamic", na.rm=TRUE); print(summary(ad))
as_ <- aggte(cs_hp, type="simple", na.rm=TRUE)
cat(sprintf("ATT simple = %+.3f SE=%.3f IC95=[%+.2f,%+.2f]\n", as_$overall.att, as_$overall.se, as_$overall.att-1.96*as_$overall.se, as_$overall.att+1.96*as_$overall.se))
png("event_study_HP_CS.png", width=900, height=600, res=110)
print(ggdid(ad, title="Event study (Callaway-Sant'Anna): expansion tratamiento HP -> incidencia CG"))
dev.off(); cat("[guardado event_study_HP_CS.png]\n")

cat("\n=== 2b. Estimador alternativo Sun & Abraham (HP) ===\n")
hp$coh <- ifelse(hp$G==0, 10000, hp$G)
m_sa_hp <- feols(incidence ~ sunab(coh, pidx) + PorcRural + PorcPobreza | Cluster + pidx, cluster=~Cluster, data=hp)
print(summary(m_sa_hp, agg="att"))
cat("Coeficientes por tiempo-evento (Sun-Abraham):\n"); print(round(coef(m_sa_hp)[grepl("pidx",names(coef(m_sa_hp)))],4))
if(has_dcdh){ cat("\n=== 2b-bis. de Chaisemartin estático (HP) ===\n")
  hp$D <- Dfun(hp$G, hp$pidx)
  dmh <- tryCatch(DIDmultiplegt::did_multiplegt(df=hp, Y="incidence", G="Cluster", T="pidx", D="D",
           placebo=2, dynamic=2, brep=50, cluster="Cluster"), error=function(e){cat("ERR:",conditionMessage(e),"\n");NULL})
  if(!is.null(dmh)) print(dmh) }

cat("\n=== 2c. TWFE continuo leads/lags: incidencia ~ HPcov(t+1)[lead]+HPcov(t)+HPcov(t-1)+HPcov(t-2) (Poisson, offset pob, FE) ===\n")
m_hp_es <- fepois(CasosFonasa ~ HPcov_z_lead1 + HPcov_z + HPcov_z_lag1 + HPcov_z_lag2 + PorcRural + PorcPobreza |
                  Cluster + pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
print(etable(m_hp_es, digits=4))

cat("\n=== 2d. CONTROLES NEGATIVOS (HP) ===\n")
cat("B1. Placebo exposicion FUTURA: incidencia_t ~ HPcov(t+1) | FE\n")
m_hp_lead <- fepois(CasosFonasa ~ HPcov_z_lead1 + PorcRural+PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
cat(sprintf("  HPcov(t+1): %+.4f (SE %.4f, p=%.3f)\n", coef(m_hp_lead)["HPcov_z_lead1"], se(m_hp_lead)["HPcov_z_lead1"], pvalue(m_hp_lead)["HPcov_z_lead1"]))
cat("B2. Exposiciones de control negativo (capacidad) sobre incidencia: Endoscopias, Consultas (contemporaneo)\n")
m_hp_real <- fepois(CasosFonasa ~ HPcov_z  + PorcRural+PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
m_hp_endo <- fepois(CasosFonasa ~ Endo_z   + PorcRural+PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
m_hp_cons <- fepois(CasosFonasa ~ Consult_z+ PorcRural+PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
print(etable(m_hp_real, m_hp_endo, m_hp_cons, digits=4, headers=c("HP(real)","Endo(NC)","Consultas(NC)")))
cat("B3. LATENCIA (lag-response): un efecto real de erradicacion HP debe CRECER con el lag\n")
for(v in c("HPcov_z","HPcov_z_lag1","HPcov_z_lag2")){
  mm <- fepois(as.formula(paste0("CasosFonasa ~ ",v," + PorcRural+PorcPobreza | Cluster+pidx")), offset=~log(PoblacionFonasa), cluster=~Cluster, data=hp)
  cat(sprintf("  %-13s: %+.4f (p=%.3f)\n", v, coef(mm)[v], pvalue(mm)[v]))
}
cat("\nDONE\n")
