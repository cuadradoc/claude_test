# Revisión adversarial #5 — Reproducibilidad, proveniencia de datos, disponibilidad de código, ética e integridad

**Manuscrito:** *Persistent effective coverage gaps in gastric cancer prevention in Chile 2010–2024: a conceptual framework and ecological study using real world data* (Lagos, Cuadrado, Riquelme)
**Revista objetivo:** Health Policy and Planning (Q1)
**Foco del revisor:** exclusivamente reproducibilidad, proveniencia/gobernanza de datos, disponibilidad de código, ética e integridad de la investigación. No evalúo clínica, estadística fina ni redacción salvo que impacten estos ejes.

---

## Fortalezas

- **F1. Existe una declaración de disponibilidad de datos y un repositorio nombrado.** El manuscrito consigna un repositorio público (`https://github.com/rlagosb/GastricCancerEffectiveCoverage`) y un archivo `parquet` como artefacto de datos (líneas 103, 237). Es más de lo que ofrecen muchos estudios de RWD y da un punto de partida para exigir un depósito verificable.
- **F2. Trazabilidad numérica parcial de las cifras titulares.** Los números centrales del abstract y de resultados sí rastrean a la fila "Total" de la Tabla 4: utilización cruda 88% (86–91%) y EC 36% (35–37%) coinciden con `UC 0.88 (0.86–0.91)` y `EC 0.36 (0.35–0.37)`; los "17.9 consultas" y "4.77 tratamientos por 1000 prevalentes" (línea 194) rastrean a `AC j=1 0.0179` y `UC j=1 0.0048`. Esto demuestra al menos consistencia interna de las cifras de portada.
- **F3. Cuantificación explícita de incertidumbre.** Se corre simulación Monte Carlo (1000 sorteos) y se reportan intervalos, y hay un Anexo 0 con la especificación de la distribución del error de incidencia (t de Student, KS test). El andamiaje probabilístico existe.
- **F4. Financiamiento declarado con detalle.** La sección Funding (línea 236) lista los grants ANID/FONDECYT/FONIS con las iniciales de los investigadores responsables. Es concreto y verificable.
- **F5. Conciencia autodeclarada de sesgos de datos.** El texto reconoce el sesgo por subregistro rural, el fenómeno de *bypassing* y el uso de datos administrativos con información faltante (secciones 4.4.1–4.4.3). Esa autocrítica facilita la exigencia de mitigaciones formales.

> **Advertencia transversal:** todas las fortalezas anteriores son AFIRMACIONES, no DEMOSTRACIONES. El repositorio no se pudo verificar desde el texto (sin DOI, sin tag, sin descripción de contenido, sin licencia), y el "procedimiento completo" de construcción del dato se remite a una referencia inaccesible (ver M1). El manuscrito describe un pipeline reproducible; no evidencia uno.

---

## Defectos MAYORES

### M1. Los métodos críticos dependen de referencias no publicadas, "en revisión" o alojadas en Google Docs privados: el estudio NO es verificable por un revisor.

**Qué está mal.** Al menos cinco piezas metodológicas nucleares se externalizan a documentos que un revisor no puede leer (marcados "n.d." o "En revisión", varios apuntando a URLs de `docs.google.com` privadas, líneas 251–256):

| # | Referencia | Qué método sostiene | Dónde | Estado |
|---|---|---|---|---|
| 1 | **Lagos & Cuadrado (n.d.)** | Definición de las **45 redes funcionales endoscópicas** — la unidad de análisis de todo el paper | L20, ref L251 | Google Doc privado |
| 2 | **Lagos et al. (En revisión)** — *Declining GC Incidence in Small Areas* | (a) **clusters de riesgo de CG**; (b) **metodología IMR** para estimar incidencia; (c) afirmación de mayor riesgo de la población FONASA | L22, L95, L102, ref L254 | Google Doc privado, no publicado |
| 3 | **Libuy et al. (n.d.)** | **Prevalencia de HP por edad y región** = el denominador (N) de toda la prevención primaria | L44, ref L256 | **Sin URL siquiera** en la lista de referencias |
| 4 | **Lagos & Jofré (n.d.)** | **Extrapolación/reconstrucción de cobertura FONASA 2010–2014** (denominadores de la mitad del período) | L101, ref L252 | Google Doc privado |
| 5 | **Lagos et al. (2026, SciPy)** — *A Reproducible Data Lakehouse* | El **"procedimiento completo"** de construcción del dataset/parquet — es decir, EL artefacto de reproducibilidad | L103, L225, ref L253 | Google Doc privado / proceedings no disponible |

