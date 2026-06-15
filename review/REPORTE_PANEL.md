# Reporte del Panel Experto — Estrategia de Identificación Causal
## "Effectiveness of stomach cancer prevention in Chilean health services 2009–2024, an ecological study"
### (Lagos, Cuadrado, Riquelme)

Panel: Bioestadística · Inferencia causal · Epidemiología del cáncer/tamizaje.
Objetivo: criticar y proponer mejoras a la estrategia de identificación causal para explotar de la mejor forma posible los datos panel (45 redes locales × 5 períodos trienales × sexo × edad).

---

## 0. Veredicto consensuado

El estudio se apoya en una infraestructura de datos **excepcional** y aborda una pregunta de alto valor sanitario en un *hotspot* mundial de cáncer gástrico (CG). Su contribución **descriptiva** —el mapa de inequidad territorial (gradiente rural/sur de mayor incidencia y mortalidad, menor sobrevida) y de cuellos de botella de oferta— es **sólida, consistente con la literatura chilena (Corsi-Sotelo 2025; Latorre 2015) y defendible**.

Sin embargo, **las afirmaciones causales actuales NO están justificadas por el diseño** ("HP treatments reduced GC cases", "ultimately reducing mortality", "GC prevention strategies have been effective in reducing GC mortality"). El análisis es, en lo esencial, un **modelo de corte transversal con encogimiento entre redes (intercepto aleatorio)** que no explota la dimensión longitudinal para identificar, y descansa en un supuesto de ignorabilidad condicional que falla por **al menos cuatro vías independientes**, cada una capaz de generar los signos observados **sin que exista efecto real**:

1. **Offset/denominador endógeno**: los casos (offset de mortalidad y outcome de HP) se *estiman a partir de la mortalidad* vía RIMH → relación mecánica numerador↔denominador.
2. **Endogeneidad/causalidad inversa de la oferta**: los recursos se asignan según demanda/riesgo, no al azar (confirmado por el propio signo positivo consultas→casos).
3. **Sesgo de selección por colisión**: restringir muertes/sobrevida a hospitalizados FONASA abre un *backdoor* exposición→mortalidad.
4. **Lead-time / length-time bias**: la sobrevida a 3 años mejora con más detección *sin* reducir mortalidad.

El argumento de los autores —"que el efecto aparezca con *lag* sugiere causalidad"— **no constituye identificación**.

Los tres ejes coinciden en el mismo paquete de soluciones: **(i) romper la circularidad de los casos estimados, (ii) pasar a un diseño cuasi-experimental tipo efectos fijos / event-study sobre la expansión de cobertura, (iii) cambiar el endpoint a mortalidad poblacional, y (iv) montar un programa de controles negativos / análisis cuantitativo de sesgo (E-values).**

---

## 1. Fortalezas del enfoque actual

- **Datos y granularidad**: la desagregación en 45 redes locales por patrones de derivación (no en los ~29 Servicios administrativos) maximiza la variabilidad de demanda/utilización explotable — buena intuición para identificación.
- **Marco de cobertura efectiva** (disponibilidad→utilización→efectividad): estructura conceptualmente correcta y alineada con la literatura de sistemas de salud.
- **Estratificación sexo×edad**: controla confusión composicional por esas variables y permite efectos heterogéneos (hallazgo en hombres 40-60).
- **Linkage individual** de hospitalizaciones y muertes con pseudo-ID: permite construir sobrevida y abre la puerta a una validación semi-individual (hoy subutilizada).
- **Reconocimiento honesto** de varias limitaciones (sesgo de hospitalizados, error RIMH, exclusión ISAPRE) y uso de binomial con denominador (`cbind(Sobrevida, NoSobrevida)`) en sobrevida, que es lo correcto.
- **Reproducibilidad**: el pipeline (parquet → `load_coberturas_servicios` → `glmer`) es replicable; el panel reprodujo la Tabla 1 y los modelos.

---

## 2. Debilidades centrales (consolidadas por los tres expertos)

