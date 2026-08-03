# Revisión adversarial #4 — Aplicación del marco de Cobertura Efectiva (Effective Coverage) y métricas de sistemas de salud

**Manuscrito:** *Persistent effective coverage gaps in gastric cancer prevention in Chile 2010-2024: a conceptual framework and ecological study using real world data* (Lagos, Cuadrado & Riquelme).
**Foco de esta revisión:** Tabla 1 (marco propuesto), Tabla 2 (variables), sección 2.4 (operacionalización), sección 4 (discusión). No se evalúa clínica, aritmética fina ni redacción salvo cuando afectan la coherencia conceptual del marco.

**Fuentes canónicas verificadas para esta revisión:**
- Shengelia, Tandon, Adams & Murray (2005), *Soc Sci Med* 61(1):97–109. https://doi.org/10.1016/j.socscimed.2004.11.055
- Tanahashi (1978), *Bull WHO* 56(2):295. PMC2395571.
- Amouzou et al. (2019), *BMJ Glob Health* 4(Suppl 4):e001297. https://doi.org/10.1136/bmjgh-2018-001297
- Marsh et al. (2020), *Lancet Glob Health* 8(5):e730–e736. https://doi.org/10.1016/S2214-109X(20)30104-2
- Lozano et al. / GBD 2019 (2020), *Lancet* 396(10258):1250–1284. https://doi.org/10.1016/S0140-6736(20)30750-9
- Ng et al. (2014), *PLoS Med* 11(9):e1001730. https://doi.org/10.1371/journal.pmed.1001730

---

## Fortalezas

1. **Ambición metodológica pertinente.** Aplicar el marco de EC a un cáncer (gástrico) omitido tanto por las estimaciones globales de GBD (que cubrieron mama, cérvix, útero y colorrectal) como por la literatura chilena de EC (restringida a mama y cérvix) es un vacío real y legítimo. La motivación está bien establecida.
2. **Resolución subnacional genuina.** Descomponer el país en 45 redes endoscópicas funcionales y estimar métricas por red-período-sexo-edad es un aporte de granularidad que la literatura de EC basada en encuestas nacionales (Aguilera 2014; Frenz 2014) no ofrece. La lógica de "invisibilidad en el agregado nacional" está bien argumentada y es coherente con el uso previsto de las cascadas a nivel subnacional que recomienda el propio grupo de Amouzou/Marsh.
3. **Uso explícito de la fórmula de Shengelia.** La ecuación individual EC = Q × (U∣N=1) (línea 25) es fiel a la definición de Shengelia et al. (2005): utilización condicional a necesidad, ponderada por calidad definida como ganancia en salud relativa (Q = HG/HGmax). La *forma* algebraica del estimador es correcta.
4. **Transparencia sobre limitaciones de datos.** El manuscrito reconoce abiertamente que no puede medir estadio al diagnóstico, que extrapola 2010–2014, y que la disponibilidad (availability) "no está incluida en las cascadas más recientes". Esta honestidad facilita la revisión (aunque, como se detalla abajo, reconocer una debilidad no la subsana).
5. **Rescalado por percentiles inspirado en GBD.** El uso de percentiles (1º/99º) en lugar de extremos absolutos para fijar HGmax/HGmin (línea 62) replica correctamente la lógica anti-outlier de Lozano et al. (2020), que ancló 0 y 100 en los percentiles 97,5 y 2,5.

---

## Defectos MAYORES

### M1 — El marco mezcla dos taxonomías incompatibles (Shengelia U×Q vs. cascada de Amouzou) y el nivel "quality-adjusted coverage" nunca se operacionaliza: se lo sustituye por un *outcome*

**Qué está mal.** La Tabla 1 anuncia una cascada de seis peldaños de cobertura (Available → Contact → Resource-adjusted → Crude/Utilized → **Quality-adjusted** → **Effective/Outcome-adjusted**), tomada explícitamente de "Tanahashi's and Amouzou's taxonomy" (línea 28). En la taxonomía de Amouzou et al. (2019), *quality-adjusted coverage* y *outcome-adjusted coverage* son **peldaños distintos y ordenados** de una misma cascada anidada: el primero es la proporción que recibe el servicio **según estándares de calidad de proceso** (guías, prontitud, insumos), y el segundo es la proporción que **experimenta un resultado de salud positivo**. Son conceptualmente separables por diseño.