**Por qué importa.** Un revisor no puede evaluar: cómo se trazaron las redes (todo el análisis territorial descansa en ellas), cómo se estimó la incidencia de CG (el denominador N de prevención secundaria), cómo se definió la prevalencia de HP (el denominador N de prevención primaria), ni cómo se reconstruyó la mitad temporal de las coberturas. Es una regresión infinita de "descrito en otra parte" hacia documentos inaccesibles. La ironía es aguda: el paper que describe el pipeline "reproducible" (#5) es él mismo irreproducible/ilegible para el revisor.

**Qué se exige.**
- **Bloqueantes absolutos (sin ellos no hay revisión posible):** #1, #2, #3, #4, #5. Cada uno debe (a) proveerse como **preprint con DOI** (o depósito citable), **o** (b) trasladarse su método al **material suplementario del propio manuscrito** con detalle suficiente para reproducción independiente. Los enlaces de Google Docs NO son aceptables como referencia científica: son privados, mutables, no archivados y no citables.
- La referencia #3 (Libuy) **ni siquiera tiene URL** — se cita como fuente del denominador principal y no hay forma de recuperarla. Inaceptable.
- La #5 debe estar públicamente disponible (proceedings/preprint) **antes** de que este manuscrito pueda afirmar reproducibilidad; si no, retirar la palabra "reproducible" del título y del cuerpo.

---

### M2. Ausencia total de declaración ética / gobernanza de datos para un estudio con enlace individual de hospitalizaciones y mortalidad.

**Qué está mal.** La sección 2.6 (líneas 98–103) describe un **enlace a nivel individual** de las bases de egresos hospitalarios y de mortalidad mediante un "pseudo-identificador único provisto por el Ministerio de Salud". Se manejan datos personales de salud pseudonimizados de millones de personas. Sin embargo, en TODO el manuscrito **no existe**:
- aprobación de comité de ética / IRB (nombre del comité, número de protocolo, fecha);
- declaración de consentimiento informado **o de su exención/dispensa** por el comité;
- acuerdo de uso de datos (DUA) o autorización formal de acceso de DEIS y FONASA (número de solicitud/resolución);
- declaración de cumplimiento normativo de protección de datos (Chile: Ley 19.628 y la nueva ley de protección de datos personales; principios de minimización y confidencialidad);
- descripción del entorno seguro de procesamiento del dato individual.

La única frase relacionada es "We didn't have any access to real identifiers to ensure anonymity" (L99), que es una afirmación de anonimización, **no** una aprobación ética ni una autorización de acceso.

**Por qué importa.** Health Policy and Planning (y la práctica editorial estándar / ICMJE) **exige** una declaración ética para investigación con datos de personas, incluso pseudonimizados/rutinarios. La ausencia es habitualmente causal de **rechazo de escritorio** o de suspensión del proceso hasta subsanar. No es un detalle formal: es un requisito de integridad.

**Qué se exige.** Agregar una sección de **Ethics approval** con: comité que aprobó, número de protocolo y fecha; declaración explícita de consentimiento o de su dispensa (waiver) y su justificación; identificación de las autorizaciones/resoluciones de MINSAL/DEIS/FONASA que habilitaron el acceso y el enlace; y una declaración de cumplimiento de la normativa chilena de datos personales. Si no existe aprobación, el estudio no es publicable en su forma actual.

---

### M3. La declaración de disponibilidad de datos es engañosa y la de código es inexistente; el pipeline no es reproducible como se presenta.

**Qué está mal.**
1. **Sobredeclaración de datos.** La *Data availability* (L237) afirma que "los datasets generados y analizados durante el estudio están disponibles en el repositorio [GitHub]". Esto es implausible y probablemente falso para los **datos administrativos individuales de FONASA/DEIS** (egresos + mortalidad enlazados): esos datos casi con certeza no pueden alojarse públicamente por restricciones legales. O bien el repositorio contiene solo el `parquet` **agregado derivado** —en cuyo caso la frase es engañosa— o contiene microdatos que no deberían estar públicos —en cuyo caso hay un problema de gobernanza. En ninguno de los dos casos la declaración es correcta.
2. **Sin declaración de código.** No hay una *Code availability statement* separada. El nombre del repo sugiere código, pero el texto no lo declara, no da **licencia**, no da **tag/release**, no da **hash de commit**, no da **DOI archivado** (p. ej. Zenodo). Un repo GitHub vivo es mutable: no es un artefacto citable ni congelado.
3. **Sin semilla ni entorno computacional.** La simulación Monte Carlo de 1000 sorteos (L105) **no reporta semilla aleatoria** → resultados no reproducibles bit a bit. No se declaran versiones de lenguaje (R/Python), versiones de paquetes, ni contenedor/entorno (renv, conda, Docker). El paper mezcla ecosistemas (menciona `parquet`, "data lakehouse", SciPy) pero no fija ninguna versión.
4. **Sin diccionario de datos.** El `parquet` se menciona (L103) pero no hay diccionario de variables más allá de los encabezados de los Anexos; no se describen los **códigos CIE/ICD** que definen "caso de CG", ni los códigos de prestación que definen tratamiento HP, UGE, confirmación o tratamiento de CG. Sin las definiciones de códigos, ningún tercero puede reconstruir las cohortes.

**Por qué importa.** Para HPP y para cualquier estándar FAIR, "disponible en un GitHub" sin DOI, licencia, versión, semilla, entorno ni diccionario **no constituye reproducibilidad**. FAIR falla en los cuatro ejes: no **Findable** (sin DOI), no **Accessible** (datos administrativos restringidos, sin procedimiento de solicitud descrito), débilmente **Interoperable** (parquet sin esquema documentado), no **Reusable** (sin licencia ni metadatos).

**Qué se exige.**
- Reescribir *Data availability* distinguiendo **datos derivados compartibles** (parquet agregado, con DOI archivado y diccionario) de **microdatos restringidos** (con el **procedimiento formal para solicitarlos** a FONASA/DEIS: a quién, bajo qué condiciones).
- Añadir *Code availability* con licencia, **release etiquetado + DOI (Zenodo)**, y hash de commit correspondiente a la versión analizada.
- Reportar **semilla(s)** de la simulación MC y **versiones** de software/paquetes (o `sessionInfo()`/lockfile).
- Incluir un **diccionario de datos** y las **listas de códigos CIE/prestaciones** usados para definir cada variable.

---

### M4. No se declara ninguna guía de reporte; para un estudio de datos rutinarios/administrativos, RECORD (extensión STROBE) es prácticamente obligatoria.

**Qué está mal.** El manuscrito es un estudio ecológico observacional construido íntegramente con **datos rutinarios de salud (RWD)** con **enlace de registros**. No menciona **STROBE**, **RECORD** ni **RECORD-PE** en ninguna parte, y no adjunta checklist alguno. Faltan ítems típicos de RECORD que además son de reproducibilidad pura:
- listas completas de **códigos y algoritmos** para definir población, exposiciones y desenlaces (ítem RECORD 6.1/7.1) — ausentes;
- descripción del **proceso de linkage y su calidad** (tasa de enlace, registros no enlazados, validación) (ítem RECORD 13.1) — ausente; el texto solo dice que se usó un pseudo-ID;
- **diagrama de flujo de datos** desde las bases fuente hasta el dataset analítico — ausente;
- limpieza y desduplicación de "1st-time" claims/hospitalizaciones a lo largo de 2010–2024 — no descrita.

**Por qué importa.** HPP publica rutinariamente estudios con RWD y espera adherencia a la guía de reporte pertinente. Sin RECORD, el manuscrito omite justamente los elementos que permitirían reproducir las cohortes. No es cosmético: es el estándar mínimo de reporte para este diseño.

**Qué se exige.** Declarar y **adjuntar el checklist RECORD** (o RECORD-PE) completo, con especial atención a los ítems de definición por códigos y de calidad del linkage; incluir un diagrama de flujo de datos.

---

### M5. Conflictos de interés, CRediT/contribuciones de autoría, ORCID y afiliaciones: todas las declaraciones de integridad de autoría están ausentes.

**Qué está mal.**
- **Sin declaración de conflictos de interés** en todo el documento. No es neutral: uno de los autores (Riquelme) firma recomendaciones regionales de prevención de CG (ref. L262) y el manuscrito cita y respalda los *Lineamientos técnicos* de MINSAL 2025 (L223, ref. L260) como política a monitorear. Cualquier vínculo con la elaboración de esas guías es un COI potencial que debe declararse.
- **Sin declaración CRediT** de contribuciones. Esto se agrava por la **gobernanza de autoría**: los métodos dependen de estimaciones no publicadas de terceros (Batarce en brechas de consultas, ref. L250; Jofré en reconstrucción de cobertura, refs. L252–253; Libuy en prevalencia HP, L256). Según el contexto editorial interno de este panel, existe además una discusión no resuelta sobre **incorporar a "Matías" como coautor por estimaciones no publicadas**. Esto plantea riesgo de **autoría fantasma/de regalo** y exige clarificar quién contribuyó qué, y por qué las personas cuyas estimaciones son insumo crítico figuran (o no) como autores.
- **Sin ORCID** de los autores.
- **Afiliaciones incompletas.** El encabezado (L2) tiene superíndices numéricos (2,3,4,5) pero **no hay lista de afiliaciones** en el texto. No se puede verificar filiación institucional ni correspondencia más allá del símbolo ✉.

**Por qué importa.** ICMJE/HPP exigen COI, contribuciones de autoría, y crecientemente ORCID y afiliaciones completas. La combinación de COI ausente + CRediT ausente + insumos no publicados de terceros + una discusión abierta de coautoría es un foco de riesgo de integridad que un editor tomará en serio.

**Qué se exige.** Declaración explícita de COI de cada autor (o "ninguno"); tabla CRediT; ORCID de todos; lista completa de afiliaciones; y resolución/documentación de la autoría respecto de quienes aportaron estimaciones no publicadas (Libuy, Jofré, Batarce, "Matías"), conforme a los cuatro criterios ICMJE.

---

### M6. Citas críticas de métodos ausentes de la lista de referencias (integridad bibliográfica).

**Qué está mal.** Varias citas invocadas en el texto —algunas metodológicamente centrales— **no tienen entrada en la lista de referencias** (sección 5, L238–267):

| Cita en el texto | Función | Ubicación | En lista de refs |
|---|---|---|---|
| **Chatignoux et al. (2021)** | Método IMR para estimar incidencia — base del Anexo 0 | L270 | **No** |
| **Heise et al. (2009)** | Cohorte chilena que sostiene el uso de HMR como proxy de ganancia en salud | L58 | **No** |
| **Navarrete et al. (2018)** | "Modelo de Red Oncológica" que sustenta recomendaciones de política | L224 | **No** |
| **Latorre et al. (2024)** | Justifica definición de población en riesgo | L232 | **No** |
| **Thiruvengadam et al. (2024)** | Ídem | L232 | **No** |
| **Leslie et al. (2019)** | Justifica uso de incidencia como denominador | L232 | **No** |

**Por qué importa.** Chatignoux 2021 y Heise 2009 no son citas decorativas: sustentan el estimador de incidencia y el proxy de desenlace, respectivamente. Que citas de método no sean recuperables es un defecto de integridad y de trazabilidad: el revisor no puede verificar que el método invocado existe ni que dice lo que se afirma.

**Qué se exige.** Completar todas las entradas faltantes con DOI; verificar que cada cita del texto tenga par en la lista y viceversa.

---

## Defectos menores

- **m1. Intervalos mal etiquetados como "95% CI".** Los métodos (L105) describen reportar **mediana, percentil 2.5 y 97.5** de una simulación MC — esto es un **intervalo de credibilidad/incertidumbre**, no un intervalo de confianza frecuentista. Sin embargo el abstract, resultados y tablas los rotulan "95% CI" (L6, L138, Tabla 4). Corregir la nomenclatura en todo el manuscrito; afecta la interpretación de la incertidumbre.
- **m2. Inconsistencia del período de estudio en la contribución novel.** La introducción afirma el aporte "for the first time" para "Chile from 2010 to **2014**" (L15), mientras todo el resto del paper es **2010–2024**. Si es errata, corregir; si no, aclarar. Está en la frase que declara la novedad.
- **m3. Figuras y varios anexos son marcadores `[image]` vacíos.** Figuras 1 y 2 (L200–211) y Anexos 0, 3, 5 y 6 aparecen como `[image]` sin contenido. El revisor no puede verificar los resultados visuales (cascadas, tendencias, ajuste del error de incidencia). Reproducibilidad de resultados gráficos: no evaluable.
- **m4. Anexo 4 truncado.** La tabla de EC por red/sexo/edad (Anexo 4) se corta en "Metropolitano Central" (L572) y no cubre todas las 45 redes. La verificación red-por-red de las cifras es imposible tal como está.
- **m5. Referencias fechadas en el futuro / soportes débiles.** Varias referencias son 2026 (Lagos & Batarce 2026 con DOI; SciPy julio 2026) y una cita clave de edad-predictor (Silva et al. 2023, L264) es un **resumen de congreso** ("Libro de Resúmenes"), evidencia frágil para sostener la definición de población objetivo 40+.
- **m6. Repositorio como URL viva, no archivada.** Aun aceptando el GitHub, se cita como URL mutable sin snapshot. Un `parquet` puede cambiar entre la revisión y la publicación sin rastro.
- **m7. Rol de los financiadores no declarado.** Se listan grants (L236) pero no se indica el rol (o su ausencia) de los financiadores en diseño, análisis y decisión de publicar.
- **m8. Fuentes de 2.5 sin fechas de extracción ni versiones.** La sección 2.5 (L96–97) enumera INE/FONASA/DEIS pero sin **fecha de acceso/descarga**, versión del reporte estadístico mensual del DEIS, ni identificadores de las bases. Trazabilidad de proveniencia incompleta.

---

## Clarificaciones exigidas

1. **¿Qué contiene exactamente el repositorio GitHub?** ¿Microdatos individuales, el parquet agregado, o solo código? ¿Se puede reproducir el paper clonándolo? Enumerar contenido, licencia, tag y DOI archivado.
2. **¿Cuál es la vía formal para que un tercero obtenga los microdatos de FONASA/DEIS?** (autoridad, requisitos, tiempos). La declaración actual ("disponibles en el repositorio") no puede ser cierta para datos individuales.
3. **¿Existe aprobación de comité de ética y autorización de acceso a datos?** Aportar nombre del comité, número de protocolo, fecha, y las resoluciones de MINSAL/DEIS/FONASA.
4. **¿Qué semilla, versiones de software y entorno se usaron?** Reportarlos para permitir reproducción de la simulación MC.
5. **¿Cuáles son las listas de códigos** (CIE-10 para CG; códigos de prestación para HP, UGE, confirmación y tratamiento de CG) usadas para construir cada variable?
6. **¿Cuál fue la calidad del linkage** egresos–mortalidad? Tasa de enlace, registros no enlazados, validación del pseudo-ID.
7. **¿Se declararán COI, CRediT y ORCID?** ¿Cómo se resuelve la autoría respecto de quienes aportaron estimaciones no publicadas (Libuy, Jofré, Batarce, "Matías")?
8. **¿Estarán públicamente disponibles (preprint/DOI) las cinco referencias bloqueantes** antes de la decisión editorial, o se trasladarán los métodos al suplementario?
9. **¿Qué guía de reporte se seguirá** (RECORD/RECORD-PE) y dónde está el checklist?

---

## Ataque del revisor hostil

Este manuscrito reclama en su título ser un "framework **reproducible**", pero es precisamente lo que **no demuestra**. El "procedimiento completo" de construcción del dato se remite a un *proceeding* de SciPy que existe solo como un Google Doc privado (Lagos et al. 2026); la definición de la unidad de análisis —las 45 redes— vive en otro Google Doc privado (Lagos & Cuadrado n.d.); el denominador de prevención primaria descansa en una fuente (Libuy et al. n.d.) que ni siquiera trae URL; y el denominador de prevención secundaria y los clusters de riesgo dependen de un manuscrito "en revisión" que no puedo leer. Se me pide, como revisor, que confíe en cuatro o cinco cajas negras encadenadas. Eso no es reproducibilidad: es una promesa.

Peor aún: el estudio **enlaza a nivel individual** egresos hospitalarios y mortalidad de millones de personas y **no presenta una sola línea de aprobación ética, consentimiento/dispensa, ni autorización de acceso a datos**. En cualquier revista seria esto detiene el reloj de inmediato. La declaración de disponibilidad de datos ("disponibles en el repositorio") es, para microdatos de FONASA/DEIS, o falsa o un problema de gobernanza; no hay tercera opción benigna. No hay semilla de la simulación, no hay versiones, no hay licencia, no hay DOI, no hay diccionario de datos, no hay listas de códigos, no hay checklist RECORD, no hay COI, no hay CRediT, no hay ORCID, y hay al menos seis citas de método —incluida la que sostiene el estimador de incidencia (Chatignoux 2021)— que simplemente no están en la lista de referencias. A esto se suma una discusión de autoría abierta sobre incorporar a un colaborador por estimaciones no publicadas, sin ninguna declaración que la ordene.

En síntesis: el paper **afirma** rigor y reproducibilidad y **evidencia** lo contrario. Con la evidencia disponible, un tercero independiente no podría reconstruir ni las cohortes, ni los denominadores, ni las cifras. Y sin declaración ética, no debería siquiera entrar a revisión de fondo.

---

## Severidad global

**RECHAZAR** (reject) en su forma actual, con posibilidad de reconsideración como **nueva sumisión** solo si se resuelven simultáneamente los seis defectos mayores.

Justificación: (1) la **ausencia de declaración ética/gobernanza** para datos individuales enlazados (M2) es, por sí sola, causal de rechazo/desk-reject en HPP; (2) la **dependencia de 5 referencias bloqueantes inaccesibles** (M1) hace los métodos no verificables; (3) la **no reproducibilidad efectiva del pipeline** (M3: sin semilla, versiones, licencia, DOI, diccionario ni códigos) contradice el reclamo central del título; (4) la **omisión de guía de reporte RECORD** (M4) y (5) de **COI/CRediT/ORCID** (M5) incumplen requisitos editoriales básicos. Ninguno de estos es subsanable con edición menor. Si el comité prefiere una vía de continuidad, la mínima aceptable es **grandes revisiones con re-revisión externa completa**, condicionada a evidencia documental de ética y a la publicación con DOI de todo el material metodológico hoy inaccesible.
