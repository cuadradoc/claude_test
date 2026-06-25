suppressMessages(library(lme4))
d <- read.csv("repl_eda_lag1.csv"); d <- d[d$CasosFonasa>0,]
d$Periodo_scaled <- as.numeric(scale(d$Periodo))
d$Rural_sc <- as.numeric(scale(d$PorcPoblacionRural))
d$Pobreza_sc <- as.numeric(scale(d$PorcPoblacionPobreza))
d$Endoscopias_sc <- as.numeric(scale(d$Endoscopias))

cat("\n== 1. MODELO PRINCIPAL (replica notebook): Poisson, offset log(Casos), lag1 ==\n")
m1 <- glmer(DefuncionesHospLag1 ~ offset(log(CasosFonasa)) + Endoscopias_sc + Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m1)$coefficients,4))
rdf <- df.residual(m1); pe <- sum(residuals(m1,type="pearson")^2)
cat(sprintf("Overdispersion Pearson/df = %.2f (p=%.3g) | Var(Cluster)=%.4f\n", pe/rdf, pchisq(pe,rdf,lower.tail=FALSE), as.numeric(VarCorr(m1)$Cluster)))

cat("\n== 2. OFFSET ENDOGENO: log(Casos) como coef LIBRE (exogeno => ~1) ==\n")
m2 <- glmer(DefuncionesHospLag1 ~ log(CasosFonasa) + Endoscopias_sc + Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m2)$coefficients["log(CasosFonasa)",,drop=FALSE],4))

cat("\n== 4. REESPEC: denominador POBLACIONAL (no Casos-RIMH) ==\n")
m4 <- glmer(DefuncionesHospLag1 ~ offset(log(PoblacionFonasa)) + Endoscopias_sc + Periodo_scaled + Rural_sc + Pobreza_sc + (1|Cluster), family=poisson, data=d)
print(round(summary(m4)$coefficients["Endoscopias_sc",,drop=FALSE],4))

cat("\n== 5. EFECTOS FIJOS red+periodo (within) ==\n")
m5 <- glm(DefuncionesHospLag1 ~ offset(log(CasosFonasa)) + Endoscopias_sc + factor(Periodo) + Rural_sc + Pobreza_sc + factor(Cluster), family=poisson, data=d)
print(round(coef(summary(m5))["Endoscopias_sc",,drop=FALSE],4))
cat("\nDONE\n")
