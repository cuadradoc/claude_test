# Informe de revisión adversarial

**Manuscrito:** *Persistent effective coverage gaps in gastric cancer prevention in Chile 2010-2024: a conceptual framework and ecological study using real world data* (Lagos, Cuadrado & Riquelme)
**Revista objetivo:** *Health Policy and Planning* (Oxford UP, Q1)
**Método de revisión:** panel de 7 revisores adversariales independientes desplegados en paralelo (dominio clínico; bioestadística; diseño/inferencia causal; marco de cobertura efectiva; reproducibilidad/integridad; novedad/encaje editorial; claridad/figuras), consolidados por un editor jefe. Cada panelista tuvo la instrucción de buscar razones de rechazo y distinguir lo que el manuscrito *demuestra* de lo que solo *afirma*.

---

## 1. Veredicto en una línea

El manuscrito aborda un problema real y valioso con un activo de datos genuino (45 redes endoscópicas funcionales, resolución subnacional que la evidencia previa no permitía), **pero en su forma actual sería rechazado en una Q1**: su hallazgo insignia (utilización cruda 88% → cobertura efectiva 36%, "por calidad") descansa en una métrica —la razón hospitalización-mortalidad (HMR)— que tres panelistas independientes califican de inválida como proxy de ganancia en salud, y que está estructuralmente acoplada al denominador del propio cálculo, de modo que el resultado central **podría ser un artefacto de definición y no un hallazgo**. A eso se suman dos bloqueantes editoriales de integridad (sin declaración ética; métodos deferidos a fuentes inaccesibles).

**Severidad por panelista:** RECHAZAR ×4 (dominio clínico, bioestadística, marco EC, reproducibilidad) · GRANDES REVISIONES con riesgo de rechazo ×3 (diseño/causalidad, novedad/HPP, claridad/figuras).

**Veredicto editorial consolidado:** **Rechazar en la forma actual** (equivalente a *reject & resubmit*), **con ruta de rescate viable** si se resuelven primero los tres defectos de fondo del constructo.

---

## 2. Lo que el estudio demuestra vs. lo que solo afirma

Esta separación es el eje de la revisión.

**Demuestra (sólido, publicable si se enmarca así):**
- Existe gran **variabilidad territorial** en tasas administrativas de tratamiento de HP, hospitalización y en la razón defunciones/hospitalizaciones de CG en FONASA, **invisible en los agregados nacionales**.
- Es **factible** construir métricas por red-sexo-edad-período con datos administrativos rutinarios y estadísticas vitales, sorteando la ausencia de registro de cáncer y de estadificación.
- Hay **heterogeneidad entre redes adyacentes** (Bulnes vs. San Carlos-Chillán; Limarí vs. La Serena) — un aporte de vigilancia descriptiva concreto.

**Solo afirma (no soportado por el diseño actual):**
- Que "el sistema falla en traducir el diagnóstico en ganancias de salud" (es una razón mortalidad/hospitalización reempaquetada, no una medición de desempeño con dimensiones independientes).
- Que la mayoría de los casos se detecta en estadio avanzado (**no hay datos de estadio**).
- Que "la prevención primaria focalizó con éxito" (no hay EC de prevención primaria; y hay causalidad inversa prevalencia→tratamiento).
- Que existe un efecto pre/post de política (diseño descriptivo, sin contrafactual).
- Que la brecha refleja calidad del cuidado (coincide punto por punto con el gradiente de **calidad del dato** que el propio texto admite).
- Que el marco es "reproducible" y "comparable internacionalmente" (métodos en Google Docs privados; anclaje a percentiles internos que destruye la comparabilidad).

---

## 3. Defectos P0 — bloqueantes (la conclusión central no se sostiene sin resolverlos)

