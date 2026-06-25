suppressMessages({library(lme4); library(glmmTMB)})
d <- read.csv("repl_eda_lag1.csv")
d <- d[d$CasosFonasa>0,]
d$Periodo_scaled <- as.numeric(scale(d$Periodo))
d$Rural_sc <- as.numeric(scale(d$PorcPoblacionRural))
d$Pobreza_sc <- as.numeric(scale(d$PorcPoblacionPobreza))
d$Endoscopias_sc <- as.numeric(scale(d$Endoscopias))
d$PoblacionFonasa40 <- d$PoblacionFonasa   # mayor40 dataset already

cat("\n========== 1. MODELO PRINCIPAL (replica notebook): Poisson, offset log(Casos) ==========\n")
m1 <- glmer(DefuncionesHospLag1 ~ offset(log(CasosFonasa)) + Endoscopias_sc +
            Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m1)$coefficients,4))
rdf <- df.residual(m1); pe <- sum(residuals(m1,type="pearson")^2)
cat(sprintf("Overdispersion Pearson/df = %.3f (p=%.3g)\n", pe/rdf, pchisq(pe,rdf,lower.tail=FALSE)))
cat("Var(Cluster) =", round(as.numeric(VarCorr(m1)$Cluster),5), "\n")

cat("\n========== 2. TEST OFFSET ENDOGENO: log(Casos) como coeficiente LIBRE ==========\n")
cat("(Si Casos fuese denominador exogeno, el coeficiente deberia ser ~1)\n")
m2 <- glmer(DefuncionesHospLag1 ~ log(CasosFonasa) + Endoscopias_sc +
            Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m2)$coefficients,4))

cat("\n========== 3. BINOMIAL NEGATIVA (glmmTMB) mismo modelo ==========\n")
m3 <- glmmTMB(DefuncionesHospLag1 ~ Endoscopias_sc + Periodo_scaled + Rural_sc + Pobreza_sc +
              (1|Cluster), offset=log(CasosFonasa), family=nbinom2, data=d)
print(round(summary(m3)$coefficients$cond,4))

cat("\n========== 4. REESPECIFICACION: denominador POBLACIONAL (no Casos-RIMH) ==========\n")
m4 <- glmer(DefuncionesHospLag1 ~ offset(log(PoblacionFonasa40)) + Endoscopias_sc +
            Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m4)$coefficients,4))

cat("\n========== 5. EFECTOS FIJOS de red + periodo (within estimator) ==========\n")
m5 <- glm(DefuncionesHospLag1 ~ offset(log(CasosFonasa)) + Endoscopias_sc +
          factor(Periodo) + Rural_sc + Pobreza_sc + factor(Cluster), family=poisson, data=d)
cat("Coef Endoscopias_sc (FE):", round(coef(summary(m5))["Endoscopias_sc",],4), "\n")
cat("\nDONE\n")