Sin embargo, la sección 2.4 colapsa ambos en un solo término. Define una única Q = (HGmin − HMR)/(HGmin − HGmax) construida sobre un **outcome de mortalidad** (la razón hospitalización-mortalidad, HMR), y luego EC = Q · U/N (líneas 64–69). Es decir: **lo que el manuscrito rotula "quality" es, en la propia taxonomía que adopta, el peldaño *outcome-adjusted***. El peldaño "Quality-adjusted Coverage" que la Tabla 1 define como "diagnosed according to clinical guidelines and within the legally mandated timeframe" (adherencia de proceso) **nunca se mide** — no hay ninguna métrica de adherencia a guía, prontitud legal (garantía GES) ni estándar endoscópico en ningún resultado. El peldaño está vacío.

El resultado es una incoherencia irreducible: el manuscrito invoca **simultáneamente** (a) el modelo de dos términos de Shengelia (EC = utilización × calidad, con calidad = ganancia en salud, donde usar un *outcome* como Q es legítimo) y (b) la cascada de Amouzou (que exige separar calidad-de-proceso de resultado). Ambos no pueden ser verdaderos a la vez para la misma Q. Si Q es ganancia-en-salud (Shengelia), entonces la fila "Quality-adjusted" de la Tabla 1 no existe como peldaño separado y la cascada de seis rungs es ficción. Si Q es calidad-de-proceso (Amouzou), entonces medirla con HMR es incorrecto.

**Por qué importa.** El "conceptual framework" es la contribución declarada del paper (está en el título). Su coherencia interna es precisamente lo que HPP evaluaría. Un marco que promete seis peldaños y entrega tres (Available, Utilized, y un "Effective" que es en realidad el peldaño outcome disfrazado de quality) no es un marco: es una etiqueta. Además, el hallazgo central —"el gap está impulsado por la calidad (43,3% de reducción de HMR)" (línea 138)— se vuelve casi **tautológico**: con UC≈0,88 (cerca del techo), EC = 0,88 × Q ≈ 0,36 obliga a que el "gap" sea (1−Q) por construcción. Decir "el gap es de calidad" equivale a decir "la mortalidad-por-caso no está en su percentil óptimo", que es una reformulación del *outcome*, no un hallazgo independiente sobre la calidad del cuidado.

**Qué se exige.** (i) Elegir **una** taxonomía y declararla: o Shengelia (dos términos, Q = ganancia en salud, y entonces eliminar de la Tabla 1 la distinción quality/outcome) o Amouzou (y entonces medir *quality-adjusted* con indicadores de proceso —cumplimiento de garantía GES, tiempos, estándares endoscópicos— separadamente del *outcome-adjusted*). (ii) Reetiquetar la fila mal nombrada. (iii) Reformular el hallazgo "el gap es calidad" reconociendo su casi-circularidad dado UC≈0,88.

---

### M2 — Doble (triple) uso de la mortalidad: N, Q y U no son independientes; la EC de j=2 es, en esencia, un estadístico de mortalidad reempaquetado

**Qué está mal.** El denominador y el numerador de la EC comparten la misma señal de mortalidad, por tres vías:

- **N (población en necesidad).** La incidencia de CG se deriva de la mortalidad vía IMR: *Incidence = Mortality / IMR* (Annex 0, líneas 276–277). Por lo tanto **N ∝ Deaths**.
- **Q (calidad).** Q se construye sobre HMR = DeathsGC / HospitalizationsGC (líneas 59, 64). Es decir, **Q depende de Deaths en el numerador y de Hospitalizations en el denominador**.
- **U (utilización).** En la especificación principal U = TreatmentsGC; pero en la especificación alternativa (y en la que el propio manuscrito prefiere a nivel de red, línea 228) **U = HospitalizationsGC**, que es exactamente el denominador de HMR.

En la versión basada en hospitalizaciones (UC*, EC* de la Tabla 4): EC* = (Hosp/N)·Q, con N ∝ Deaths y Q ∝ (1 − Deaths/Hosp). La misma variable *Deaths* aparece en el denominador de la primera fracción (vía N) y en el numerador de la segunda (vía HMR); *Hosp* aparece simultáneamente en numerador (U), en N y en el denominador de HMR. **El numerador y el denominador de la EC están algebraicamente entrelazados.**

