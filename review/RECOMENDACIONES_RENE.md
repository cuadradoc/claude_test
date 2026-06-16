# Recomendaciones metodológicas — Manuscrito de cobertura efectiva de prevención de cáncer gástrico

**Para:** René Lagos
**De:** Panel de revisión metodológica (bioestadística · inferencia causal · epidemiología)
**Objeto:** *"Effectiveness of stomach cancer prevention in Chilean health services 2009–2024, an ecological study"*
**Fecha:** junio 2026

---

## Cómo leer este documento

Las observaciones están **jerarquizadas por relevancia**:

- **🔴 OBSERVACIONES MAYORES (M1–M5):** comprometen directamente la validez de la afirmación causal de "efectividad". Mientras no se aborden, las conclusiones deben formularse como **asociaciones ecológicas exploratorias**, no como efectos. Son condición necesaria para sostener cualquier lenguaje causal.
- **🟡 OBSERVACIONES MENORES (m1–m6):** afectan la robustez, la precisión, la transparencia o la interpretación, pero no invalidan por sí solas el trabajo. Mejoran sustancialmente la calidad y blindan el manuscrito frente a revisores.

Cada punto incluye: *qué observamos · por qué importa · orientación metodológica · referencias*. Todas las referencias fueron verificadas individualmente (autoría, revista, año, páginas y DOI). Las biomédicas provienen de PubMed (DOI enlazados al final).

> **Mensaje central:** el estudio tiene una **fortaleza descriptiva sólida y publicable** —el mapa de inequidad territorial (gradiente rural/sur de mayor incidencia y mortalidad, menor sobrevida) es consistente con la literatura chilena—. La debilidad está en el **salto de la asociación al efecto causal**. Nuestra recomendación estratégica es **reposicionar el aporte principal como descriptivo/de equidad** y tratar la parte de efectividad como **hipótesis a evaluar con un diseño cuasi-experimental** (que ya esbozamos y testeamos empíricamente: ver §Evidencia).

---

## 🔴 OBSERVACIONES MAYORES

### M1. El outcome y el denominador (offset) se construyen ambos a partir de la mortalidad → circularidad
**Qué observamos.** Los `CasosFonasa` (incidencia) no son casos observados: se estiman aplicando razones incidencia-mortalidad-hospitalización (RIMH) que **incorporan la mortalidad observada**. Esos casos estimados son simultáneamente (a) el **offset** `log(Casos)` de los modelos de mortalidad y (b) el **outcome** de los modelos de HP, y (c) el denominador de las "coberturas". Numerador (muertes) y denominador (casos ∝ muertes) comparten la misma señal.

**Por qué importa.** Un offset construido desde la mortalidad induce una relación **mecánica/algebraica** entre el predictor y el outcome, no causal. En nuestra replicación, la correlación entre muertes hospitalarias y casos estimados es **r ≈ 0,94**; con `log(Casos)` como coeficiente libre se estima ≈0,81 (muy lejos de un denominador exógeno). Las "coberturas efectivas" (razones con denominador común) son especialmente vulnerables a correlación espuria.

**Orientación.**
1. Para mortalidad, usar **denominador poblacional observado** (`offset(log(PoblaciónFonasa 40+))`) en vez de casos-RIMH; tratar la incidencia como covariable medida de fuente independiente.
2. Para sobrevida, usar el **conteo observado de hospitalizados** como denominador, no casos-RIMH.
3. **Validar** los casos contra **registros poblacionales de cáncer reales** (p. ej., registros regionales con cobertura poblacional) en las redes donde existan, y **propagar la incertidumbre del RIMH** por Monte Carlo (no tratar `Casos` como dato fijo). El error del 11% provincial es **diferencial** (correlacionado con la dotación local), por lo que sesga, no solo atenúa.

---