### 2.1. El offset/denominador es endógeno respecto al outcome  ⚠️ DEFECTO DE PRIMER ORDEN
`CasosFonasa` **no se observa**: se estima aplicando razones incidencia-mortalidad-hospitalización (**RIMH**) a la población. Es decir, **los casos son una función creciente de la mortalidad observada**. Pero:
- En los modelos de mortalidad EDA, `Deaths` es el numerador y `log(Cases)` el offset → numerador y denominador **comparten la señal de mortalidad**. El modelo regresa, en parte, muerte contra una transformación de muerte. El coeficiente de un offset está fijado en 1; si `Cases ∝ Deaths`, la "tasa de letalidad" se estabiliza mecánicamente y cualquier covariable que prediga el factor RIMH aparece asociada de forma espuria.
- En sobrevida es peor: el regresor `UtilizedCoverage = Utilized/Cases` lleva `Cases` (∝ mortalidad) en el denominador, **y** `Cases` reaparece ligado al outcome → correlación espuria por denominador común (problema clásico de razones con denominador compartido). El cambio de signo de la sobrevida (− mismo período, + a 2 lags) es **compatible con un artefacto algebraico**, no necesariamente con un mecanismo clínico.
- El error RIMH (≈11% provincial) **no es ruido clásico**: está correlacionado con la mortalidad y con la dotación local (la exposición) → **sesga, no solo atenúa**, y es mayor en redes pequeñas (Nueva Imperial 337 casos en 14 años, Petorca 240).

> **Evidencia empírica del panel** (sección 4): la correlación entre las muertes y los casos estimados (el offset) es de **r ≈ 0.94**.

### 2.2. Endogeneidad de la oferta / confusión por indicación / causalidad inversa
La asignación de endoscopías, consultas y tratamientos **no es aleatoria ni "as good as random"** condicional a ruralidad/pobreza/período: responde a demanda, listas de espera, presión epidemiológica y capacidad de gestión. Tres mecanismos confunden: causalidad inversa (más casos→más recursos), *targeting* al riesgo, y confusión por capacidad/calidad general del sistema (redes mejor gestionadas tienen más producción **y** mejores desenlaces por razones ajenas a la EDA). **La evidencia interna lo confirma**: la asociación **positiva** consultas→casos (Annex 6) es la firma de endogeneidad de la oferta, no de un efecto protector; los autores la leen benignamente.

### 2.3. El intercepto aleatorio NO es control de confusión causal
`(1|Cluster)` asume que el efecto de red es **ortogonal a las covariables** (exogeneidad del efecto aleatorio) y capturable por un desplazamiento gaussiano de nivel. En redes de salud esto casi nunca se cumple: las redes con más recursos difieren en confusores no medidos correlacionados con `u_i`. Síntoma sospechoso: las varianzas de cluster estimadas son **diminutas** (≈0.01–0.05 en escala log) pese a la enorme heterogeneidad territorial de Chile → la heterogeneidad real probablemente se está filtrando al efecto fijo (sesgo). Un test de Hausman casi con certeza rechazaría RE.

### 2.4. "El lag sugiere causalidad" es una inferencia inválida
Regresar `Deaths(t+1)` o `Deaths(t+2)` sobre `Exposición(t)` **reusa la misma exposición** y solo desplaza el outcome. Si exposición y mortalidad comparten una **tendencia secular** común (ambas mejoran por razones ajenas), aparece asociación a cualquier lag sin causalidad. Con incidencia/mortalidad de CG en **fuerte descenso secular**, la reversión a la media y las tendencias diferenciales por red (no absorbidas por `Periodo` lineal) producen exactamente el patrón rezagado. La precedencia temporal es **necesaria pero no suficiente**.

### 2.5. Sesgo de selección por usar solo hospitalizados FONASA (colisión)
La hospitalización es **hija** tanto de la severidad/incidencia como del **acceso** (que depende de la disponibilidad EDA). Condicionar en "hospitalizado" abre un camino espurio exposición→mortalidad. Dirección probable: donde hay más oferta se captura una **mayor fracción de casos** (incluyendo leves/precoces), inflando la sobrevida y diluyendo la letalidad **sin efecto sobre la historia natural**. El argumento de los autores ("la significancia de la ruralidad mitiga el sesgo") es un *non sequitur*: ajustar por una covariable asociada **no cierra** un *collider*, e incluso puede amplificarlo; y la ruralidad es un control ecológico grueso del propio mecanismo de selección.