Contrástese con Lozano/GBD (2020), la fuente que el manuscrito cita como precedente metodológico: allí la **MIR (mortalidad-incidencia) rescalada ES la medida de cobertura efectiva**, usada **una sola vez** como *proxy* del outcome — no se la recicla para construir el denominador de necesidad y además como ponderador de calidad. El manuscrito toma prestado el rescalado por percentiles de GBD pero rompe su lógica: en GBD la mortalidad entra una vez; aquí entra en N (vía IMR), en Q (vía HMR) y en U (vía hospitalizaciones).

**Por qué importa.** Invalida la interpretación del hallazgo estrella (la "caída de 50 puntos" entre UC=88% y EC=36%, líneas 138, 214) como evidencia de una *brecha de calidad del cuidado*. Mecánicamente, la Q está acotada por la misma señal de mortalidad ya incrustada en el denominador N; el "gap" puede ser en parte un artefacto de la circularidad, no una propiedad del sistema. La EC de j=2 es, a primer orden, una función de (Deaths, Hospitalizations, y una incidencia derivada de Deaths): esencialmente un estadístico de mortalidad con traje de cascada.

**Qué se exige.** Demostrar formalmente la (in)dependencia entre N, U y Q. O bien: (i) probar algebraicamente que la señal de mortalidad no induce dependencia mecánica entre numerador y denominador de EC; o (ii) reconstruir N a partir de una fuente de incidencia **independiente de la mortalidad** (p. ej. registros poblacionales de cáncer directos, no IMR-derivados); o (iii) reconocer explícitamente que EC_j=2 no es separable de la mortalidad y reformular la contribución como "índice de desempeño mortalidad-ajustado", no como cobertura efectiva en sentido Shengelia/Amouzou.

---

### M3 — "Available Coverage" mal normalizada (AC de 117 a 429): no es una cobertura, rompe la naturaleza anidada/acotada de la cascada, y contradice el propio argumento de escasez

**Qué está mal.** La Tabla 4 reporta AC_j=2 = EndoscopiesAll / IncidentCasesGC con valores de **117,1 (Arica), 218,2 (Tarapacá), 316,5 (Antofagasta), 429,3 (Metropolitano Central)** (líneas 145–147, 163). Una "cobertura disponible" de 429 significa 42.900%. Esto **no es una proporción de cobertura**: es el cociente entre *todas* las endoscopías digestivas altas producidas (hechas mayoritariamente por dispepsia, tamizaje, vigilancia de metaplasia, control de úlcera, etc.) y los *casos incidentes de cáncer gástrico*. Numerador y denominador **no son poblaciones conmensurables**: la enorme mayoría de las UGE no son para casos incidentes de CG, y una endoscopía no es "una-por-caso-de-cáncer". Usar casos incidentes de cáncer como denominador de la disponibilidad de un examen que se aplica a toda la población dispéptica es un **error de categoría**.

Consecuencias en cascada:
1. **Rompe el axioma de anidamiento.** Tanto Tanahashi (1978) como Amouzou (2019) definen la cascada como una secuencia de proporciones **anidadas y monótonamente decrecientes**, todas en [0,1]: availability ≥ accessibility ≥ contact ≥ … ≥ effective. Aquí AC≈200 mientras UC≈0,005 y EC≈0,36: la "cascada" no decrece, no está anidada, y sus peldaños viven en escalas incomparables (AC en las centenas, UC en los milésimos). La Figura 1 (cascada por clúster) no puede ser, geométricamente, una cascada.
2. **Contradice la justificación misma de incluir availability.** El manuscrito añade el peldaño availability (que admite ausente en cascadas modernas, línea 52) argumentando que la capacidad es "una restricción presumiblemente relevante". Pero sus propios números muestran una oferta de endoscopías **~200 veces** los casos incidentes: a nivel agregado **no hay restricción de disponibilidad** para diagnosticar CG; la restricción es de *targeting*/priorización/lista de espera. El peldaño availability, tal como está normalizado, refuta la narrativa que lo motiva.

