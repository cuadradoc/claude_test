# Propuestas de mejora accionables

Complemento al informe de revisión. Aquí van los "quick wins" y borradores concretos que el autor (René) puede adoptar. **Importante:** las propuestas de framing y las plantillas de abstract asumen que las cifras (88%, 36%, etc.) **sobreviven** al reanálisis de los defectos P0 (C1–C3). Mientras eso no se resuelva, úsense como *estructura*, no como texto final: si la EC no supera la validación del HMR, el paper debe reencuadrarse como estudio de vigilancia de inequidad territorial, no de "cobertura efectiva".

Ninguna cifra, referencia ni aprobación se inventa. Lo que no está verificado se marca como pendiente del autor.

---

## 1. Reencuadre y título

**Problema (C8, C2, C15):** el título mezcla aporte y diseño ("a conceptual framework and ecological study"), promete "cobertura efectiva de la prevención" cuando la EC solo se calcula para la prevención secundaria, y no señala qué es nuevo ni transferible.

**Opciones de título orientadas a contribución (elegir según la decisión de vía editorial):**

- *Si sobrevive el constructo EC y se va a HPP como marco transferible:*
  "Measuring effective coverage of cancer prevention without a cancer registry: an administrative-data framework applied to gastric cancer in Chile, 2010–2024"
- *Si se enfatiza la inequidad territorial (encaje IJEH / equidad):*
  "Territorial inequities in gastric cancer prevention hidden in national averages: a subnational real-world-data analysis of 45 endoscopic networks in Chile"
- *Si el HMR no valida y se degrada a vigilancia descriptiva:*
  "Subnational surveillance of gastric cancer prevention using routine administrative data: territorial gaps between epidemiological need and service delivery in Chile"

**Movimiento de framing (apertura de la Introducción):** abrir con el problema **genérico** ("¿cómo monitorear la cobertura efectiva de la prevención del cáncer en sistemas de salud sin registro de cáncer ni estadificación, usando solo datos administrativos?") y presentar a Chile como **caso de aplicación**, no como el objeto. Cerrar Discusión con una subsección de **transferibilidad LMIC**: inputs mínimos requeridos (claims de tratamiento; egresos enlazables a mortalidad; un registro poblacional regional para calibrar la IMR; proyecciones poblacionales subnacionales), qué se rompe si falta cada uno, y límites de validez externa.

---

## 2. Plantilla de abstract en formato HPP + Key Messages

HPP usa **Background / Methods / Results / Conclusions**, ≤300 palabras, e **exige** una sección "Key Messages" (3–4 viñetas). El abstract actual usa OBJECTIVE/METHODS/RESULTS/DISCUSSION y no tiene Key Messages.

**Estructura sugerida (rellenar con cifras ya validadas tras C1–C3):**

> **Background.** Gastric cancer is a leading cause of cancer mortality in Chile, where prevention has been prioritized for two decades (guaranteed endoscopic diagnosis since 2006; H. pylori eradication since 2013), yet most cases are still diagnosed late. In the absence of a functional cancer registry and stage-at-diagnosis data, prevention coverage has never been monitored at a subnational level. We develop and apply a framework to estimate the effective coverage cascade of gastric cancer prevention from routine administrative and vital-statistics data.
>
> **Methods.** Ecological analysis of ~80% of the population (public insurance, FONASA), 2010–2024, across 45 functional endoscopic networks. We estimated need, [available], utilized and effective coverage for primary (H. pylori eradication) and secondary (endoscopic diagnosis) prevention, using incidence–mortality ratios to impute incidence and a hospitalization–mortality ratio as an outcome proxy, with uncertainty via Monte Carlo simulation. [Declarar aquí, honestamente, la naturaleza del proxy y sus límites.]
>
> **Results.** [3–5 hallazgos numéricos con su intervalo, tras reanálisis: brecha utilización↔outcome; desacople riesgo-cobertura rural/metropolitano; tendencia divergente primaria vs. secundaria; magnitud de la inequidad entre redes adyacentes.]
>
> **Conclusions.** [Lección transferible + implicancia de política calibrada al diseño; sin lenguaje causal.]

