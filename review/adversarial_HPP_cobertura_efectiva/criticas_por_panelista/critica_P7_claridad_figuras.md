# Revisión Adversarial P7 — Claridad, Estructura Narrativa, Inglés Científico y Tablas/Figuras
**Manuscrito:** *"Persistent effective coverage gaps in gastric cancer prevention in Chile 2010-2024: a conceptual framework and ecological study using real world data"*
**Revista objetivo:** Health Policy and Planning (Q1)
**Foco del revisor:** legibilidad, arco narrativo, calidad del inglés, tablas y figuras. NO validez estadística/clínica de fondo.

---

## Fortalezas

1. **El macro-arco narrativo es sólido y publicable en su lógica.** El hilo problema → brecha → método → hallazgos → implicancias está bien trazado: (a) hook epidemiológico fuerte ("Gastric cancer (GC) is the fifth most diagnosed malignant tumor worldwide, with South America—and Chile in particular—representing a critical hotspot"); (b) brecha clara y triple (vacío de datos de estadificación, encuestas cada 7 años, EC nunca medida para GC); (c) método novedoso (cascada de EC con RWD y proxy HMR sobre 45 redes); (d) hallazgo central memorable ("a 50-percentage-point drop-off between crude diagnostic utilization (88%) and final, outcome-adjusted coverage (36%)"); (e) tres recomendaciones de política concretas. La "idea vendible" existe y es potente.

2. **El hallazgo principal se comunica con una cifra ancla repetida y fácil de recordar** (88% → 36%), lo que funciona muy bien para audiencia de política.

3. **La sección de limitaciones (4.4) está bien ubicada** (antes de la conclusión) y es honesta respecto a sesgos rurales, datos de HP y definición de denominador.

4. **Buen anclaje conceptual** en taxonomías reconocidas (Tanahashi, Amouzou, Shengelia, Lozano) que dan legitimidad al marco.

5. **Las implicancias de política (4.3) son accionables y bien argumentadas** (triaje por riesgo, descentralización, "infostructure"), con analogías útiles (inverse care law, gestión de casos tipo colonoscopía).

Dicho esto, el problema del manuscrito **no es la narrativa sino la ejecución y presentación**: en su estado actual sería rechazado de plano en la mesa editorial antes de llegar a revisión de fondo.

---

## Defectos MAYORES

### M1. TODAS las figuras del texto principal y de los anexos son placeholders `[image]`
**Qué está mal:** No hay una sola figura real. Son placeholders: Figura 1 (cascada por clúster de riesgo, a y b), Figura 2 (evolución 2010-2024, a y b), Anexo 0 (ajuste t-Student), Anexo 3 (series de tiempo), Anexo 5 (cascadas a/b/c), Anexo 6 (a/b). Ejemplo textual: *"a) HP Treatment (j=1) \[image\] b) UGE Diagnosis (j=2) \[image\]"*.
**Por qué importa:** Las secciones 3.2.2 (Territorial Heterogeneity) y 3.2.3 (EC trends) descansan **por completo** en figuras que el revisor no puede ver. Todo el argumento visual del paper —las cascadas y las trayectorias temporales, que son la contribución metodológica central— es inauditable. Un revisor Q1 no puede evaluar la afirmación "ECj=2 followed the same pattern" ni "positive upward tread in ECj=2" sin la figura. Esto por sí solo motiva rechazo/gran revisión.
**Qué se exige:**
- Entregar todas las figuras renderizadas, en resolución de publicación, autoconsistentes con Tabla 4 y Anexos.
- **Figura 1 (cascada):** orientación de paneles pequeños **4×1 por clúster de riesgo** (bajo/medio/alto/muy alto), mostrando explícitamente los peldaños de la cascada (Available → Utilized/Crude → Quality-adjusted → Effective), con banda/whisker de **IC95%**, línea de referencia nacional, color consistente por clúster, y panel separado j=1 vs j=2.
- **Figura 2 (evolución):** small multiples por métrica (AC/UC/Q/EC), líneas por clúster con **ribbon de IC95%**, eje temporal 2010-2024 en periodos trienales.
- **Leyendas autoexplicativas** (ver M2): cada figura debe leerse sin recurrir al texto.