Adicionalmente, múltiples celdas de UC y EC en la Tabla 4 **exceden 1** (UC=1,32 Huasco; UC*=1,36 Metropolitano Central; UC=1,21 Valparaíso, línea 154; y decenas de UCT/UCH>1 en el Annex 4). Una "cobertura utilizada" >1 vuelve a violar el carácter de proporción acotada, producto de que U (hospitalizaciones/tratamientos) supera a N (incidencia estimada) por *bypassing*, casos prevalentes y error de estimación. Es decir, **ni siquiera el peldaño de utilización es una cobertura acotada.**

**Por qué importa.** Si tres de los peldaños centrales (Available, Utilized, y por herencia la cascada completa) no son proporciones interpretables ni anidadas, el objeto "cascada de cobertura efectiva" no existe como se lo presenta. Es el corazón del marco.

**Qué se exige.** (i) Renormalizar la disponibilidad contra un denominador conmensurable con el numerador (población elegible para endoscopía / con indicación, no casos incidentes de cáncer), o (ii) renombrar la métrica como "razón de capacidad" (capacity ratio) y **sacarla de la cascada**. (iii) Explicar por qué UC/EC>1 es admisible dentro de un marco de "cobertura", o acotar/reinterpretar. (iv) Demostrar el anidamiento monótono de los peldaños que sí se conserven.

---

### M4 — La EC del "diagnóstico" (prevención secundaria) se mide con HMR, que captura la letalidad de TODO el continuo (incluido el tratamiento), no la efectividad del diagnóstico; y la definición de la Tabla 1 (estadio I) diverge de la medida (HMR)

**Qué está mal.** La Tabla 1 define la *Effective Coverage* de j=2 como "Individuals with GC who are diagnosed at **stage I**" (línea 40) — un outcome de **oportunidad diagnóstica** (prevención secundaria). Pero como no hay registro de estadio, se sustituye por HMR (mortalidad-por-caso hospitalizado, líneas 58–60). El problema es que **la mortalidad-por-caso depende del continuo completo**: estadio al diagnóstico *más* calidad quirúrgica, oncológica, de cuidados, acceso a terapias, comorbilidad, etc. HMR **no aísla** el desempeño del *diagnóstico*; incorpora la efectividad del *tratamiento*. Sin embargo el manuscrito atribuye la totalidad del gap a la falla de la prevención secundaria/diagnóstico ("the system's inability to translate diagnostic efforts into health gains", abstract; §4.1). Se está midiendo la EC de **toda la ruta del cáncer** y rotulándola como EC del **diagnóstico**.

Esto es una fuga de estimando (*estimand leak*): el marco promete descomponer la prevención en j=1 (primaria) y j=2 (secundaria/diagnóstica), pero el indicador de outcome de j=2 (HMR) está contaminado por la fase terapéutica, que pertenece conceptualmente a un tercer eslabón (tratamiento) que el marco no modela. La cita a Heise et al. (2009) —una cohorte clínica única— no valida que la HMR poblacional derivada de linkage administrativo rastree la supervivencia *estadio-específica*; ese puente queda **afirmado, no demostrado**.

**Por qué importa.** Toda la sección de política (§4.3: "transición a triage estratificado por riesgo", "case management en fase de confirmación") se apoya en la premisa de que el cuello de botella es diagnóstico. Si el indicador mezcla diagnóstico y tratamiento, la inferencia causal sobre *dónde* está el gap (diagnóstico vs. terapéutico) no está sustentada por la métrica.

**Qué se exige.** (i) Reconocer explícitamente que HMR mide efectividad del continuo completo y acotar las conclusiones sobre "diagnóstico" en consecuencia; o (ii) construir un indicador de outcome específico del diagnóstico (p. ej. proporción de confirmaciones en fases tempranas vía proxies disponibles, o supervivencia condicional a estadio si se logra linkage). (iii) Conciliar la definición de la Tabla 1 (estadio I) con la medida efectivamente usada (HMR), o cambiar la definición.

---

### M5 — La mitad del marco no se puede completar: j=1 (prevención primaria) carece de Q y de EC, y su "población en necesidad" está desalineada con la política

**Qué está mal.** El manuscrito reconoce (líneas 57, 230; Tabla 2 fila HG = "Not available") que **no puede estimar HG, Q ni EC para la prevención primaria** (erradicación de HP). Para j=1 sólo hay Available y Utilized (crude) coverage. Es decir, de un marco que se presenta y titula como "conceptual framework for effective coverage of GC prevention" cubriendo dos estrategias, **la EC sólo se instancia para una** (j=2). La columna j=1 de la Tabla 1 (peldaños quality-adjusted y effective) queda vacía.