### C1. El HMR no es un proxy válido de "ganancia en salud" *(P1, P3, P4)*
`HMR = DeathsGC / HospitalizationsGC` se presenta como "calidad"/ganancia en salud, pero mide **letalidad hospitalaria**, gobernada por el tratamiento (garantizado por GES), el case-mix, la práctica paliativa, la codificación y —crucial— la **propensión a hospitalizar**. Una red que hospitaliza más baja mecánicamente el HMR y aparece como "mejor calidad": el hallazgo estelar ("los hubs metropolitanos concentran la mayor calidad/EC") es plausiblemente ese artefacto. Además el HMR corre **inverso al progreso** (la resección endoscópica ambulatoria de casos incipientes *reduce* hospitalizaciones) y excluye del numerador las muertes sin hospitalización previa (paliativos/domicilio), sesgo que varía justo por ruralidad. Valores de HMR >1 (hasta 2,0–3,0 en el Anexo 4) son imposibles como fracción de letalidad y prueban que numerador y denominador miden poblaciones distintas. La cita a Heise 2009 **no valida** el proxy (documenta supervivencia por estadio en enfermedad avanzada). **Exigencia:** validar el HMR contra proporción de estadio I en un subconjunto con datos de etapa, o degradar el constructo a "letalidad hospitalaria" sin atribuirlo a diagnóstico precoz.

### C2. Circularidad: la mortalidad entra en N, en Q y en U *(P3, P4, P2)*
- **N** (necesidad) se deriva de la mortalidad vía IMR: `Incidencia = Mortalidad / IMR` → N ∝ defunciones.
- **Q** (calidad) se construye sobre el HMR = defunciones/hospitalizaciones.
- **U** (utilización), en la versión que el propio texto prefiere a nivel de red, **son las hospitalizaciones** = denominador del HMR.

La misma señal de mortalidad aparece a ambos lados de la fracción de EC. Con utilización ≈0,88 (cerca del techo), `EC = 0,88 × Q` **fuerza** que el "gap" sea (1−Q): decir "la brecha es de calidad" equivale a decir "la mortalidad-por-caso no está en su óptimo", que es una reformulación del outcome, no un hallazgo independiente. Contraste con GBD/Lozano 2020 (la fuente que el paper cita): allí la razón mortalidad-incidencia se usa **una sola vez** como la EC; aquí se recicla tres veces. **Exigencia:** demostrar algebraica y empíricamente que EC aporta información más allá del HMR (correlaciones EC~HMR, UC~Q, UC~HMR), o reconstruir N desde una fuente de incidencia independiente de la mortalidad, o reformular honestamente la EC como índice de vigilancia derivado de mortalidad.

### C3. Error de signo en la corrección de sesgo lognormal *(P2)*
En el Anexo 0, si `log(IMR) ~ N(μ,σ²)` y la IMR va en el **denominador**, el estimador correcto de la incidencia media usa `E[1/IMR] = exp(−μ + σ²/2)`. El manuscrito calcula `IMR = exp(μ + σ²/2)` y divide, obteniendo `exp(−μ − σ²/2)` — que no es ni la media ni la mediana, y **subestima la incidencia por un factor `exp(σ²)`**. Esto es consistente con un hallazgo interno que el manuscrito no comenta: **12 de 45 redes tienen cobertura utilizada UC > 100%** (Huasco 1,32; San Carlos 1,35; Magallanes 1,29; Met Central 1,20; etc.), imposible lógico y señal clásica de denominador subestimado. **Exigencia:** re-derivar la corrección, reportar σ², recalcular la incidencia y todas las coberturas, y verificar si desaparecen las UC>1.

### C4. Sin declaración ética ni gobernanza de datos *(P5)*
El estudio **enlaza a nivel individual** egresos hospitalarios y mortalidad pseudonimizados de millones de personas, pero no hay aprobación de comité de ética/IRB, ni consentimiento o su dispensa, ni autorizaciones de acceso DEIS/FONASA, ni declaración de cumplimiento normativo (Ley 19.628 / nueva ley de datos). En HPP/ICMJE esto es causal estándar de **desk-reject**. **Exigencia:** sección de *Ethics approval* con comité, número de protocolo, dispensa y su justificación, y las resoluciones de acceso.