### 2.6. Lead-time, length-time, overdiagnosis e immortal time  ⚠️ endpoint de sobrevida inválido
- **Lead-time**: adelantar el diagnóstico mueve hacia atrás el inicio del "reloj" de sobrevida **sin posponer la muerte** → la sobrevida a 3 años sube de forma artefactual. "Más utilización → mejor sobrevida a 2 lags" es **exactamente** lo que predice el lead-time.
- **Length-time / overdiagnosis**: más detección capta tumores indolentes/incipientes → más casos (coherente con consultas→**más casos**, leído por los autores como "constraint de recursos" pero que es la firma del sobrediagnóstico) y mejor sobrevida aparente.
- **Immortal time**: medir sobrevida "desde 1ª hospitalización" exige sobrevivir hasta hospitalizarse/confirmarse → favorece a los grupos con más utilización.
- La narrativa "sobrevida baja primero, alta después → efecto neto de menor mortalidad" **acomoda cualquier patrón** y no es falsable. Solo la **mortalidad poblacional** es robusta a estos sesgos.

### 2.7. Discrepancia conceptual: "Confirmacion_C16" no es tamizaje
El objetivo declarado es **tamizaje oportunista** (asintomáticos), pero la variable de utilización es *"UGE requests for GC confirmation of **symptomatic** patients"* — diagnóstico confirmatorio, **lo opuesto** al tamizaje. Las "endoscopías producidas" mezclan indicaciones diagnósticas/terapéuticas/seguimiento. La fracción que es tamizaje real varía por red → **misclasificación diferencial** correlacionada con exposición y riesgo. La ENS chilena muestra cobertura de tamizaje **muy baja**, lo que refuerza que la señal capturada es *actividad diagnóstica*, no tamizaje poblacional.

### 2.8. Latencia HP→CG: implausibilidad del efecto a 1 período
La carcinogénesis por *H. pylori* (cascada de Correa) toma **décadas**; el beneficio de la erradicación sobre incidencia aparece con latencias de **7–15+ años**. Detectar una reducción de incidencia con **lag de 1 período (3–6 años)** tras 2013 es **biológicamente implausible** como efecto causal → mucho más compatible con confusión (efecto cohorte de caída secular de prevalencia HP, *case-finding*).

### 2.9. Falacia ecológica y confusión sustantiva no medida
Inferir efectos individuales desde asociaciones de red puede **invertir el signo** (Simpson ecológico). Confusores no medidos de primer orden, todos con gradiente geográfico que imita los hallazgos:
- **Prevalencia de HP por cohorte/zona** (no la constante 0.79 — varía por edad/cohorte/saneamiento/ruralidad): mal mide `InfectedHP` de forma **diferencial** (en redes rurales/pobres la prevalencia real es mayor → se subestima el denominador justo donde la ruralidad ya es significativa).
- **Etnia (pueblos originarios/mapuche)**: el sur concentra alta incidencia/mortalidad de CG, alta ruralidad y menor dotación → el "efecto ruralidad" puede ser en gran parte **composición étnica/cohorte HP**.
- **Dieta (sal, nitratos), tabaquismo**, y **calidad de endoscopía/histología/registro** (más recursos → mejor detección y registro = sesgo de detección que imita efectividad).

### 2.10. Cuestiones estadísticas adicionales
- **Sobredispersión** no testeada: residuos escalados de ±8 en anexos delatan que los SE Poisson/binomiales están **subestimados**; varios hallazgos en p≈0.02–0.04 probablemente no sobreviven a binomial negativa / beta-binomial.
- **Inferencia múltiple**: ≥18 regresiones + versiones estratificadas; cosecha selectiva de "significativos"; **no se reportan IC ni tamaños de efecto** (solo p-valores/estrellas).
- **45 clusters** están al límite para inferencia de varianza y SE sandwich → se requiere **wild cluster bootstrap**.
- **Extrapolación de la EDA 2010–2014** con modelos mixtos: error de medición en la exposición principal → atenuación (regression dilution) y SE sobre-confiados (no se propaga la varianza de imputación).
- **Modelos estratificados rank-deficient** ("dropping 1 column"): celdas sexo×edad vacías; interacción triple consume demasiados grados de libertad para 45×5.
- **Pseudo-replicación**: al desagregar por sexo×edad el `n` sube a miles, pero la información de cluster sigue siendo 45 → falsa sensación de poder.