Peor: la definición de N para j=1 es "toda la población infectada por HP (PrevalentCasesHP)" (líneas 44–45, Tabla 2), pero **no existe en Chile una política poblacional de test-and-treat** que haga de todos los infectados la población-objetivo. El resultado es UC_j=1 ≈ 0,005 (4,77 tratamientos por 1.000 casos prevalentes, línea 194), un 0,5% que se rotula "cobertura utilizada" pero que es ininterpretable como cobertura porque el denominador (todos los infectados) no corresponde al objetivo de la intervención. La "población en necesidad" de Shengelia debe ser la que *se beneficiaría de y es objetivo de* la intervención; aquí es una población epidemiológica de referencia sin correlato programático.

**Por qué importa.** Debilita sustancialmente la afirmación de "marco de EC": un marco cuya mitad no puede completarse, y cuyo denominador de necesidad en esa mitad está desalineado con la política, demuestra menos de lo que afirma. La comparación primaria-vs-secundaria (un eje narrativo central: "la prevención primaria ha focalizado bien, la secundaria no", abstract/§4.1) se sostiene sobre métricas **no homólogas**: j=1 con crude coverage, j=2 con effective coverage. No son comparables.

**Qué se exige.** (i) Definir N_j=1 como la población efectivamente objetivo de la política (infectados sintomáticos/elegibles según protocolo GES), no todos los infectados; (ii) o bien reconocer que para j=1 sólo se mide utilización cruda y **abstenerse de comparar** j=1 y j=2 como si ambas fueran EC; (iii) atenuar el título/marco: es un marco de EC para prevención *secundaria*, con un componente de utilización cruda para la primaria.

---

### M6 — Sobreafirmación de reproducibilidad y comparabilidad internacional: el anclaje a percentiles internos y la dependencia de HMR local destruyen justamente la comparabilidad que se reclama

**Qué está mal.** El abstract y la introducción venden un "reproducible framework ... standardizable" para monitoreo comparable (líneas 5, 15). Pero:
1. **Anclaje interno.** HGmax/HGmin son los percentiles 1º/99º de la **propia distribución chilena** de HMR por sexo-edad (línea 62). Por tanto Q y EC están definidas **relativas a la mejor red chilena**, no a un estándar clínico absoluto de ganancia alcanzable. Una red con supervivencia absoluta pésima puede tener Q≈1 si es "la mejor de un mal conjunto". Esto **contradice la definición de la Tabla 1** ("achieve the optimal health gains") y la de Shengelia (HGmax = mejor resultado *posible*, no *observado*). Y rompe el propósito de GBD, que ancló los percentiles **a través de todas las localizaciones y años** precisamente para lograr comparabilidad internacional. Con anclaje interno, EC=36% **no es comparable** con la EC de ningún otro país ni con ninguna referencia externa.
2. **Dependencia de HMR local.** Reproducir esto en otro país exige linkage individual defunción-egreso hospitalario (que la mayoría de los sistemas no tienen), datos de claims FONASA idiosincráticos, y proyecciones INE. La "reproducibilidad" es, en la práctica, dependiente de la infraestructura de datos chilena.

**Por qué importa.** La comparabilidad y estandarización se **afirman**, no se **demuestran**. Para HPP —una revista con foco explícito en sistemas de salud comparados— reclamar estandarización internacional sin un ancla externa común es un sobre-alcance evaluable.

**Qué se exige.** (i) Distinguir explícitamente "reproducible dentro de Chile" (defendible) de "comparable internacionalmente" (no demostrado); (ii) si se persigue comparabilidad, anclar HGmax/HGmin a un benchmark externo/absoluto (p. ej. supervivencia estadio-específica de series internacionales) como hace GBD, no a percentiles internos; (iii) atenuar las afirmaciones de estandarización.

---

## Defectos menores

- **m1 — Nomenclatura "health gain" para una razón de letalidad.** En el Annex 4, HG *es* la HMR (Deaths/Hosp), que puede superar 1 (p. ej. 1,14; 1,0). Llamar "ganancia en salud (HG)" a una razón de mortalidad-por-caso, donde *mayor* valor es *peor*, es un contrasentido; es una *pérdida* en salud. Q se define luego como "reducción de HMR". La terminología invierte el signo respecto de la ganancia en salud de Shengelia y confunde al lector.