### M2. La estrategia de identificación (intercepto aleatorio) no controla la confusión estructural; el efecto no sobrevive a un estimador *within*
**Qué observamos.** El modelo central es un GLMM con intercepto aleatorio por red `(1|Cluster)` y tres covariables. Esto es, en la práctica, un **corte transversal con encogimiento entre redes**: asume que el efecto de red es ortogonal a las covariables (exogeneidad del efecto aleatorio), supuesto que casi nunca se cumple en redes de salud (las redes con más recursos difieren en riesgo basal, capacidad y calidad de forma no medida). Además, la asignación de endoscopías/consultas **no es aleatoria**: responde a demanda y a presión epidemiológica (causalidad inversa). La propia asociación **positiva consultas→casos** del manuscrito es la firma de esta endogeneidad de la oferta.

**Por qué importa.** El coeficiente del intercepto aleatorio identifica una **pendiente parcial de regresión**, no un efecto causal. Cuando lo testeamos con **efectos fijos de red + período** (que absorben toda confusión invariante en el tiempo), la asociación EDA→mortalidad cae de p=0,013 a **p=0,09**, y bajo estimadores robustos a heterogeneidad (Callaway–Sant'Anna y Sun–Abraham) y un event-study escalonado, **no hay efecto detectable** (ver §Evidencia). El argumento "el efecto aparece con *lag*, luego es causal" **no es una estrategia de identificación**: con tendencias seculares comunes aparece asociación a cualquier *lag* sin causalidad.

**Orientación.**
1. **Mínimo no negociable:** sustituir el intercepto aleatorio por **efectos fijos de red + de período** (estimador *within*), con **errores estándar cluster-robustos** y, dado que hay solo 45 redes, **wild cluster bootstrap**. Justificar el cambio con un test de Mundlak/Hausman.
2. **Columna vertebral recomendada:** **event study / difference-in-differences escalonado** sobre la expansión de cobertura, con **estimadores robustos a heterogeneidad de timing** (Callaway–Sant'Anna; de Chaisemartin–D'Haultfœuille; Sun–Abraham). Los **coeficientes de los *leads* (pre-tratamiento)** son el test correcto de tendencias paralelas y **reemplazan** el argumento del *lag*.
3. Reportar **ambos** (FE y modelo dinámico) como cota, dado el sesgo de Nickell con T pequeño.

**Referencias.** Callaway & Sant'Anna 2021 [1]; Sun & Abraham 2021 [2]; de Chaisemartin & D'Haultfœuille 2020 [3]; síntesis práctica para implementar todo esto: Roth, Sant'Anna, Bilinski & Poe 2023 [4].

---

### M3. La sobrevida a 3 años es un endpoint inválido para tamizaje (lead-time, length-time, immortal time)
**Qué observamos.** La interpretación central usa la **sobrevida a 3 años** ("baja el mismo período, sube a 2 *lags*") como evidencia de efectividad del diagnóstico precoz.

**Por qué importa.** Adelantar el diagnóstico (más endoscopía) **mueve hacia atrás el inicio del reloj de sobrevida sin posponer la muerte** (lead-time): la sobrevida puede mejorar **aunque la mortalidad no cambie**. La detección preferente de tumores indolentes (length-time) y el sobrediagnóstico inflan además la sobrevida y la incidencia (coherente con consultas→más casos). Medir sobrevida "desde la 1ª hospitalización" introduce **immortal time bias** (hay que sobrevivir hasta hospitalizarse/confirmarse). La narrativa "baja primero, sube después" **acomoda cualquier patrón** y no es falsable. Solo la **mortalidad poblacional** es robusta a estos sesgos.

**Orientación.**
1. **Endpoint primario = mortalidad por CG poblacional** (todas las muertes por CG de la red, estadísticas vitales, denominador poblacional), **sin condicionar en hospitalización**.
2. Si se mantiene la sobrevida, **degradarla a exploratoria** con advertencia explícita de lead-time; idealmente corregir por lead-time (supuestos de tiempo de adelanto por estadio) y reportar **sobrevida estadio-específica** (no afectada por lead-time si el estadio es fijo).
3. Verificar **corrimiento de estadio** (stage shift) como evidencia mecanística más creíble que la sobrevida cruda.

**Referencias.** Jacklyn, Bell & Hayen 2017 (volunteer, lead-time, length-time, overdiagnosis) [10]; Suissa 2008 (immortal time bias) [9].

---

### M4. Sesgo de selección por usar solo muertes/sobrevida de hospitalizados (colisión)
**Qué observamos.** Los desenlaces de mortalidad y sobrevida provienen exclusivamente de pacientes **hospitalizados** como beneficiarios FONASA (~65% de los casos). El manuscrito argumenta que "la significancia de la ruralidad mitiga este sesgo".

**Por qué importa.** La hospitalización es **hija** tanto de la severidad como del **acceso** (que depende de la disponibilidad de EDA). Condicionar en "hospitalizado" **abre un camino espurio** (collider) entre exposición y mortalidad: donde hay más oferta se captura una mayor fracción de casos (incluidos los leves/precoces), lo que **infla la sobrevida y diluye la letalidad** sin efecto sobre la historia natural. El argumento de la ruralidad es un *non sequitur*: ajustar por una covariable asociada **no cierra** un collider (puede amplificarlo), y la ruralidad ecológica mide groseramente el propio mecanismo de selección.

**Orientación.**
1. Adoptar el **endpoint poblacional** de M3 (rompe la colisión al no condicionar en hospitalización).
2. **Análisis cuantitativo de sesgo de selección** (probabilistic bias analysis): parametrizar la probabilidad de hospitalización en función de la exposición y recalcular bajo escenarios de captura diferencial (p. ej., 55–75%); reportar **límites** (bracketing) imputando el desenlace del 35% no hospitalizado bajo supuestos extremos.

**Referencias.** Greenland & Robins 1994 (sesgos en estudios ecológicos) [8]; para el marco de control negativo que detecta este tipo de sesgo, Lipsitch, Tchetgen Tchetgen & Cohen 2010 [5].

---

### M5. La exposición medida no es "tamizaje", y la latencia HP→cáncer hace implausible el efecto a 1 período
**Qué observamos.** (a) El objetivo declarado es **tamizaje oportunista** (asintomáticos), pero la variable de utilización es *"UGE requests for GC confirmation of **symptomatic** patients"*: diagnóstico confirmatorio de sintomáticos, conceptualmente **opuesto** al tamizaje. Las "endoscopías producidas" mezclan indicaciones diagnósticas, terapéuticas y de seguimiento. (b) En la rama HP, se reporta reducción de incidencia con **lag de 1 período (3–6 años)**.

**Por qué importa.** (a) La fracción de EDA que es tamizaje real varía por red → **misclasificación diferencial** correlacionada con exposición y riesgo (sesgo de dirección impredecible); además, la cobertura poblacional de tamizaje en Chile es muy baja (ENS), lo que refuerza que se está midiendo **actividad diagnóstica**, no tamizaje. (b) La carcinogénesis gástrica por *H. pylori* (cascada de Correa) se desarrolla en **décadas**; el beneficio de la erradicación sobre incidencia aparece con latencias de **7–15+ años**. Un efecto al primer período es **biológicamente implausible** y mucho más compatible con confusión (efecto cohorte de caída secular de prevalencia de HP; *case-finding*). En nuestra replicación, la **lag-response de HP es nula y plana** (lag0/1/2 ≈ 0), lo contrario de lo que produciría un efecto real (que debería **crecer** con el *lag*).

**Orientación.**
1. **Reetiquetar el constructo**: medir *intensidad de actividad endoscópica/diagnóstica*, no *cobertura de tamizaje*. Ajustar título, objetivos e interpretación. Triangular las cifras de "utilización" con la cobertura poblacional de la ENS (Corsi-Sotelo 2025; Latorre 2015, ya en sus referencias).
2. **Desagregar por indicación** (tamizaje vs. confirmación vs. terapéutica) si REM/FONASA lo permiten.
3. Para HP, modelar **ventanas de inducción largas** y mostrar la **función *lag*-respuesta**; añadir **placebo temporal** (efecto "antes de 2013"). Estratificar por edad de erradicación (el beneficio plausible está en <50 años, pre-atrofia).

**Referencias.** Correa 1992 (cascada y latencia de la carcinogénesis gástrica) [12]; evidencia experimental del efecto (y su magnitud/latencia) de la erradicación de HP: Ford, Yuan, Forman, Hunt & Moayyedi 2020, revisión Cochrane (incidencia RR 0,54; mortalidad RR 0,61) [13].

---

## 🟡 OBSERVACIONES MENORES

### m1. Sobredispersión no testeada; faltan IC, tamaños de efecto y control de multiplicidad
La Poisson/binomial asume varianza = media; nuestros diagnósticos muestran **sobredispersión real (Pearson/df ≈ 1,73)** → los errores estándar están **subestimados** y varios hallazgos en p≈0,02–0,04 son frágiles. Se corren ≥18 regresiones y se reportan solo p-valores/estrellas.
**Orientación.** Testear sobredispersión (p. ej., con simulación de residuos) y reajustar con **binomial negativa** (conteos) y **beta-binomial** (proporciones de sobrevida); **reportar IRR/OR con IC95%** (bootstrap cluster) para toda la familia de exposiciones×lags, no solo las significativas; definir **hipótesis primarias a priori** y controlar la **tasa de falso descubrimiento (FDR)**. **Ref.** Bolker et al. 2009 [11].

### m2. Prevalencia de HP constante (0,79) para toda edad/zona/cohorte
La prevalencia de HP **varía fuertemente** por edad, cohorte de nacimiento, saneamiento y ruralidad. Asumirla constante hace que `InfectedHP` (denominador del modelo HP) esté **mal especificado de forma diferencial** (en redes rurales/pobres la prevalencia real es mayor → se subestima el denominador justo donde la ruralidad ya es significativa), lo que puede crear o invertir las asociaciones HP–incidencia y confundir el coeficiente de ruralidad.
**Orientación.** Análisis de sensibilidad con **prevalencia de HP estructurada por edad/cohorte/zona**; mostrar cuánto se mueven los coeficientes de HP y de ruralidad. *(Nota: en el manuscrito la referencia a la prevalencia aparece como "(REFERENCIA)" pendiente — completar con Libuy et al.)*

### m3. Exposición de EDA extrapolada 2010–2014 tratada como observada
La EDA (pública y privada) se **imputa** con modelos mixtos para 2010–2014. Tratarla como observada **ignora la varianza de imputación** (SE sobre-confiados) y puede atenuar (regression dilution) o sesgar los coeficientes.
**Orientación.** **Imputación múltiple** (reglas de Rubin) propagando la incertidumbre; **análisis de sensibilidad restringido a 2015–2024** (datos observados); incluir un indicador `imputado` × exposición.

### m4. Modelos estratificados sexo×edad con matriz de rango deficiente
Los modelos con interacciones triples reportan "dropping 1 column" (celdas sexo×edad vacías) y consumen demasiados grados de libertad para 45×5; el `n` grande al desagregar es **pseudo-replicación** (la información de cluster sigue siendo 45).
**Orientación.** Diagnosticar la celda vacía; reemplazar las interacciones triples saturadas por **splines de edad**; reportar `isSingular()`, ICC y **n efectivo**.

### m5. DAG por niveles, mediadores y collider; nodo de oferta omitido
El DAG mezcla variables individuales (dieta, tabaco, etnia) con variables de red (disponibilidad EDA) y **omite** un nodo de **capacidad/calidad del sistema** (confusor estructural de la exposición). Disponibilidad→utilización→efectividad es una **cadena de mediación**, no covariables intercambiables; y la hospitalización es un **nodo de selección/collider**.
**Orientación.** Redibujar **dos DAGs por nivel** (individual y de red) con el nodo de oferta explícito; marcar utilización/diagnóstico como **mediadores** y hospitalización como **selección**; analizar la cadena con **mediación causal formal** (efectos directo/indirecto) y, como el supuesto de no-confusión mediador–outcome no se sostiene, acompañar con **análisis de sensibilidad** (E-value de mediación) o limitarse al **efecto total de disponibilidad**. **Ref.** VanderWeele 2016 [7].

### m6. Confusores sustantivos no medidos; cuantificar su impacto
Etnia (pueblos originarios/mapuche, con gradiente sur de alta incidencia de CG), tabaquismo, dieta (sal, nitratos) y **calidad de registro/detección** (más recursos → mejor detección/codificación = sesgo que imita efectividad) no se controlan.
**Orientación.** Incorporar covariables ecológicas disponibles (% población indígena por comuna del Censo; tabaquismo/sal por región de la ENS); reportar **E-values** para cada asociación principal: dado el tamaño de los efectos (RR≈0,96), un E-value bajo (~1,2–1,4) implicaría que un confusor modesto los explica — **mostrarlo** es una prueba de honestidad muy valorada por revisores. Complementar con **controles negativos** de exposición y de resultado. **Ref.** VanderWeele & Ding 2017 (E-value) [6]; Lipsitch, Tchetgen Tchetgen & Cohen 2010 (controles negativos) [5].

---

## Hoja de ruta priorizada (qué hacer primero)

| Prioridad | Acción | Aborda |
|---|---|---|
| 1 | Cambiar el endpoint a **mortalidad poblacional** (denominador poblacional, sin condicionar en hospitalización) | M3, M4, parte de M1 |
| 2 | Romper la **circularidad RIMH** y validar casos con registro de cáncer real | M1 |
| 3 | Reemplazar intercepto aleatorio por **event-study / DiD escalonado** con *leads* como test de tendencias paralelas | M2 |
| 4 | **Reetiquetar la exposición** (actividad diagnóstica ≠ tamizaje) y modelar **latencia larga** en HP | M5 |
| 5 | **Controles negativos + E-values**; sobredispersión (NB/beta-binomial) + IC + FDR | M4/M6, m1 |
| 6 | Refinamientos: prevalencia HP estructurada, imputación múltiple de EDA, splines, DAG por niveles | m2–m5 |

---

## Evidencia empírica ya generada por el panel (para orientar la reescritura)

Replicamos el pipeline y aplicamos las recomendaciones 1–3 sobre el cubo de datos (denominador poblacional, R 4.3.3, `fixest`/`did`):

- **EDA → mortalidad:** el hallazgo "protector" lag-1 se **replica** con el modelo original (β=−0,042, p=0,013) pero **no sobrevive** a efectos fijos (p=0,09), y bajo **event-study escalonado** (Callaway–Sant'Anna) el ATT es **+0,68 [−2,62; +3,97]** — **sin efecto detectable**; confirmado por **Sun–Abraham** (ATT +0,30, p=0,82) y robusto a tres umbrales de "expansión".
- **HP → incidencia:** **nulo** en Callaway–Sant'Anna (ATT +0,65), Sun–Abraham (+0,85, p=0,33) y leads/lags continuos, con **signo positivo** y **lag-response plana** (contradice la latencia de Correa).
- **Controles negativos:** el placebo de exposición futura es nulo (✔) y el outcome placebo (mortalidad <40 años) es nulo (✔); las **únicas** asociaciones significativas son **capacidad→incidencia** (endoscopías/consultas), exactamente el mecanismo de **confusión por detección** que anticipamos.

*Caveat de poder:* 45 redes × 5 períodos con cohortes pequeñas → "ausencia de evidencia ≠ evidencia de ausencia". Por eso las recomendaciones 1–2 (mejor endpoint y casos reales) y más resolución temporal son decisivas para una conclusión definitiva.

Los scripts y resultados completos están en `review/` (carpeta del repositorio de revisión).

---

## Referencias (verificadas individualmente)

*Las referencias biomédicas provienen de búsquedas en **PubMed**; se incluyen los DOI como enlace. Se verificó autoría, revista, año y páginas de cada una.*

**Métodos de inferencia causal con datos panel / diferencias-en-diferencias**
1. Callaway B, Sant'Anna PHC. **Difference-in-Differences with multiple time periods.** *Journal of Econometrics.* 2021;225(2):200–230. DOI: [10.1016/j.jeconom.2020.12.001](https://doi.org/10.1016/j.jeconom.2020.12.001)
2. Sun L, Abraham S. **Estimating dynamic treatment effects in event studies with heterogeneous treatment effects.** *Journal of Econometrics.* 2021;225(2):175–199. DOI: [10.1016/j.jeconom.2020.09.006](https://doi.org/10.1016/j.jeconom.2020.09.006)
3. de Chaisemartin C, D'Haultfœuille X. **Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects.** *American Economic Review.* 2020;110(9):2964–2996. DOI: [10.1257/aer.20181169](https://doi.org/10.1257/aer.20181169)
4. Roth J, Sant'Anna PHC, Bilinski A, Poe J. **What's trending in difference-in-differences? A synthesis of the recent econometrics literature.** *Journal of Econometrics.* 2023;235(2):2218–2244. DOI: [10.1016/j.jeconom.2023.03.008](https://doi.org/10.1016/j.jeconom.2023.03.008)

**Sesgos, controles negativos y análisis de sensibilidad (epidemiología) — vía PubMed**
5. Lipsitch M, Tchetgen Tchetgen E, Cohen T. **Negative controls: a tool for detecting confounding and bias in observational studies.** *Epidemiology.* 2010;21(3):383–388. DOI: [10.1097/EDE.0b013e3181d61eeb](https://doi.org/10.1097/EDE.0b013e3181d61eeb)
6. VanderWeele TJ, Ding P. **Sensitivity Analysis in Observational Research: Introducing the E-Value.** *Annals of Internal Medicine.* 2017;167(4):268–274. DOI: [10.7326/M16-2607](https://doi.org/10.7326/M16-2607)
7. VanderWeele TJ. **Mediation Analysis: A Practitioner's Guide.** *Annual Review of Public Health.* 2016;37:17–32. DOI: [10.1146/annurev-publhealth-032315-021402](https://doi.org/10.1146/annurev-publhealth-032315-021402)
8. Greenland S, Robins J. **Invited commentary: ecologic studies—biases, misconceptions, and counterexamples.** *American Journal of Epidemiology.* 1994;139(8):747–760. DOI: [10.1093/oxfordjournals.aje.a117069](https://doi.org/10.1093/oxfordjournals.aje.a117069)
9. Suissa S. **Immortal time bias in pharmaco-epidemiology.** *American Journal of Epidemiology.* 2008;167(4):492–499. DOI: [10.1093/aje/kwm324](https://doi.org/10.1093/aje/kwm324)
10. Jacklyn G, Bell K, Hayen A. **Assessing the efficacy of cancer screening.** *Public Health Research & Practice.* 2017;27(3):2731727. DOI: [10.17061/phrp2731727](https://doi.org/10.17061/phrp2731727)

**Modelos de conteo / GLMM — vía PubMed**
11. Bolker BM, Brooks ME, Clark CJ, Geange SW, Poulsen JR, Stevens MHH, White JSS. **Generalized linear mixed models: a practical guide for ecology and evolution.** *Trends in Ecology & Evolution.* 2009;24(3):127–135. DOI: [10.1016/j.tree.2008.10.008](https://doi.org/10.1016/j.tree.2008.10.008)

**Cáncer gástrico y *H. pylori* (materia sustantiva) — vía PubMed**
12. Correa P. **Human gastric carcinogenesis: a multistep and multifactorial process—First American Cancer Society Award Lecture on Cancer Epidemiology and Prevention.** *Cancer Research.* 1992;52(24):6735–6740. PMID: [1458460](https://pubmed.ncbi.nlm.nih.gov/1458460/)
13. Ford AC, Yuan Y, Forman D, Hunt R, Moayyedi P. **Helicobacter pylori eradication for the prevention of gastric neoplasia.** *Cochrane Database of Systematic Reviews.* 2020;7:CD005583. DOI: [10.1002/14651858.CD005583.pub3](https://doi.org/10.1002/14651858.CD005583.pub3)

---

*Atribución: la información bibliográfica biomédica (refs. 5–13) fue obtenida y verificada en **PubMed**; las refs. 1–4 (econometría) fueron verificadas en las fuentes editoriales originales (Elsevier/AEA). Cada referencia fue comprobada en existencia, autoría, revista, año y páginas.*