### C5. Métodos deferidos a 5 referencias inaccesibles *(P5, P6)*
El núcleo metodológico se externaliza a documentos que un revisor no puede leer: definición de las 45 redes (Lagos & Cuadrado, n.d.), IMR/clusters de riesgo (Lagos et al., En revisión), prevalencia de HP —el denominador de prevención primaria— (Libuy et al., n.d., **sin URL**), reconstrucción de cobertura FONASA 2010–2014 (Lagos & Jofré, n.d.) y el "pipeline reproducible" (Lagos et al., 2026, SciPy). Los enlaces a Google Docs privados no son referencias científicas. **Exigencia:** preprint con DOI de cada una o traslado de los métodos al material suplementario del propio manuscrito.

---

## 4. Defectos P1 — mayores (grandes revisiones)

- **C6. "IC95%" mal etiquetados + propagación incompleta.** Son percentiles de una simulación Monte Carlo que solo propaga incidencia y prevalencia; ignora la variabilidad Poisson de muertes/hospitalizaciones (conteos de 0–2 por celda), los parámetros del modelo IMR, HGmax/HGmin y la imputación 2010–2014. Prueba interna: el "IC" de Q es 0,43–0,44 (±0,005) sobre razones que fluctúan entre 0 y 3 — implausible. *(P2, P3, P5)*
- **C7. Métrica Q mal condicionada.** El cap de HGmin=1 trunca a Q=0 justo las peores celdas (sesgo no aleatorio en rurales/ancianos); los percentiles 1/99 se estiman sobre conteos de 1–2 muertes; celdas con N=0 producen UC=EC=1,0 (cobertura del 100% sobre población en necesidad de cero). Requiere cotas robustas (empirical Bayes/shrinkage) y manejo explícito de N=0 y HMR>1. *(P2, P4)*
- **C8. Reencuadre para HPP.** El paper se lee como estudio descriptivo mono-país. HPP exige contribución transferible a países de ingreso bajo/medio, **Key Messages** (obligatorias) y lecciones para debates internacionales. Reencuadrar alrededor del *marco* (Chile como caso de aplicación), añadir una sección de **transferibilidad** (inputs mínimos para replicar en otro sistema sin registro de cáncer), y evaluar el formato **"How to do (or not to do)"**. Riesgo de desk-reject estimado ~50–60% en la forma actual. *(P6)*
- **C9. Lenguaje causal excede el diseño descriptivo** ("post-implementation", "primary failure", "demonstrating", "successfully targeted"). Reescribir a lenguaje asociativo o adoptar ITS/DiD para afirmaciones pre/post. *(P1, P3, P6)*
- **C10. Bypassing.** La Tabla 4 principal usa utilización por centro de atención, que los autores admiten sesgada por bypassing; la métrica por residencia **invierte conclusiones** en varias redes rurales (Petorca EC 0,00→0,42). Adoptar residencia como análisis principal y cuantificar los flujos origen-destino. *(P3)*
- **C11. Confusión no ajustada + calidad-del-dato vs. calidad-del-cuidado.** El gradiente rural-urbano atribuido a desempeño del sistema coincide con el de subnotificación diferencial que el propio texto admite. Ajustar por confusores territoriales; análisis de sensibilidad al subregistro. *(P3)*
- **C12. Error de categoría "prevención secundaria" + definición de caso.** Una EDA diagnóstica gatillada por síntomas en cáncer ya invasor no es tamizaje ni prevención secundaria; el marco omite la cascada premaligna de Correa (atrofia→metaplasia→displasia) y la vigilancia OLGA/OLGIM (MAPS II; Riquelme 2023, coautor). Falta definición histológica/anatómica de caso (ICD-O): mezcla cardial/no cardial, difuso/intestinal, y posiblemente linfoma MALT (donde erradicar HP es tratamiento, no prevención). *(P1)*
- **C13. Denominadores no interpretables.** j=1 = "todos los infectados" no es la población objetivo de la política → UC≈0,5% sin sentido. j=2 = incidentes → el 88% mide completitud de diagnóstico de un cáncer casi siempre eventualmente diagnosticado, **no** acceso oportuno. *(P1, P3, P4)*
- **C14. "Available Coverage" mal normalizada (117–429).** No es una proporción; rompe el axioma de cascada anidada en [0,1] y contradice el argumento de escasez que la motiva. Renormalizar o sacarla de la cascada como "razón de capacidad". *(P4, P2)*
- **C15. Mitad del marco vacía.** j=1 no tiene Q ni EC; la comparación primaria-vs-secundaria usa métricas no homólogas. Atenuar el título/marco o completar j=1. *(P4, P3, P1)*
- **C16. Coherencia framework↔métricas.** La Tabla 1 promete 7 peldaños (incl. Contact y Resource-adjusted) que nunca se miden; solo se reportan AC/UC/Q/EC. Recortar la Tabla 1 a lo operacionalizado. *(P4, P7)*
- **C17. Reproducibilidad y cumplimiento editorial.** Faltan: semilla MC, versiones/lockfile, licencia, DOI archivado (Zenodo), diccionario de datos, listas de códigos CIE/prestaciones, *code availability statement*; la *Data availability* es engañosa (los microdatos no pueden estar en GitHub público); sin checklist **RECORD/RECORD-PE** ni calidad del linkage; sin **COI, CRediT, ORCID ni afiliaciones**. *(P5)*
- **C18. Figuras.** **Existen en el documento — verificado en ronda 2 contra el Doc real** (los `[image]` de la extracción eran artefacto, no ausencia; los comentarios internos de coautores discuten su layout renderizado). La **calidad se evalúa sobre la figura renderizada**: con la evidencia disponible NO se afirma insuficiencia; los comentarios indican fase de pulido (IC95%, orientación 4×1, leyendas). Ajustes de forma (coinciden con los coautores): resolución de publicación, orientación 4×1 por clúster, peldaños de cascada explícitos, banda de IC95%, línea nacional de referencia y leyendas autoexplicativas. Mover la Tabla 4 (45×8) a anexo y dejar en el cuerpo un resumen por clúster. *(P7 + comentarios internos; reclasificado ronda 2: de "ausentes/insuficientes" a "presentes; forma")*