- **m2 — Tabla 2 duplica la etiqueta "Maximum health gain (HGmax)"** para las filas del percentil 1º y del 99º (líneas 87–88); una debe ser HGmin. Dado que menor HMR = mejor, HGmax debería corresponder al percentil 1º y HGmin al 99º; el error tipográfico hace ambigua la dirección del rescalado en la única tabla que lo define.

- **m3 — Celdas degeneradas con N=0.** En el Annex 4 hay celdas con N=0 casos pero UCT/ECT=1,0 (p. ej. Arica, Mujer [40,50): N=0, T=1, UCT=1,0, ECT=1,0, línea 393). U/N con N=0 es indefinido; reportarlo como 1,0 infla artificialmente la cobertura agregada. Debe declararse la regla de manejo de ceros y su impacto en los agregados ponderados.

- **m4 — El tope HGmin≤1 penaliza estructuralmente a las redes rurales.** Cuando HMR>1 (defunciones > hospitalizaciones, plausible por muertes extrahospitalarias más frecuentes en zonas rurales/aisladas), Q→0 por construcción (línea 62). Pero HMR>1 es en buena parte un artefacto de **completitud de datos** (defunciones capturadas, hospitalizaciones no registradas en zonas rurales), no de calidad del cuidado. Así Q confunde calidad de datos con calidad de atención, sesgando a la baja justamente a las redes rurales que el paper destaca (Bulnes Q=0; Petorca/Nueva Imperial/Victoria/Angol con EC≈0). Este sesgo diferencial refuerza M2 y contamina el hallazgo de inequidad territorial.

- **m5 — Peldaños decorativos.** "Contact Coverage" y "Resource-adjusted Coverage" se definen en la Tabla 1 pero **no se miden ni reportan** en ningún resultado (sólo aparecen AC, UC, Q, EC en Tabla 4 y Figura 1). Dos de los seis peldaños son ornamentales. Un marco cuya cascada empírica tiene 3 rungs no debería presentar una Tabla 1 de 6 rungs sin advertirlo.

- **m6 — Mezcla Tanahashi/Amouzou reconocida pero no reconciliada.** Se agrega availability (Tanahashi) admitiendo que "no está en las cascadas más recientes" (Amouzou/Marsh), pero no se justifica por qué el numerador de availability (todas las consultas / todas las endoscopías) es conmensurable con el resto de la cascada. Reconocer la mezcla no la legitima.

- **m7 — "U0" (utilización no condicionada a necesidad) se menciona pero su rol en el marco de EC queda difuso.** Se introduce ConfirmationsCG para una utilización no condicionada (línea 55, §3.2.2) sin ubicarla claramente como un peldaño formal ni relacionarla con "contact coverage".

---

## Clarificaciones exigidas

1. **Independencia N–U–Q.** Aportar la demostración algebraica (o el reconocimiento explícito de dependencia) de que la mortalidad, presente en N (vía IMR), en Q (vía HMR) y en U (vía hospitalizaciones), no induce una relación mecánica entre numerador y denominador de EC. (Ver M2.)
2. **Taxonomía única.** Declarar si Q mide calidad de proceso (Amouzou *quality-adjusted*) o resultado (Amouzou *outcome-adjusted* / Shengelia health-gain), y alinear la Tabla 1 con la operacionalización. No pueden coexistir ambos marcos para la misma Q. (M1.)
3. **Estimando de j=2.** Clarificar que HMR mide letalidad del continuo completo (incluye tratamiento) y no la efectividad del diagnóstico; conciliar la definición de EC de Tabla 1 ("estadio I") con la medida (HMR). (M4.)
4. **Normalización de availability.** Justificar o corregir un denominador conmensurable para AC; explicar por qué AC≈100–429 constituye "cobertura". (M3.)
5. **Población en necesidad de j=1.** Justificar el uso de "todos los infectados por HP" como N frente al objetivo real de la política; explicar la interpretabilidad de UC_j=1≈0,5%. (M5.)
6. **Peldaños no reportados.** Reportar Contact y Resource-adjusted coverage o eliminarlos de la Tabla 1. (m5.)
7. **Cobertura >1 y celdas N=0.** Explicar por qué UC/EC>1 es admisible en un marco de "cobertura" y declarar la regla de manejo de N=0. (M3, m3.)
8. **Anclaje del rescalado.** Justificar el anclaje a percentiles internos frente a la afirmación de comparabilidad internacional; contrastar explícitamente con el anclaje trans-localización de GBD. (M6.)