### M2. Leyendas de figura no autoexplicativas + brecha entre marco conceptual (Tabla 1) y métricas reportadas
**Qué está mal:** (a) Las leyendas son telegráficas: *"Figure 1. Effective coverage cascade by GC risk clusters 2022-2024 / a) HP Treatment (j=1) / b) UGE Diagnosis (j=2)"* — sin descripción de ejes, sin definir los peldaños de la cascada, sin nota de IC, sin n. (b) Más grave: **la Tabla 1 promete una cascada de 7 niveles** (Target Population, Target Service, Available, **Contact**, **Resource-adjusted**, Crude, Quality-adjusted, Effective) pero el análisis y la Tabla 2/Resultados solo operacionalizan **AC, UC, Q, EC**. "Contact Coverage" y "Resource-adjusted Coverage" se definen elaboradamente y **nunca se miden ni reaparecen**.
**Por qué importa:** Rompe el hilo conductor entre el framework y los resultados. El lector (y el revisor) espera ver la cascada completa en las figuras y solo recibe AC→UC→EC. Es una promesa incumplida que socava la coherencia narrativa central del paper, que se anuncia como "a conceptual framework".
**Qué se exige:** O se miden/reportan los peldaños Contact y Resource-adjusted, o se recorta la Tabla 1 para que el marco declarado coincida exactamente con lo operacionalizado, explicando por qué esos dos peldaños no son estimables con RWD.

### M3. Ecuaciones y notación ilegibles ("sopa" de entidades HTML) y notación colisionada
**Qué está mal:** La ecuación de Calidad (línea 65) aparece renderizada como basura: *"${Q}_{isat}=\frac{...}$=&#25;(&#25;HG&#29;sa&#29;min&#27; - &#25;HG&#29;isat&#29;&#27; )&#29;(&#25;HG&#29;sa&#29;min&#27; - &#25;HG&#29;sa&#29;max&#27;)&#27;&#30;"*. Lo mismo en el Anexo 0 (líneas 277-278). Además hay **colisión notacional**: en `ECj = Qj × Uj∣Nj =1` (línea 25), el símbolo `j=1` se usa a la vez como índice de intervención (j=1 primaria / j=2 secundaria) y como indicador de necesidad (N=1). Y subíndices corridos como *"HGminsa"*, *"HGmaxj"*.
**Por qué importa:** Un lector de política —y de hecho cualquier revisor— no puede seguir el método. Las fórmulas son el corazón operacional y están, literalmente, corruptas en el texto.
**Qué se exige:** Re-tipografiar todas las ecuaciones en LaTeX/MathML limpio; desambiguar el índice de intervención (usar p.ej. superíndice `(j)`) del indicador de necesidad (usar `N=1` o `1[need]`); definir un único convenio de subíndices.

### M4. Residuos editoriales masivos (comentarios de Google Docs, tracked changes, enlaces muertos)
**Qué está mal:** El cuerpo está plagado de anclas de comentarios `<comment_start id=kix...>` / `<comment_end...>` (decenas), al menos un texto **tachado** visible (*"~~...~~"* al cierre de la Introducción, línea 15), y **cada cita es un enlace muerto del plugin Zotero/Google Docs**: `https://www.zotero.org/google-docs/?xdyPzi` — incluso las entradas de la lista de referencias están envueltas en estos enlaces placeholder.
**Por qué importa:** Señala un manuscrito no finalizado ("no listo para enviar"). Un editor Q1 lo devuelve sin revisar. Además impide verificar las referencias.
**Qué se exige:** Limpiar TODAS las anclas de comentario, aceptar/rechazar cambios, y regenerar la bibliografía con enlaces DOI reales.

