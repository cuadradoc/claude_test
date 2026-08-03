# Revisión Adversarial #6 — Editor/Revisor de *Health Policy and Planning* (HPP)
## Foco: Novedad, relevancia política, encaje editorial y riesgo de desk-reject

**Manuscrito:** "Persistent effective coverage gaps in gastric cancer prevention in Chile 2010–2024: a conceptual framework and ecological study using real world data" (Lagos, Cuadrado, Riquelme).

**Marco de evaluación (HPP):** revista open access de OUP dedicada a "research and original ideas relevant to the design, implementation and evaluation of health policies and health systems in low- and middle-income countries"; exige que el trabajo se enfoque primariamente en uno o más LMIC, con al menos un coautor en el país de estudio, y que "set out the international debates to which the paper contributes, and draw out policy lessons and conclusions" (bajo pena de rechazo o revisión demorada). Límites: estudios cuantitativos/diseño fijo ≤6.000 palabras; cualitativos/mixtos ≤7.000 (excluye tablas, figuras y referencias); abstract ≤300 palabras; requiere sección **Key Messages**. Fuentes: [Author guidelines HPP](https://academic.oup.com/heapol/pages/author-guidelines); precedentes en Chile/cobertura efectiva: [Frenz et al. 2014](https://academic.oup.com/heapol/article/29/6/717/573689) y [Nazzal et al. 2016, EC e IAM en Chile](https://academic.oup.com/heapol/article/31/6/700/1749619).

---

## Fortalezas

1. **Contribución metodológica genuina en su núcleo.** Aplicar la cascada de cobertura efectiva (Shengelia/Tanahashi/Amouzou) al cáncer gástrico (CG) usando **datos administrativos (RWD) + estadísticas vitales**, sorteando la ausencia de registro poblacional de cáncer y de estadificación nacional mediante razones incidencia-mortalidad (IMR) y una razón hospitalización-mortalidad (HMR) como proxy de ganancia en salud, es una idea transferible y, en principio, atractiva para HPP. Es exactamente el tipo de "medición pragmática de cobertura efectiva en contextos con datos imperfectos" que la revista valora.

2. **Resolución subnacional (45 redes endoscópicas) con lente de equidad.** Revelar heterogeneidad territorial entre redes adyacentes (Bulnes vs. San Carlos-Chillán; Limarí vs. La Serena) que queda invisible en agregados nacionales es una fortaleza alineada con el interés de HPP por equidad, cobertura universal y desagregación subnacional. La articulación con la "inverse care law" (Hart 1971), el fenómeno de *bypassing* y las dos dimensiones de vulnerabilidad (exposición al riesgo vs. capacidad de respuesta) es conceptualmente sólida.

3. **Encaje formal con la política editorial LMIC.** Coautoría radicada en el país de estudio (requisito duro de HPP) y foco en un LMIC. El tema (garantías GES/AUGE, listas de espera, prevención priorizada por dos décadas) es de sistemas de salud, no meramente clínico.

4. **Serie temporal larga (2010–2024) y cuantificación de incertidumbre** vía simulación Monte Carlo (1.000 draws), con análisis de sensibilidad de especificación (utilización por egresos vs. GRD/claims; denominador incidencia vs. población total). Esto da robustez descriptiva.

5. **Precedente favorable en HPP.** La revista ya publicó cobertura efectiva con equidad en Chile (Frenz 2014) y cobertura efectiva ligada a sobrevida (IAM, 2016). Existe, por tanto, un "pasillo editorial" abierto para este tipo de trabajo — lo que sube la probabilidad si el framing se corrige.

---

## Defectos MAYORES

### M1 — Riesgo alto de desk-reject: el manuscrito se lee como estudio descriptivo, mono-país, no como contribución conceptual/transferible
**Qué está mal.** El propio texto se auto-clasifica como descriptivo: el abstract dice "This study **describes** the coverage of two interventions"; el diseño es "descriptive ecological study". El "gancho" central para el lector global termina siendo "otro estudio de cobertura de CG en Chile" con vocabulario de cobertura efectiva encima. HPP exige explícitamente ubicar el trabajo en debates internacionales y extraer lecciones de política transferibles; ese andamiaje está ausente o es implícito. La contribución conceptual (la cascada de EC para CG con RWD) existe pero **no está posicionada como el producto principal** — está sepultada entre resultados locales network-by-network.
**Por qué importa.** Para un editor de HPP la pregunta es "¿qué aprende un tomador de decisiones de Kenia, Perú o Vietnam de esto?". Tal como está, la respuesta es débil. Ese es el eje de un desk-reject por *scope/contribution*.
**Qué se exige.** Reencuadrar el paper alrededor del **marco transferible** (no de Chile como objeto): abrir con el problema genérico ("¿cómo monitorear cobertura efectiva de prevención de cáncer en sistemas sin registro de cáncer ni estadificación, usando solo datos administrativos?"), tratar a Chile como caso de aplicación, y cerrar con lecciones para LMIC. Considerar seriamente el formato **"How to do (or not to do)"** de HPP, que es el hábitat natural de una contribución metodológica de monitoreo.

### M2 — Novedad sobre-declarada e insuficientemente diferenciada
**Qué está mal.** El claim "first study of EC of GC to our knowledge" es **novedad por omisión**: Lozano et al. 2020 (GBD) midió EC de 4 cánceres vía IMR; este trabajo agrega el 5º (gástrico) con la misma lógica IMR. Eso es incremental, no un salto conceptual. Además, la diferenciación frente a los referentes obligados es floja:
- **Frenz 2014 (HPP):** EC + equidad en Chile — mismo país, mismo constructo, misma revista. Hay que decir explícitamente qué agrega este paper (respuesta previsible: resolución subnacional y RWD en vez de encuestas; pero eso debe argumentarse, no asumirse).
- **Lozano 2020:** el método IMR/percentiles 1–99 para HGmax/HGmin es **directamente tomado** de allí; el aporte marginal es la desagregación y la HMR como proxy de calidad. Debe delimitarse con precisión.
- **Estudios previos del propio grupo:** el paper apoya su núcleo metodológico en **~6 referencias internas no publicadas / gray literature / "n.d." / enlaces a Google Docs** (Lagos & Cuadrado n.d.; Lagos et al. En revisión; Lagos et al. 2026 SciPy; Lagos & Jofré n.d.; Libuy et al. n.d.; Lagos & Batarce 2026). Esto produce dos problemas: (a) **verificabilidad nula** de los métodos críticos (definición de redes, reconstrucción FONASA 2010–2014 por modelos mixtos, IMR, prevalencia HP), y (b) percepción de **salami slicing** — que este manuscrito es un fragmento de un proyecto mayor cuyo aporte incremental no está claro.
**Por qué importa.** Un revisor hostil convertirá "first study of EC of GC" en "quinto cáncer añadido a un método existente, con métodos deferidos a papers propios inéditos". Eso hunde la percepción de novedad.
**Qué se exige.** (1) Una tabla o párrafo explícito de **delta de contribución** frente a Frenz 2014, Lozano 2020, Amouzou/Marsh y los papers companion. (2) Reemplazar dependencias inéditas por métodos autocontenidos en el manuscrito o su suplemento (no "described elsewhere" en un Google Doc). (3) Rebajar/matizar el "first" o defenderlo con criterios verificables.

### M3 — Riesgo de mismatch de alcance: ¿es esto un paper de *health policy & systems* o de *cancer epidemiology/measurement*?
**Qué está mal.** El corazón analítico —usar la **reducción de HMR como proxy de "health gain"** para la dimensión Calidad de la EC— es un supuesto de medición epidemiológica fuerte y discutible (ganancia en salud aproximada por razón hospitalización-mortalidad, validada solo con una cohorte chilena de 2009, Heise). Buena parte del paper (Annex 0 IMR, tablas network×sexo×edad) es epidemiología de medición, no análisis de sistemas/políticas. HPP puede leerlo como **demasiado clínico/epidemiológico** para su scope, o como **sub-desarrollado en la dimensión de sistemas** (¿qué falla organizacional, de financiamiento, de gobernanza produce la brecha? — se menciona, pero no se analiza con datos).
**Por qué importa.** El encaje editorial es binario en la etapa de screening. Si el editor percibe "measurement paper", lo deriva a una revista de epidemiología/oncología o de métricas.
**Qué se exige.** Fortalecer el andamiaje de *health systems*: vincular las brechas a mecanismos de sistema (distribución de especialistas, arquitectura público-privada MLE/ISAPRE, incentivos de las garantías GES, gobernanza de listas de espera) con evidencia, no solo con narrativa. Y validar o acotar seriamente el proxy HMR (idealmente contra estadificación en un subconjunto).

### M4 — Recomendaciones de política genéricas, no derivadas de los datos y con sobre-promesa respecto al diseño
**Qué está mal.** Las tres recomendaciones (triage por riesgo con pepsinógeno/antígenos HP; descentralización de capacidad diagnóstica a zonas rurales; transformar datos administrativos en "infostructure") son razonables pero: (a) **no se testean ni cuantifican** en el estudio; (b) podrían escribirse **sin haber hecho el análisis** — no emergen de un resultado específico; (c) **sobre-prometen** frente a un diseño ecológico descriptivo. Peor: la Discusión desliza lenguaje causal ("the system's **primary failure** lies in its inability to translate diagnosis into health gains", "demonstrating that...") que excede lo que un diseño ecológico correlacional puede sostener. El *bypassing* se invoca como explicación pero también se admite como sesgo de las propias métricas — no se puede tener ambas sin cuantificar.
**Por qué importa.** HPP premia lecciones de política **accionables y calibradas al tipo de evidencia**. Recomendaciones genéricas + claims causales sobre evidencia descriptiva es una combinación que los revisores penalizan como "policy theatre".
**Qué se exige.** (1) Anclar cada recomendación a un hallazgo específico y cuantificado (p. ej., "la brecha de calidad de X pp en redes de riesgo muy alto Y sugiere Z"). (2) Sustituir lenguaje causal por asociacional (match design-to-claim). (3) Declarar explícitamente qué NO puede concluir el diseño (contrafactual del triage, efecto de la descentralización).

### M5 — Transferibilidad LMIC no explicitada ni operacionalizada (la palanca de encaje más grande, desperdiciada)
**Qué está mal.** El ángulo que **más subiría la probabilidad en HPP** —"cómo otro LMIC replica este marco con sus propios datos administrativos"— está esencialmente ausente. No hay una sección de **prerrequisitos de datos mínimos** (¿qué necesita un país: claims de tratamiento? egresos linkeables a mortalidad? un PBCR regional para calibrar IMR? proyecciones poblacionales subnacionales?), ni discusión de portabilidad de los supuestos (IMR representativa, HMR como proxy, extrapolación por modelos mixtos), ni de condiciones de fallo. Sin esto, la contribución queda **local**, contradiciendo el mandato LMIC de la revista.
**Por qué importa.** Es precisamente el "so what" transferible que HPP exige. Es también lo que separa "estudio de Chile" de "framework para sistemas con datos administrativos e infraestructura de registro débil" (que es la mayoría de LMIC).
**Qué se exige.** Una subsección explícita de **replicabilidad/transferibilidad**: inputs mínimos, árbol de decisión de proxies según disponibilidad de datos, límites de validez externa, y un ejemplo de cómo escalaría a otro país de la región. Idealmente, tabla de "datos requeridos vs. datos deseables".

### M6 — Título/abstract no comunican la contribución en 30 s; y no cumplimiento de formato HPP
**Qué está mal.**
- **Título** largo y con la contribución sepultada; "conceptual framework and ecological study" mezcla el aporte con el diseño y no señala el "qué nuevo".
- **Abstract** con estructura OBJECTIVE/METHODS/RESULTS/DISCUSSION que no coincide con la de HPP (Background/Methods/Results/Conclusions ≤300 palabras) y **sin la sección obligatoria "Key Messages"** (3–4 viñetas). No hay 3–5 *key findings* explícitos en ningún lugar del paper.
- **Figuras placeholder:** Figuras 1 y 2 y los Anexos 0, 3, 5 y 6 aparecen como `[image]` — **no revisables**. Un manuscrito con figuras sin renderizar es motivo frecuente de devolución administrativa antes de revisión.
  > **Corrección (ronda 2 — verificado contra el Doc real):** **ARTEFACTO de extracción**, no figuras sin renderizar. Las figuras existen en el Doc (el `[image]` es cómo un export de texto representa una imagen embebida; los comentarios internos de coautores discuten su apariencia y layout: *"Se ven mucho mejor!… IC95%"*, *"Plotealos como 4×1…"*). **Se retira** el riesgo de "devolución administrativa por figuras sin renderizar" de la lista de motivos de desk-reject. Los demás sub-puntos de M6 se mantienen REALES y verificados: el **abstract sigue formato OBJECTIVE/METHODS/RESULTS/DISCUSSION** (no Background/Methods/Results/Conclusions de HPP) y **carece de la sección "Key Messages"** obligatoria; el suplementario voluminoso y las erratas de inglés persisten.
- **Suplementario desproporcionado:** Annex 2 y especialmente Annex 4 (tablas network×sexo×grupo etario) abarcan decenas de páginas de datos crudos, inusable tal como está presentado; excede lo razonable y no está curado para lectura.
- **Errores internos y de redacción** que delatan borrador no pulido: "Chile needs **to to** transition"; Tabla 2 lista **"Maximum health gain (HGmax)" dos veces** donde una debe ser HGmin; "we capped HGmin**sa** at 1"; "45 local endoscopic health networks... from **2010 to 2014**" (contradice 2010–2024); mezcla de "95% CI" en abstract con percentiles 2.5/97.5 de Monte Carlo (que son intervalos de credibilidad, no IC frecuentistas); "HospitalizactionsGC" (typo en Tabla 2); acrónimos locales sin desarrollar para lector internacional (FONASA, DEIS, MLE, ISAPRE, PNC, HA, GES).
**Por qué importa.** En la etapa de screening editorial, formato incumplido + figuras placeholder + abstract sin Key Messages es un cóctel que dispara devolución/desk-reject **antes** de que se evalúe el mérito.
**Qué se exige.** Reescribir título orientado a contribución; abstract al formato HPP con **Key Messages** de 3–4 viñetas y 3–5 hallazgos numéricos explícitos; renderizar todas las figuras; curar y podar el suplementario; pasada de edición de inglés científico.

---

## Defectos menores

- **m1.** No hay enumeración explícita de 3–5 *key findings*; el lector debe reconstruirlos.
- **m2.** Inconsistencia de período: 2010–2024 en casi todo el texto vs. "2010 to 2014" (línea 15).
- **m3.** "n=29 HA divididas en 45 redes" debería reconciliarse visiblemente con las ~45 filas de la Tabla 4.
- **m4.** Available Coverage j=2 con valores >1 (117–429 "por caso") se presenta de forma opaca; un lector general no interpreta la escala sin ayuda.
- **m5.** Tablas 1 y 2 parcialmente redundantes (podrían fusionarse; Tabla 1 podría ir a suplemento).
- **m6.** Referencias no recuperables (Google Docs, "n.d.", "En revisión") en posiciones metodológicamente críticas — problemático para una revista indexada; al menos deberían depositarse en preprint con DOI.
- **m7.** Resultados y Discusión se solapan (se repiten cifras 88%/36%); podría consolidarse.
- **m8.** Conclusión delgada y genérica ("paradigm shift toward risk-stratified triage...") — repite las recomendaciones sin cierre de contribución.
- **m9.** El abstract afirma que "primary prevention has successfully targeted high-risk areas" pero HG/EC de prevención primaria **no se pudo estimar** (sin datos de erradicación) — hay una tensión entre lo que se afirma y lo que se midió.

---

## Clarificaciones exigidas

1. **Delta de novedad:** en una frase verificable, ¿qué aporta este paper que no esté ya en Frenz 2014, Lozano 2020, y en los papers companion del grupo (Lagos et al. En revisión; Lagos & Cuadrado n.d.; SciPy 2026)? ¿Es este manuscrito separable de esos, o es una porción de un mismo proyecto?
2. **Validez del proxy HMR:** ¿existe validación externa de la razón hospitalización-mortalidad como proxy de ganancia en salud/estadio más allá de Heise 2009? Sin ello, ¿cómo se acota la interpretación de "Calidad" y "EC"?
3. **Transferibilidad:** ¿cuáles son los inputs mínimos para replicar el marco en otro LMIC, y qué se rompe si un país carece de PBCR regional, de linkage egreso-mortalidad o de claims de tratamiento?
4. **Causalidad vs. asociación:** ¿los autores sostienen que el triage/descentralización mejorarían la EC, y con qué base? Si es hipótesis, debe rotularse como tal.
5. **Entregables faltantes:** figuras renderizadas, Key Messages, hallazgos clave explícitos, y confirmación de cumplimiento de límite de palabras del cuerpo principal.

---

## Ataque del revisor hostil (argumento de desk-reject más fuerte)

> "Este es un estudio **descriptivo, ecológico y mono-país** cuya novedad analítica se reduce a **agregar el cáncer gástrico como quinto cáncer** a un método de cobertura efectiva vía IMR ya publicado (Lozano 2020, GBD), aplicado a datos administrativos chilenos, y cuyos métodos centrales (definición de redes, reconstrucción FONASA, IMR, prevalencia HP) están **deferidos a cinco manuscritos internos no publicados** enlazados como Google Docs. El proxy de 'ganancia en salud' (razón hospitalización-mortalidad) descansa en un solo estudio de 2009 y no se valida. No hay palanca experimental ni cuasi-experimental sobre las preguntas de política que plantea; las recomendaciones (triage, descentralización, 'infostructure') son **genéricas y no se derivan de los datos**, y el manuscrito **no articula un marco transferible** que otro LMIC pueda adoptar —el único ángulo que justificaría HPP. El abstract carece de las **Key Messages** obligatorias, las figuras son **placeholders `[image]`**, el suplementario es un volcado de tablas crudas de decenas de páginas, y el texto tiene errores que delatan un borrador. Por *scope* y *contribución*, encaja mejor en una revista regional o de medición que en *Health Policy and Planning*. **Desk-reject.**"

> **Corrección (ronda 2 — verificado contra el Doc real):** La pieza "las figuras son placeholders `[image]`" es **falsa como defecto del documento**: es un artefacto de extracción; las figuras existen (ver corrección de M6). Retirado ese elemento, el argumento de desk-reject **se apoya solo en lo que es verificable y real**: framing descriptivo mono-país, transferibilidad LMIC ausente, dependencia de métodos inéditos, abstract sin **Key Messages** y erratas de borrador. El núcleo del reproche de *scope/contribución* de P6 **se mantiene**; solo se depura la pieza de presentación errónea.

Este es el escenario que hay que neutralizar. Es contundente porque cada pieza es verificable en el propio manuscrito.

---

## Recomendación de encaje (HPP sí/no; alternativas)

**HPP: SÍ, pero condicional a un reencuadre mayor.** Hay precedente (Frenz 2014; EC-IAM 2016) y el tema es de sistemas. Pero **tal como está, el riesgo de desk-reject es moderado-alto (≈50–60%)**, impulsado por: framing descriptivo, transferibilidad LMIC ausente, formato incumplido (Key Messages, figuras placeholder) y dependencia de métodos inéditos. HPP se vuelve la revista correcta **solo si** el paper: (1) se reposiciona como **marco transferible de monitoreo de cobertura efectiva de prevención de cáncer para sistemas sin registro de cáncer** (posiblemente en formato **"How to do (or not to do)"**); (2) explicita lecciones para debates internacionales y prerrequisitos de replicación LMIC; (3) internaliza sus métodos (deja de depender de Google Docs); (4) cumple formato (Key Messages, 3–5 hallazgos, figuras renderizadas, suplementario podado); (5) calibra las recomendaciones y el lenguaje causal al diseño.

**Alternativas honestas si los autores no quieren reencuadrar:**
- **BMJ Global Health** — open access, receptiva a métricas/RWD, equidad y LMIC; encaje natural para un paper de medición con ángulo de sistemas.
- **The Lancet Regional Health – Americas** — el propio paper ya cita dos trabajos de LANA (Riquelme 2023; Quezada-Díaz 2025); alta relevancia regional del CG en las Américas; buen hogar si el énfasis queda en el caso chileno/latinoamericano.
- **International Journal of Health Policy and Management (IJHPM)** — sistemas y políticas, más flexible con estudios de caso-país bien enmarcados.
- **International Journal for Equity in Health** — si el eje se vuelve la inequidad territorial (inverse care law, bypassing).
- **Health Systems & Reform** — si se refuerza el análisis de mecanismos de sistema.
- (Para la parte puramente metodológica IMR/HMR, una revista de *cancer epidemiology* o *Population Health Metrics*, pero eso sacrifica el ángulo de política.)

---

## Severidad global

**GRANDES REVISIONES (major revisions), con riesgo real de desk-reject en su forma actual.**

- Como está submitido: **riesgo de desk-reject moderado-alto (~50–60%)** por scope/contribución + incumplimiento de formato (Key Messages, figuras placeholder, métodos deferidos a inéditos).
- El material subyacente es **publicable y potencialmente valioso para HPP**, pero requiere una intervención mayor de framing (M1, M5), delimitación de novedad (M2), calibración de política/causalidad (M4), decisión de alcance (M3) y saneamiento de formato (M6) antes de que un editor lo envíe siquiera a revisión.
- Recomendación operativa: **no enviar a HPP en el estado actual.** Reescribir como contribución metodológica transferible con Key Messages, figuras reales y métodos autocontenidos; o redirigir a BMJ Global Health / Lancet Regional Health – Americas.
