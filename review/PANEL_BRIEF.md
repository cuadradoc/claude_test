# BRIEF PARA PANEL EXPERTO — Estrategia de identificación causal

## Manuscrito
"Effectiveness of stomach cancer prevention in Chilean health services 2009-2024, an ecological study" (Lagos, Cuadrado, Riquelme). Texto completo en `/home/user/claude_test/MANUSCRIPT.txt`.

## Pregunta de investigación
Estimar el efecto potencial de dos intervenciones de prevención de cáncer gástrico (CG) en Chile:
1. **Erradicación de H. pylori (HP)** — prevención primaria (reduce incidencia de CG).
2. **Tamizaje oportunista por endoscopía digestiva alta (UGE/EDA)** — prevención secundaria (diagnóstico precoz → reduce mortalidad).

## Diseño
- Estudio **ecológico, observacional, analítico**. Beneficiarios FONASA (~80% población).
- Unidad de análisis: **45 redes locales** (subdivisiones de Servicios de Salud según patrones de derivación) × **períodos de 3 años** (2010-2012 … 2022-2024) × sexo × grupo etario ([0,40),[40,50),[50,60),[60,70),[70,80),80+).
- Marco de **"cobertura efectiva"**: Disponibilidad → Utilización → Efectividad.

## Variables
| | HP (primaria) | EDA (secundaria) |
|---|---|---|
| Población objetivo | Infectados HP (PoblacionFonasa × 0.79 prev.) | Casos incidentes 40+ |
| Disponibilidad | Consultas gastroenterología producidas | Endoscopías producidas (pública REM + privada MLE/FONASA) |
| Utilización | Tratamientos HP | EDA para confirmación CG (Confirmacion_C16) |
| Outcome | Casos CG (incidencia) | Muertes hospitalarias y sobrevida 3 años de 1ª hospitalización |
| Covariables | % rural, % pobreza, período | idem |

## Especificaciones de modelos (lme4::glmer, variables escaladas, intercepto aleatorio por Cluster)
**EDA — Poisson para muertes (con offset = log casos):**
```
Deaths_it     = offset(log(Cases_it)) + βA·AvailableUGE_it + βP·Poverty + βR·Rural + βT·t + u_i + ε
Deaths_i,t+1  = offset(log(Cases_it)) + βA1·AvailableUGE_it + ...   (lag 1)
Deaths_i,t+2  = offset(log(Cases_it)) + βA2·AvailableUGE_it + ...   (lag 2)
(idem con UtilizedUGE en vez de AvailableUGE)
```
**EDA — Logística para sobrevida (proporción):**
```
Logit(SurvivalRate_it) = βUC·UtilizedCoverageUGE_it + βP·Poverty + βR·Rural + βT·t + u_i + ε
(+ lag 1 y lag 2);  UtilizedCoverageUGE = UtilizedUGE / Cases
```
**HP — Poisson para casos (offset = log infectados), solo períodos post-2013:**
```
Cases_it     = offset(log(InfectedHP_it)) + βU·TreatmentsHP_it + ... (+ lag 1, lag 2)
Cases_it     = offset(log(InfectedHP_it)) + βA·ConsultationsGE_it + ... (+ lag 1, lag 2)
```
**Estratificación sexo×edad:** se reemplaza `βT·t + βU·UtilizedCoverage` por interacciones triples `AgeRange×Sex×(intercepto, t, UtilizedCoverage)`.

## Construcción de variables CLAVE (del notebook "1 Load Cubo Coberturas")
- **CasosFonasa (incidencia, = offset y denominador de coberturas)**: NO son casos observados. Se **estiman** aplicando razones incidencia-mortalidad-hospitalización (**RIMHcl**, método "RIMH") a la población de cada red local. Es decir, los casos estimados son **función de la mortalidad** observada por estadísticas vitales y de las hospitalizaciones.
- **DefuncionesHosp (outcome de mortalidad)**: muertes por CG de personas que tuvieron ≥1 hospitalización previa como beneficiario FONASA (linkage individual con pseudo-ID). Solo ~65% de casos incidentes se hospitalizan.
- **Sobrevida3**: proporción de 1ª hospitalizaciones por CG que sobreviven ≥3 años.
- **AvailableUGE/Endoscopias**: producción pública (REM) + privada (MLE/bonos FONASA). Datos FONASA disponibles 2015-2024; **extrapolados a 2010-2014 con modelos mixtos**. Igual la EDA privada.
- **Prevalencia HP** asumida constante = 0.79 (Libuy et al.) para toda la población FONASA, todas las edades.

## Resultados principales reportados
- ↑ Disponibilidad EDA → ↓ mortalidad con lag 1 período.
- ↑ Utilización EDA → ↓ mortalidad lag 1 y 2; ↓ sobrevida mismo período; ↑ sobrevida lag 2. Más pronunciado en hombres 40-60.
- ↑ Tratamientos HP → ↓ casos incidentes lag 1 período.
- Disponibilidad de consultas → asociación POSITIVA con casos mismo período.
- Ruralidad → ↑ incidencia y mortalidad, ↓ sobrevida. Pobreza: comportamiento heterogéneo.

## Interpretación causal de los autores
"El hecho de que la reducción ocurra más tarde (lag) sugiere asociación causal." La caída de sobrevida mismo período + alza a 2 lags se interpreta como diagnóstico de casos avanzados primero y precoces después → efecto neto de reducción de mortalidad.

## Limitaciones reconocidas por los autores
- Solo muertes/sobrevida de hospitalizados (sesgo hacia mayor acceso). 65% de casos se hospitalizan.
- Casos estimados por RIMH (error ~11% a nivel provincial) en vez de casos reales.
- No incluye población ISAPRE (mayor ingreso, menor incidencia, mayor acceso EDA).

## TAREA DEL PANEL
Criticar y proponer mejoras a la **estrategia de identificación causal** para explotar de la mejor forma posible estos datos panel (45 redes × 5 períodos). Foco en: validez de la inferencia causal, confusión, sesgos de selección/medición, especificación de modelos, y diseños/estimadores alternativos que aprovechen mejor la estructura panel.