### M5. Tablas con encabezados vacíos/desalineados y una tabla-anexo íntegramente en español
**Qué está mal:**
- **Todas** las tablas (1, 2, 3, 4, Anexos 1, 2, 4) comienzan con una **fila de encabezado en blanco** (`| | | | |`) y colocan los encabezados reales en la primera fila del cuerpo → desalineación y fila fantasma.
- **Tabla 4:** los rótulos de grupo *"H. Pylori Treatment (j=1)"* y *"UGE Diagnosis (j=2)"* se ubican en las columnas 2 y 3 pero deberían **abarcar** 2 y 6 columnas respectivamente; el lector no puede saber qué columnas pertenecen a cada intervención sin la segunda fila. Además **"AC" aparece dos veces** (col 2 para j=1 ≈0,01-0,04 y col 4 para j=2 ≈90-430) con la **misma etiqueta pero escalas radicalmente distintas y sin unidades** — profundamente confuso.
- **Tabla 2:** encabezado malformado *"***Helicobacter***** Pylori treatment (j=1)**"* (exceso de asteriscos), columnas de header desalineadas respecto al cuerpo, y **dos filas consecutivas idénticas rotuladas "Maximum health gain (HGmax)"** (la segunda, "99th percentile of HMR", debe ser **HGmin**).
- **Anexo 2 está completamente en español** dentro de un manuscrito en inglés: encabezados *"Nombre, Poblacion Fonasa, Casos Fonasa CG, Consultas, Endoscopias, Tratamientos HP, Confirmacions CG, Hospitalizaciones, Defunciones"* (además "Confirmacions" está mal escrito incluso en español).
**Por qué importa:** Ilegibilidad directa y falta de profesionalismo; el Anexo 2 es inaceptable en una revista anglófona.
**Qué se exige:** Reconstruir todas las tablas con una única fila de encabezado, encabezados de grupo con *spanning* correcto, unidades explícitas por columna, corrección HGmax→HGmin, y traducción íntegra del Anexo 2 al inglés.

### M6. Inconsistencia terminológica y de siglas generalizada
**Qué está mal:** El manuscrito abusa de siglas y las usa de forma inconsistente:
- **HospitalizedGC** (línea 55) vs **HospitalizationsGC** (líneas 59, 85, 107) vs **HospitalizactionsGC** (Tabla 2, línea 86) — tres variantes de la misma variable.
- **GC vs CG:** el cuerpo usa "GC" pero aparece **ConfirmationsCG** (línea 55, orden invertido) y todo el Anexo 2 usa "CG" ("Casos CG", "Confirmacions CG", "Tratamientos CG", "Defunciones CG").
- **IMR:** definido como "Incidence-Mortality Ratios" (línea 14), "incidence-to-mortality ratios" (línea 102) e "incidence-mortality ratios" (Anexo 0, línea 270), **pero la fórmula es `IMR = Deaths/Cases`** (línea 271), es decir mortalidad/incidencia. El nombre contradice la fórmula, y la literatura estándar (Lozano 2020) usa **MIR (mortality-to-incidence ratio)**. Confusión conceptual de rótulo.
- **HMR:** en el abstract se llama *"hospital discharges-mortality ratios"* (línea 5) y en Métodos *"Hospitalization-Mortality Ratio (HMR)"* (línea 58) — deriva "discharges" vs "hospitalizations".
- **GES** se usa sin expandir (línea 28); "case lethality" / "case-fatality" / "hospital discharge lethality" se alternan como sinónimos.
**Por qué importa:** Un revisor pierde el rastro de qué variable alimenta qué métrica; la contradicción nombre-fórmula del IMR es especialmente dañina.
**Qué se exige:** Un **glosario/caja de abreviaturas** único; fijar un nombre canónico por variable (`HospitalizationsGC`, `ConfirmationsGC`, etc.); renombrar IMR→MIR o corregir la fórmula/orden; expandir GES en primer uso; un único término para letalidad.

---

## Defectos menores (errores de inglés / tipeo / siglas con ubicación aproximada)

