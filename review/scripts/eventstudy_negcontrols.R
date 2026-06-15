suppressMessages({library(fixest); library(did)})
p <- read.csv("panel_eventstudy.csv")
p$Cluster <- as.integer(factor(p$Cluster))
options(width=200)

cat("################################################################\n")
cat("#  PARTE A — EVENT STUDY\n")
cat("################################################################\n")

cat("\n===== A1. Callaway–Sant'Anna staggered DiD (outcome = tasa mortalidad CG /100k, denominador POBLACIONAL) =====\n")
cat("Tratamiento = red supera 1.5x su disponibilidad EDA per capita basal (2011). Controles: never-treated.\n\n")
cs <- att_gt(yname="mortrate", tname="pidx", idname="Cluster", gname="G",
             xformla=~PorcRural+PorcPobreza, data=p,
             control_group="nevertreated", est_method="reg", base_period="universal")
agg_dyn <- aggte(cs, type="dynamic", na.rm=TRUE)
print(summary(agg_dyn))
agg_simple <- aggte(cs, type="simple", na.rm=TRUE)
cat("\nATT global (simple):", round(agg_simple$overall.att,3), " SE:", round(agg_simple$overall.se,3), "\n")

# Event-study plot
png("event_study_CS.png", width=900, height=600, res=110)
print(ggdid(agg_dyn, title="Event study (Callaway–Sant'Anna): expansión EDA → mortalidad CG"))
dev.off()
cat("[guardado event_study_CS.png]\n")

cat("\n===== A2. Event study TWFE de tratamiento CONTINUO con leads/lags (offset poblacional) =====\n")
cat("Deaths_t ~ Endo(t+1)[LEAD/placebo] + Endo(t) + Endo(t-1)[LAG] | red + periodo ; SE cluster-red\n\n")
m_es <- fepois(DefuncionesHosp ~ Endo_z_lead1 + Endo_z + Endo_z_lag1 + PorcRural + PorcPobreza |
               Cluster + pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=p)
print(etable(m_es, digits=4))

cat("\n################################################################\n")
cat("#  PARTE B — CONTROLES NEGATIVOS\n")
cat("################################################################\n")

cat("\n===== B1. PLACEBO de exposición FUTURA (anti-causal): mortalidad_t ~ Endo(t+1) | FE =====\n")
cat("Si la exposición FUTURA 'predice' la mortalidad presente => confusión/tendencia (no efecto causal).\n\n")
m_lead <- fepois(DefuncionesHosp ~ Endo_z_lead1 + PorcRural + PorcPobreza | Cluster + pidx,
                 offset=~log(PoblacionFonasa), cluster=~Cluster, data=p)
print(etable(m_lead, digits=4))

cat("\n===== B2. EXPOSICIONES de control negativo (proxies de capacidad del sistema) sobre mortalidad CG =====\n")
cat("HP-treatment actúa sobre INCIDENCIA (años antes), no sobre letalidad contemporánea; consultas = capacidad general.\n")
cat("Si 'protegen' igual que la EDA => la señal refleja capacidad/calidad general, no el mecanismo de tamizaje.\n\n")
m_real  <- fepois(DefuncionesHosp ~ Endo_z    + PorcRural + PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=p)
m_hp    <- fepois(DefuncionesHosp ~ TratHP_z  + PorcRural + PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=p)
m_cons  <- fepois(DefuncionesHosp ~ Consult_z + PorcRural + PorcPobreza | Cluster+pidx, offset=~log(PoblacionFonasa), cluster=~Cluster, data=p)
print(etable(m_real, m_hp, m_cons, digits=4,
             headers=c("EDA(real)","HP-trat(NC)","Consultas(NC)")))

cat("\n===== B3. OUTCOME de control negativo: mortalidad CG en <40 años (el tamizaje 40+ no debería afectarla) =====\n")
cat("Total muertes <40 =", sum(p$DeathsU40,na.rm=TRUE), "(baja potencia; signo/nulidad es lo informativo)\n\n")
m_u40 <- fepois(DeathsU40 ~ Endo_z + PorcRural + PorcPobreza | Cluster + pidx,
                offset=~log(PopU40), cluster=~Cluster, data=p[p$PopU40>0,])
print(etable(m_u40, digits=4))

cat("\nDONE\n")