---

## 5. Defectos P2 — menores, y P3 — clarificaciones/artefactos

**Menores (P2):** sobreafirmación de la biología de HP (C19); siglas/variables inconsistentes y contradicción nombre-vs-fórmula del IMR (C20); referencias citadas ausentes de la lista — Heise 2009, Chatignoux 2021, Navarrete 2018, Latorre 2024, Thiruvengadam 2024, Leslie 2019 (C21) **[verificado REAL en ronda 2 contra la lista de referencias del Doc]**; ~27 errores de inglés/tipeo y abstract con oraciones rotas (C22); prevalencia HP histórica y corte etario 40+ apoyado en un resumen de congreso (C23); Anexo 2 en español (REAL) y HGmax→HGmin en Tabla 2 (REAL); separadores de miles (C24) — nota: los "encabezados fantasma `| | | |`" de C24 son **artefacto de serialización**, no defecto del doc.

**Clarificación importante — artefactos de extracción (P3) [CONFIRMADO en ronda 2 contra el Doc real]:** el manuscrito se leyó vía extracción de texto del Google Doc. En ronda 2 se re-verificó directamente contra el Doc (lectura vía API + comentarios internos) y se **confirma** que los siguientes son **artefactos de exportación, NO defectos del documento real** — no perseguirlos como defectos:
- **Ecuaciones en "sopa de entidades" (`&#25;…&#30;`):** en el Doc están como objetos LaTeX bien formados que renderizan (ej. verificado `${Q}_{isat}=\frac{({HG}_{sa}^{min}-{HG}_{isat})}{({HG}_{sa}^{min}-{HG}_{sa}^{max})}$`, `${EC}_{isat}=\frac{U_{isat}}{N_{isat}}\cdot Q_{isat}$`); la "sopa" es el flujo interno de glifos del objeto-ecuación.
- **`[image]`:** las figuras **existen** como imágenes embebidas (los comentarios internos de coautores discuten su layout 4×1 y su apariencia); `[image]` es cómo un export de texto representa una imagen.
- **Enlaces `zotero.org/google-docs/?…` y anclas `<comment_start>`:** field codes de Zotero y comentarios colaborativos que desaparecen al exportar a Word/PDF (higiene de exportación).
- **Filas de encabezado fantasma `| | | |`:** artefacto de serialización de tablas de Google Docs a Markdown.