- **m1.** Abstract (L4): "for Gastric Cancer (GC) prevention" — **doble definición de GC** en dos frases (ya definido al inicio del abstract).
- **m2.** Abstract (L4): *"with South America,  Chile in particular"* — **doble espacio** y coma en vez del em-dash usado en la Intro.
- **m3.** Abstract/DISCUSSION (L7): *"Chile needs to **to** transition"* — **"to" duplicado**.
- **m4.** Abstract/DISCUSSION (L7): *"Although primary prevention has successfully targeted high-risk areas, **The** results highlight **a persistent gap remains** between..."* — mayúscula a mitad de frase + cláusula fundida (o "a persistent gap" o "a gap remains", no ambas).
- **m5.** Intro (L9): *"Despite **these** prioritization"* — concordancia; debe ser "this prioritization".
- **m6.** Intro (L9): *"resulting in persistent low survival rates"* → "persistently low".
- **m7.** Intro (L15): *"in Chile from 2010 to **2014**"* — **debe ser 2024**; el estudio es 2010-2024 en todo el resto. Error de consistencia del periodo.
- **m8.** Resultados (L206) y Abstract-adyacente: *"positive upward **tread**"* → "trend".
- **m9.** Tabla 2 (L86): *"Hospitali**zactions**GC"* — tipeo.
- **m10.** Discusión 4.4.3 (L232): *"high case-**fatility** rates"* → "case-fatality"; además doble espacio tras el punto.
- **m11.** Discusión 4.1 (L216): *"According to our estimates, **While** the majority of GC cases access care, **but** this contact occurs..."* — mayúscula intermedia + doble conjunción "While…but…" + fragmento.
- **m12.** Discusión 4.1 (L216): *"Vague symptoms in early stages **makes** GC difficult"* — concordancia sujeto-verbo ("symptoms… make").
- **m13.** Discusión (L214): *"the performance of GC prevention **and** across Chilean health networks"* — "and" sobrante.
- **m14.** Resultados (L139): *"using hospital discharges **lead** to **a reduction in** 10%"* → "led to a reduction of 10%".
- **m15.** Métodos 2.6 (L99): *"We **didn´t** have any access"* — apóstrofo con acento agudo (´) + contracción informal impropia de texto científico.
- **m16.** Métodos (L42): *"table 2 summarizes the **variables's** definitions"* → "variables' definitions"; además capitalización inconsistente "Table 1" vs "table 2".
- **m17.** Métodos (L28): *"guaranteed by public coverage (**GES**)"* — sigla sin expandir.
- **m18.** Autores (L2): *"René Lagos,2, Cristóbal Cuadrado3,2,✉, Arnoldo Riquelme4,5,2"* — **superíndices de afiliación rotos** (René Lagos sin afiliación "1"), **sin lista de afiliaciones**, símbolo de autor de correspondencia (✉) sin dirección.
- **m19.** Discusión (L219-220): la cita *"[(Corsi Sotelo et al., 2025; Latorre et al., 2015)]"* queda **huérfana en su propia línea** tras un punto en L219 (salto de párrafo a mitad de oración).
- **m20.** Citas **no gestionadas** (texto plano, sin enlace) mezcladas con las de Zotero: *"(Heise et al 2009)"* (L58), *"(Navarrete et al 2018)"* (L224), *"(Latorre et al., 2024; Thiruvengadam et al., 2024)"* y *"(Leslie et al., 2019; Lozano et al., 2020)"* (L232) — **varias sin entrada en la lista de referencias** (Heise 2009, Navarrete 2018, Latorre 2024, Thiruvengadam 2024, Leslie 2019 no aparecen en las referencias A-T). Citas colgantes.
- **m21.** Auto-citas no publicadas múltiples: *"(Lagos & Cuadrado, n.d.)"*, *"(Libuy et al., n.d.)"*, *"(Lagos et al., En revisión)"* — además **"En revisión" en español** dentro de una lista de referencias en inglés.
- **m22.** Título: *"real world data"* sin guion vs cuerpo *"real-world data (RWD)"* con guion — inconsistencia.
- **m23.** Italización inconsistente de *H. pylori*: a veces *Helicobacter pylori* en cursiva, a veces "HP", a veces "H. pylori" sin cursiva.
- **m24.** Cifras grandes sin separador de miles: *"N=16553922"*, *"N=212706832"* (L116, L283, L379) — usar 16.553.922 / 16,553,922.
- **m25.** Precisión decimal inconsistente en Tabla 4: mezcla de 4 decimales (0.0345) y 2 decimales (0.63) en la misma tabla; y en texto "17.9" vs "4.77" (L194), "43.3%" vs tabla "0.43".
- **m26.** Subíndices que no calzan: *"IncidentCasesGC**isat** = Population**isat** × NetworkIncidenceGC**isa**"* (L48) — falta el índice t a la derecha.
- **m27.** Uso de comas/puntos y dobles espacios dispersos (p.ej. L7 "prevention.  High-resolution", L232 doble espacio).

---

## Clarificaciones exigidas