---

## 3. Recomendaciones del panel (priorizadas)

### Prioridad 1 — Romper la circularidad del outcome/offset
- Para mortalidad, usar **denominador poblacional observado** (`offset(log(PoblacionFonasa 40+))`) en lugar de `Cases`-RIMH, y tratar la incidencia como covariable de fuente independiente.
- Para sobrevida, usar el **conteo observado de hospitalizados** como denominador y **no** construir el regresor de cobertura con el mismo `Cases`.
- **Validar los casos** contra registros poblacionales de cáncer reales (Valdivia, Biobío, Antofagasta, Los Ríos) donde existan; **propagar la incertidumbre RIMH** por Monte Carlo (no tratar `Cases` como fijo).
- Diagnóstico directo: estimar el **coeficiente de `log(Cases)` libre** (sin fijarlo en 1); si se aleja mucho de 1 o el SE colapsa, es evidencia de la dependencia mecánica.

### Prioridad 2 — Cambiar el endpoint primario a MORTALIDAD POBLACIONAL por CG
Usar **todas** las muertes por CG de la red (estadísticas vitales DEIS), sin condicionar en hospitalización, como tasa con denominador poblacional. Esto resuelve simultáneamente el sesgo de colisión (§2.5), el lead/length/immortal-time (§2.6) y parte de la endogeneidad del outcome restringido. **Degradar la sobrevida a 3 años a exploratoria**, con advertencia explícita de lead-time; si se mantiene, corregir lead-time (Duffy/Walter) y reportar sobrevida **estadio-específica**.

### Prioridad 3 — Diseño cuasi-experimental que explote el panel
- **Mínimo no negociable**: reemplazar el intercepto aleatorio por **efectos fijos de red + efectos fijos de período** (within estimator) con **SE cluster-robustos** y **wild cluster bootstrap** (45 clusters). Justificar con **Mundlak/Hausman**.
  ```r
  fixest::fepois(Deaths ~ Endoscopias + Pobreza + Rural | Cluster + Periodo,
                 offset = ~log(pop), cluster = ~Cluster)
  ```
- **Columna vertebral recomendada**: **event study / difference-in-differences** sobre la **expansión escalonada** de cobertura (HP desde 2013/GES; EDA en los últimos períodos), con **estimadores robustos a heterogeneidad** (Callaway–Sant'Anna, de Chaisemartin–D'Haultfœuille, Sun–Abraham). Los **coeficientes de los *leads* (pre-tratamiento) testean tendencias paralelas** y **reemplazan correctamente** el argumento del lag.
- Reportar **cotas FE-vs-LDV** (sesgo de Nickell ~1/T con T=5) en vez de un único punto.
- **IV aspiracional** (robustez): instrumentos de oferta tipo *Bartik* (capacidad instalada histórica × tendencia nacional), distancia al centro endoscópico, o shocks presupuestarios; reportar F de primera etapa (será débil con N=45).

### Prioridad 4 — Programa de falsación: controles negativos y análisis cuantitativo de sesgo
- **Outcome de control negativo**: mortalidad por una causa **no afectada** por UGE/HP (cáncer de páncreas, otra neoplasia no tamizada, causas externas) contra las mismas exposiciones. Si aparece "protección" → confusión por capacidad/registro, no efecto.
- **Exposición de control negativo**: prestación endoscópica/especialidad no relacionada como *placebo*.
- **Placebo temporal**: "efecto" de tratamientos HP **antes de 2013**; "efecto" de exposición **futura** (lead) sobre mortalidad presente.
- **E-values** para cada asociación principal: dado el tamaño de los efectos (RR≈0.96), un E-value bajo (~1.2–1.4) implicaría que un confusor modesto (HP-cohorte, etnia) los anula. **Mostrarlo.**
- **Función lag-respuesta de latencia HP**: un efecto real debería **crecer** con el lag (≥10 años), no aparecer al primer período y desaparecer.

