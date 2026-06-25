suppressMessages({
  ok <- require(lme4, quietly=TRUE)
})
if(!ok){ install.packages("lme4", repos="https://cloud.r-project.org", quiet=TRUE); library(lme4) }
d <- read.csv("repl_eda_lag1.csv")
d$Periodo_scaled <- scale(d$Periodo)
d$PorcPoblacionRural_scaled <- scale(d$PorcPoblacionRural)
d$PorcPoblacionPobreza_scaled <- scale(d$PorcPoblacionPobreza)
d$Endoscopias_scaled <- scale(d$Endoscopias)
m <- glmer(DefuncionesHospLag1 ~ offset(log(CasosFonasa)) + Endoscopias_scaled +
           Periodo_scaled + PorcPoblacionRural_scaled + PorcPoblacionPobreza_scaled + (1|Cluster),
           family=poisson, data=d)
cat("==== HEADLINE MODEL: EDA availability -> mortality, lag 1 ====\n")
print(summary(m)$coefficients)
cat("\nRandom effect var (Cluster):", as.numeric(VarCorr(m)$Cluster), "\n")
# Overdispersion check
rdf <- df.residual(m)
pearson <- sum(residuals(m, type="pearson")^2)
cat(sprintf("\nOverdispersion: Pearson chisq/df = %.3f (df=%d, p=%.3g)\n",
            pearson/rdf, rdf, pchisq(pearson, rdf, lower.tail=FALSE)))