---

## Ataque del revisor hostil

El paper se vende como una *contribución conceptual*: un "marco de cobertura efectiva" para la prevención del cáncer gástrico. Bajo escrutinio, el marco es una **re-etiquetación** de piezas existentes, ensambladas de un modo que no respeta las definiciones canónicas que cita.

Concretamente: se toma la fórmula de Shengelia (EC = U × Q), se le pegan los sustantivos de la cascada de Amouzou (contact, input/resource-adjusted, quality-adjusted, outcome-adjusted), se antepone la *availability* de Tanahashi —que los propios autores admiten obsoleta— y se instancia todo con **un único ratio de mortalidad (HMR)** rescalado a la manera de GBD. El problema es que ese HMR (i) está algebraicamente entrelazado con el denominador de necesidad, que también se deriva de la mortalidad (IMR); (ii) se rotula "quality" cuando en la taxonomía adoptada es un *outcome*; (iii) mide la letalidad de **todo** el continuo del cáncer, no la efectividad del **diagnóstico** que el marco pretende aislar; y (iv) se ancla a percentiles internos, perdiendo la comparabilidad que el paper reclama. Lo que el manuscrito llama "cobertura efectiva de j=2" es, hasta un rescalado, **la MIR de GBD con disfraz de cascada**, pero computada de modo que la mortalidad aparece a ambos lados de la fracción. Y la mitad primaria del marco (j=1) ni siquiera puede computarse.

Lo que el marco **demuestra**: que es posible calcular *algún* número por red-sexo-edad-período con datos administrativos chilenos, y que ese número varía territorialmente de manera plausible. Lo que el marco **sólo afirma**: que ese número es "cobertura efectiva" en algún sentido canónico; que la caída 88%→36% es una brecha de *calidad del cuidado* (y no un artefacto de un denominador incommensurable + anclaje interno + doble conteo de mortalidad); que el marco es estandarizable y comparable internacionalmente; y que el cuello de botella es *diagnóstico* (cuando su métrica mezcla diagnóstico y tratamiento).

Para que HPP considere esto una **contribución conceptual genuina**, el manuscrito tendría que mostrar, como mínimo: (1) un estimando explícito y una prueba de que los peldaños de la cascada son proporciones anidadas e interpretables en [0,1]; (2) que Q es separable del outcome de mortalidad usado para construir N (o el reconocimiento de que no lo es, con reformulación honesta de la etiqueta); (3) una validación de que la EC basada en HMR **recupera** la EC basada en estadio (contra la cohorte chilena de estadificación —Heise u otras—), en lugar de asumirlo; y (4) un ancla de rescalado externa que sustente la comparabilidad reclamada. Nada de esto se demuestra en la versión actual. La novedad conceptual, tal como está, no supera el umbral de "reordenamiento de marcos preexistentes con una operacionalización internamente incoherente".

---

## Severidad global

**RECHAZAR** (con posibilidad de reenvío como *grandes revisiones* sólo si el marco se reformula de raíz).

Justificación: los tres defectos foundational —M1 (conflación calidad/outcome e incoherencia entre taxonomías), M2 (doble/triple conteo de mortalidad y circularidad N–Q–U) y M3 (availability mal normalizada que rompe la naturaleza anidada/acotada de la cascada)— no son ajustes de redacción ni de análisis de sensibilidad: comprometen la **validez del constructo** del objeto central del paper (la cascada de cobertura efectiva) y, con ello, el hallazgo titular. A esto se suman M4 (estimando de j=2 contaminado por la fase terapéutica), M5 (mitad del marco vacía y N_j=1 desalineada) y M6 (sobre-afirmación de comparabilidad). En su forma actual el "conceptual framework" no está listo para una Q1 de sistemas de salud. Es reformulable —el conjunto de datos y la resolución subnacional son valiosos— pero requiere rehacer la arquitectura conceptual, no pulirla.