### Prioridad 5 — Corregir la inferencia estadística
- **Sobredispersión**: testear (DHARMa) y reajustar con **binomial negativa** (conteos) y **beta-binomial** (sobrevida); reportar el parámetro de dispersión.
- **Reportar IRR/OR + IC95% (bootstrap cluster)** para **toda** la familia de exposiciones×lags, no solo los significativos; definir **hipótesis primarias a priori** y controlar **FDR**.
- **Imputación múltiple (reglas de Rubin)** para la EDA extrapolada 2010–2014 + **análisis de sensibilidad restringido a 2015–2024** (datos observados). Indicador `imputado` × exposición.
- Diagnosticar columnas rank-deficient; sustituir interacciones triples saturadas por **splines de edad**; reportar `isSingular()`, ICC y **n efectivo**.

### Prioridad 6 — Reformular el marco como mediación causal
"Disponibilidad → utilización → mortalidad" es literalmente **mediación**, hoy analizada como regresiones separadas (riesgo de sesgo por mediador). Plantear **descomposición causal formal** (efecto natural directo/indirecto, VanderWeele) declarando los supuestos; como el supuesto de no-confusión mediador–outcome no se sostiene, usar **mediación con instrumento** para el mediador o, con honestidad, **análisis de sensibilidad** (E-value de mediación) y limitarse al **efecto total de disponibilidad** (tipo ITT: "ofrecer capacidad").

---

## 4. Verificación empírica del panel (R 4.3.3, lme4/glmmTMB)

Se reconstruyó el dataset del notebook (`load_coberturas_servicios(mayor40=TRUE, outcomes_lag=1)`, períodos ≤2020, casos>0; n=180, 45 redes × 4 períodos) y se replicó el **modelo principal** (disponibilidad EDA → mortalidad, lag 1), sometiéndolo a los diagnósticos clave del panel.

| # | Especificación | β (Endoscopías, escalada) | p | Lectura |
|---|---|---|---|---|
| 1 | **Réplica del notebook**: Poisson, `offset(log(Casos))`, `(1\|Cluster)` | **−0.042** | **0.013** | ✅ Reproduce el hallazgo reportado ("Lag 1: SIGNIFICATIVO") |
| 3 | **Binomial negativa** (corrige sobredispersión) | −0.044 | 0.018 | Sobrevive a la sobredispersión |
| 4 | **Denominador poblacional** (no Casos-RIMH) | −0.061 | 0.012 | Sobrevive al cambio de denominador |
| 5 | **Efectos fijos de red + período** (within) | −0.057 | **0.093** | ⚠️ **Pierde significancia** |

**Diagnósticos adicionales:**
- **Sobredispersión real**: Pearson/df = **1.73** (p≈8×10⁻⁹) → el Poisson **subestima** los errores estándar (confirma §2.10). El efecto, no obstante, sobrevive a la binomial negativa.
- **Vínculo mecánico casos↔muertes**: correlación **r = 0.94** entre muertes hospitalarias y casos estimados (el offset). Con `log(Casos)` como coeficiente **libre** (no fijado en 1) se estima **0.81** (z=16) — el "denominador" es, de hecho, un predictor casi proporcional al outcome (confirma §2.1).
- **Varianza de cluster diminuta** (0.014 en escala log), coherente con el síntoma señalado en §2.3.

**Interpretación honesta del panel:** el hallazgo principal **no es un mero artefacto** —es robusto a la sobredispersión y, notablemente, al cambio de denominador (lo que **atenúa** la severidad práctica de la circularidad del offset para *este* coeficiente)—, **pero es frágil ante la identificación**: al introducir **efectos fijos de red y de período** (que absorben toda confusión invariante en el tiempo, el núcleo de la objeción causal), la asociación cae a p≈0.09. Esto es exactamente lo que predijo el panel: el resultado del intercepto aleatorio **depende de comparaciones *entre* redes** (vulnerables a confusión estructural), no de la variación *dentro* de cada red en el tiempo. Es la demostración empírica de por qué la Prioridad 3 (estimador within / event-study) es decisiva.

> *Nota de alcance*: se replicó y estresó el modelo EDA-disponibilidad lag 1 como caso testigo. Las mismas pruebas (FE, NB, controles negativos, leads) deben aplicarse sistemáticamente a **todas** las exposiciones×lags antes de cualquier afirmación causal.