**Lo que SÍ sobrevive a cualquier exportación —y se verificó REAL en ronda 2—:** los ~27 errores de inglés/tipeo y el abstract con oraciones rotas; las siglas/variables inconsistentes; el **Anexo 2 íntegro en español**; el **HGmax duplicado (debe ser HGmin) en Tabla 2**; y las **referencias citadas ausentes de la lista** (Heise 2009, Chatignoux 2021, Navarrete 2018, Latorre 2024, Thiruvengadam 2024, Leslie 2019 — cotejadas contra la lista real; ninguna figura como entrada de primer autor). **Caso aparte — Anexo 4 "truncado":** NO verificable por extracción (la relectura directa también corta en "Metropolitano Central" y la herramienta advierte truncamiento de tablas grandes); los datos por red existen en Tabla 4 y Anexo 2, así que es probable artefacto de serialización, a confirmar sobre el export. Al exportar a Word/PDF para la sumisión, limpiar solo los residuos reales (comentarios y control de cambios).

---

## 6. Conflictos entre panelistas y cómo se resolvieron

- **Severidad (rechazar vs. grandes revisiones):** se resuelve a favor de "rechazar en forma actual con ruta de rescate". El desacuerdo es de grado, no de fondo: los tres panelistas de "grandes revisiones" (diseño, HPP, claridad) coinciden en que **sin resolver C1–C3 el paper no es publicable**, que es exactamente la posición de los cuatro de "rechazar". La ruta de rescate existe porque el problema es de *constructo y framing*, potencialmente remediable, no de datos inservibles.
- **¿Figuras ausentes o débiles?** P1/P7 las leyeron como "100% ausentes"; en ronda 2 se **verificó contra el Doc real** que **existen** (los `[image]` eran artefacto de extracción; los comentarios internos #4 y #12 discuten su layout renderizado). La **calidad se evalúa sobre la figura renderizada**: NO se afirma insuficiencia; los comentarios indican que están en pulido (IC95%, 4×1, leyendas). Prevalece la lectura corregida: **presentes; ajustes de forma**, no ausencia ni juicio de calidad no observado.
- **¿Novedad genuina?** P4/P6 la consideran "reetiquetado incremental"; P3 reconoce valor de vigilancia descriptiva. Se concilia: la novedad **empírica** (resolución subnacional con RWD) es real y publicable; la novedad **conceptual** ("conceptual framework") no supera hoy el umbral de validez de constructo y debe atenuarse o reconstruirse.

---

## 7. Ruta recomendada (orden de trabajo)

1. **Prueba de vida (C1–C3).** Antes que nada: validar el HMR contra estadio (o degradarlo), demostrar que la EC no es una reparametrización del HMR, y corregir la incidencia. Si la EC sobrevive, el resto es trabajo mayor pero acotado. Si no sobrevive, reencuadrar el paper como **estudio de vigilancia descriptiva de inequidad territorial** (que es sólido) en lugar de "cobertura efectiva".
2. **Desbloqueo de revisibilidad (C4–C5).** Ética + preprints con DOI, en paralelo.
3. **Reanálisis mayor (C6, C7, C10, C11, C13, C14).** Incertidumbre honesta, Q robusta, métrica por residencia, ajuste por confusores, denominadores, disponibilidad renormalizada.
4. **Reencuadre editorial (C8, C9, C15, C16).** Marco transferible, Key Messages, lenguaje asociativo, coherencia framework↔métricas; decidir HPP vs. alternativa.
5. **Saneamiento de presentación (C17–C26).** Reproducibilidad, figuras, glosario, referencias, errata, limpieza de export.
6. **Ronda 2** de esta revisión adversarial sobre la versión revisada.

**Decisión de vía editorial (del autor):** si el reencuadre transferible es viable → HPP como "How to do (or not to do)". Si se prefiere conservar el énfasis chileno/regional → **BMJ Global Health** o **The Lancet Regional Health – Americas** (el paper ya cita LANA) son hogares naturales con menor fricción de scope.

---

*Detalle íntegro por panelista en `critica_P1..P7_*.md`. Trazabilidad completa en `bitacora_revision_adversarial.md`. Propuestas accionables en `PROPUESTAS_MEJORA.md`.*