1. **¿Por qué se anuncia un marco de EC para "two interventions" si la EC solo se calcula para la secundaria (j=2)?** El abstract y el título prometen EC de la prevención de GC en general, pero el "Health Gain" de j=1 es "Not available" (L57, Tabla 2) y la Tabla 4 solo reporta AC/UC para j=1. Esta asimetría debe declararse **explícitamente en el abstract y al inicio de Resultados**, no descubrirse a mitad de camino.
2. **¿Qué significan los peldaños Contact Coverage y Resource-adjusted Coverage** de la Tabla 1 si nunca se reportan? Aclarar o eliminar.
3. **Unidades y escala de "AC":** ¿por qué AC(j=1)≈0,018 y AC(j=2)≈207 comparten etiqueta? ¿Son tasas por caso? Explicitar denominador y unidad por columna.
4. **IMR vs MIR:** aclarar la dirección del ratio y alinear nombre, fórmula y literatura.
5. **¿Es 2010-2014 o 2010-2024** el rango de la contribución subnacional (L15)? Corregir.
6. **Figuras:** entregar leyendas que definan cada peldaño de la cascada, el IC mostrado y el n por panel.

---

## Ataque del revisor hostil

> "Me piden revisar un 'conceptual framework and ecological study' cuyo marco conceptual (Tabla 1, cascada de 7 niveles) no coincide con lo que efectivamente se mide (AC/UC/Q/EC), cuyas **figuras son todas cuadros vacíos `[image]`**, cuyas **ecuaciones centrales aparecen como `&#25;(&#25;HG&#29;sa...`**, cuyo manuscrito conserva **decenas de anclas de comentarios de Google Docs y texto tachado**, cuyas citas son todas **enlaces muertos `zotero.org/google-docs/?...`** con varias referencias en el texto que **no existen en la bibliografía**, cuya **línea de autores está rota y sin afiliaciones**, y que incluye un **anexo entero en español** ('Confirmacions CG', 'Defunciones') dentro de un paper en inglés. La sola frase de cierre del abstract —*'Although primary prevention has successfully targeted high-risk areas, The results highlight a persistent gap remains'*, con mayúscula intermedia, cláusula fundida y un *'needs to to transition'* dos líneas después— me dice que este documento **no fue leído de corrido antes de enviarse**. No es que el estudio sea malo: es que **no puedo evaluarlo** porque la mitad de la evidencia (figuras, ecuaciones) es ilegible o inexistente. Esto es un *desk reject* editorial, no una revisión de fondo. La idea de fondo (88% de utilización vs 36% de cobertura efectiva; inequidad territorial invisible en el dato nacional) es genuinamente valiosa y merece publicarse —pero recién cuando el manuscrito esté terminado."

**Puntos de ataque concretos que el autor debe blindar antes de resometer:**
- Figuras reales o no hay paper (M1).
- Ecuaciones legibles (M3).
- Limpieza total de artefactos y bibliografía (M4, m20).
- Coherencia framework↔métricas (M2).
- Nomenclatura canónica única + glosario (M6).
- Tabla 4 (45×8 con IC) es **ilegible en el cuerpo**: mover el detalle por red al Anexo 4 y dejar en el texto principal solo un resumen por clúster de riesgo (bajo/medio/alto/muy alto + nacional). Los anexos gigantes (Anexo 4, cientos de filas por red×sexo×edad; Anexo 2) están bien **como anexos**, pero deben limpiarse y traducirse.

---

## Severidad global

**GRANDES REVISIONES (major revisions) — con la advertencia explícita de que, en su estado de presentación actual, el manuscrito sería RECHAZADO en mesa editorial antes de revisión de fondo.**

Justificación: el arco narrativo, la pregunta, el hallazgo central y las implicancias de política son de calidad Q1 y merecen publicarse. Pero la **ejecución de presentación** está incompleta a un nivel incompatible con envío: figuras 100% ausentes (M1), ecuaciones corruptas (M3), residuos editoriales y citas muertas (M4), tablas desalineadas y un anexo en español (M5), inconsistencia de siglas/variables (M6) y un abstract con oraciones gramaticalmente rotas. Ninguno de estos es un defecto de fondo, pero en conjunto impiden la revisión. **No recomiendo aceptar ni revisiones menores.** Recomiendo grandes revisiones con reenvío condicionado a: (1) todas las figuras renderizadas y con leyendas autoexplicativas; (2) ecuaciones re-tipografiadas; (3) limpieza total de artefactos y bibliografía verificable; (4) alineación framework-métricas; (5) glosario y nomenclatura única; (6) pase de corrección de estilo por hablante nativo.