**Key Messages (borrador, 4 viñetas — ajustar a los números finales):**
- Routine administrative data can reveal subnational gaps in cancer-prevention coverage that national averages hide, in settings without a cancer registry.
- In Chile, [X]% of gastric-cancer cases eventually reach diagnosis, but the translation of that diagnosis into the best attainable survival is far lower and highly unequal across territories.
- The largest gaps concentrate in high-risk rural networks, consistent with an inverse-care-law pattern amplified by patient bypassing to metropolitan hubs.
- Monitoring effective coverage — not just administrative compliance — requires linking claims, hospitalizations and mortality; we outline the minimum data any LMIC would need to replicate this.

**Enumerar 3–5 "key findings" explícitos** también al inicio de Resultados, como gancho (el hilo de comentarios interno #7 ya lo pedía).

---

## 3. Glosario canónico de abreviaturas y variables (C16, C20)

Fijar **un** nombre por variable y usarlo en texto, tablas y fórmulas. Propuesta:

| Canónico | Definición | No usar (variantes a eliminar) |
|----------|------------|-------------------------------|
| `HospitalizationsGC` | 1ª hospitalización por CG | HospitalizedGC, HospitalizactionsGC |
| `ConfirmationsGC` | Garantías de confirmación de CG | ConfirmationsCG |
| `TreatmentsGC` / `TreatmentsHP` | Garantías de tratamiento | — |
| `DeathsGC` | Defunción por CG con egreso previo | — |
| **MIR** (no IMR) | *Mortality-to-incidence ratio* = Deaths/Cases | IMR (contradice la fórmula; la literatura, incl. Lozano 2020, usa MIR) |
| `HMR` | *Hospitalization–mortality ratio* = DeathsGC/HospitalizationsGC | "hospital discharges-mortality ratio" (abstract) |
| GC | Gastric cancer (inglés, en todo el texto) | CG (queda solo en el Anexo 2, que hay que traducir) |
| GES | Explicar en primer uso: *régimen de Garantías Explícitas en Salud* | usar sin expandir |

**Índice de intervención:** desambiguar `j` (intervención: j=1 primaria, j=2 secundaria) del indicador de necesidad (`N=1`). Sugerencia: superíndice `(j)` para la intervención.

**Contradicción nombre-fórmula a corregir:** el texto llama "IMR = Incidence-Mortality Ratio" pero la fórmula del Anexo 0 es `Deaths/Cases` (= mortalidad/incidencia = **MIR**). Renombrar a MIR o corregir la fórmula; hoy son incoherentes.

---

## 4. Errata de inglés / tipeo (reales, sobreviven a la exportación) (C22)

Correcciones directas (ubicación aproximada por sección):

| Actual | Corregido |
|--------|-----------|
| "Chile needs **to to** transition" (Abstract) | "Chile needs to transition" |
| "Although primary prevention has successfully targeted high-risk areas, **The** results highlight **a persistent gap remains**" | "…high-risk areas, the results highlight a persistent gap between epidemiological need and secondary prevention" (elegir *una* cláusula) |
| "Despite **these** prioritization" (Intro) | "Despite this prioritization" |
| "persistent **low** survival rates" | "persistently low survival rates" |
| "45 local endoscopic health networks…from 2010 to **2014**" (Intro) | "…2010 to 2024" |
| "positive upward **tread**" (Resultados) | "positive upward trend" |
| "high case-**fatility** rates" (4.4.3) | "high case-fatality rates" |
| "the variables**'s** definitions" | "the variables' definitions" |
| "using hospital discharges **lead** to **a reduction in** 10%" | "led to a reduction of 10%" |
| "Vague symptoms in early stages **makes**" | "make" |
| "the performance of GC prevention **and** across…networks" | eliminar "and" |
| "We **didn´t** have any access" | "We did not have access" (apóstrofo recto; registro formal) |
| "N=16553922" / "N=212706832" | separadores de miles |

**Recomendación:** pase completo de corrección por hablante nativo de inglés científico; el abstract debe leerse de corrido sin oraciones rotas (un revisor lee "no fue releído antes de enviarse").

---

## 5. Referencias — completar la lista (C21)

Citas presentes en el texto pero **ausentes de la lista de referencias**. DOIs verificados por el panel (usar tal cual); los no verificados quedan como **pendiente del autor** (verificar antes de someter — no inventar):

| Cita | Función | DOI verificado |
|------|---------|----------------|
| Heise et al. 2009 | Cohorte chilena de supervivencia de CG por estadio | `10.3748/wjg.15.1854` |
| Pimentel-Nunes et al. 2019 (MAPS II) | Vigilancia de condiciones premalignas (para C12) | `10.1055/a-0859-1883` |
| Ford et al. 2014 | Erradicación HP y reducción de incidencia (RR 0,66) | `10.1136/bmj.g3174` |
| Terasawa et al. 2019 | Metaanálisis bayesiano erradicación HP | `10.1136/bmjopen-2018-026002` |
| Chatignoux et al. 2021 | Método IMR de estimación de incidencia (Anexo 0) | **Pendiente: verificar y agregar** |
| Navarrete et al. 2018 | Modelo de Red Oncológica (política) | **Pendiente: verificar y agregar** |
| Latorre et al. 2024 | Definición de población en riesgo | **Pendiente: verificar y agregar** |
| Thiruvengadam et al. 2024 | Ídem | **Pendiente: verificar y agregar** |
| Leslie et al. 2019 | Uso de incidencia como denominador | **Pendiente: verificar y agregar** |

Además: al exportar a Word/PDF, regenerar la bibliografía con Zotero de modo que las citas queden como texto formateado (no como *field codes* `zotero.org/google-docs/?...`), y verificar par cita↔referencia en ambos sentidos.

---

## 6. Presentación — checklist de saneamiento antes de someter

- [ ] Exportar a Word/PDF **aceptando cambios y eliminando comentarios** (los residuos `<comment_start>` y el texto tachado desaparecen así; no son defectos del doc).
- [ ] Verificar que las **ecuaciones** se renderizan bien en el export (en el Google Doc están; el "sopa de entidades" era artefacto de la extracción de texto de esta revisión).
- [ ] **Figuras** a resolución de publicación, 4×1 por clúster de riesgo, con peldaños de cascada, banda de IC95%, línea nacional y leyendas autoexplicativas (comentarios internos #4/#12).
- [ ] **Traducir el Anexo 2** íntegro al inglés ("Confirmacions CG" → "GC confirmations", etc.).
- [ ] Reconstruir tablas: una sola fila de encabezado (eliminar la fila fantasma), encabezados de grupo con *spanning* correcto, **unidades por columna** (especialmente "AC", que hoy comparte etiqueta con escalas 0,01 vs 200), y corregir "HGmax" duplicado → HGmin en la Tabla 2.
- [ ] Mover la Tabla 4 (45×8 con IC) a anexo; dejar en el cuerpo un **resumen por clúster** (bajo/medio/alto/muy alto + nacional).
- [ ] Añadir: sección **Ethics approval**; **Data availability** corregida (derivados compartibles con DOI + vía de solicitud de microdatos); **Code availability** (licencia, release+DOI Zenodo, semilla MC, versiones); **checklist RECORD**; **COI**, **CRediT**, **ORCID**, **afiliaciones completas**.
- [ ] Verificar límite de palabras del cuerpo (HPP: ≤6.000 cuantitativo; ≤7.000 mixto), abstract ≤300, y añadir **Key Messages**.

---

*Estas propuestas son de adopción opcional por el autor; no se editó el documento original. La prioridad absoluta sigue siendo resolver los defectos de fondo C1–C3 antes de invertir en pulido de presentación.*
