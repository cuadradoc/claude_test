# Revisión Adversarial #2 — Bioestadística y Métodos Cuantitativos
**Manuscrito:** *Persistent effective coverage gaps in gastric cancer prevention in Chile 2010–2024*
**Revista objetivo:** Health Policy and Planning (Q1)
**Foco de esta revisión:** validez estadística de Métodos (2.4, 2.6, 2.7) y Anexo 0 (incidencia por IMR); propagación de incertidumbre; construcción de Q/EC; inferencia ecológica con conteos pequeños; uso de "significant".

---

## Fortalezas

- El marco conceptual de cobertura efectiva (Tanahashi/Shengelia/Amouzou) está bien referenciado y la descomposición N–U–Q es, en principio, defendible.
- El uso de razones incidencia-mortalidad (IMR) sobre datos de registros poblacionales para imputar incidencia (Chatignoux 2021; Lozano 2020) es un enfoque legítimo y citado en la literatura de GBD.
- Se intenta cuantificar incertidumbre (Monte Carlo) en lugar de reportar sólo puntos, y se realizan dos análisis de sensibilidad de especificación (hospitalizaciones como U; población total como N).
- La estratificación de la prevalencia de HP por región y edad, y el reconocimiento explícito del fenómeno de *bypassing* y del sesgo de subregistro rural, muestran conciencia de las limitaciones. Estas fortalezas, sin embargo, no compensan los defectos que siguen.

---

## Defectos MAYORES

### M1. La corrección de sesgo lognormal (exp(...+σ²/2)) está aplicada en el sentido EQUIVOCADO → la incidencia queda sistemáticamente subestimada
En el Anexo 0 se ajusta `log(E(Deaths)/Cases) = βsa·MedianAge + β0 + βi`, con `βi ~ N(0,σ²)`, y se define `IMR_sa = exp(βsa·MedianAge + β0 + σ²/2)`. El término `+σ²/2` es la corrección de media lognormal para estimar **E[IMR]**. El problema es que la IMR entra como **denominador**: `Incidencia = Mortalidad / IMR`.

Si `log(IMR) ~ N(μ,σ²)`, entonces:
- `E[Incidencia] = Mortalidad·exp(−μ + σ²/2)` (media correcta),
- `mediana(Incidencia) = Mortalidad·exp(−μ)`.

Pero el manuscrito calcula `Incidencia = Mortalidad / exp(μ + σ²/2) = Mortalidad·exp(−μ − σ²/2)`, que **no es ni la media ni la mediana**: subestima la media por un factor `exp(σ²)` y queda por debajo de la mediana por `exp(σ²/2)`. El signo de la corrección debía invertirse al pasar la variable lognormal al denominador (aplicar `E[1/IMR] = exp(−μ + σ²/2)`).

**Por qué importa:** la magnitud es material. Con σ² = 0.3–1.0 la incidencia se subestima entre −26% y −63% (cálculo propio). Y esta subestimación explica mecánicamente un hallazgo interno que el manuscrito no aborda: **12 de 45 redes presentan cobertura utilizada UC(tratamientos) > 1** (Huasco 1.32, San Carlos 1.35, Magallanes 1.29, Valparaíso 1.21, Osorno 1.21, Met Central 1.20, Met Cordillera 1.19, Chiloé 1.16, Temuco 1.07, La Serena 1.06, Met Oriente 1.06, Concepción 1.03), es decir, "más del 100% de cobertura". Una cobertura >100% es señal clásica de denominador (incidencia) demasiado bajo. El error de signo de la corrección va exactamente en esa dirección.

**Se exige:** (a) derivar y justificar formalmente la corrección para `E[Mortalidad/IMR]` (no para `E[IMR]`); (b) reportar σ²; (c) recalcular incidencia y todas las coberturas; (d) explicar los 12 casos de UC>1 y si desaparecen tras la corrección; (e) declarar explícitamente si el estimador buscado es la media o la mediana de la incidencia y usar la corrección coherente.

### M2. Distribución t de Student con df = 0.87 (df < 1): momentos indefinidos y validación por KS inválida
El Anexo 0 modela el error de la incidencia estimada con "Student's t con 0.87 grados de libertad, location 0.03, scale 6.19", validada con Kolmogorov–Smirnov (D = 0.051, p = 0.208). Múltiples problemas:

1. **df = 0.87 < 1 ⇒ la distribución no tiene media ni varianza finitas** (la media existe sólo si df>1; la varianza sólo si df>2). Es más pesada que una Cauchy. Un error de estimación sin esperanza finita es incoherente con un procedimiento que luego promedia/propaga esos errores para construir estimadores puntuales y "IC95%": la Ley de los Grandes Números no aplica y las medias de Monte Carlo no convergen. Reportar df a dos decimales (0.87) sugiere una precisión ilusoria y delata un ajuste por máxima verosimilitud sobreajustado a unos pocos puntos atípicos.
2. **KS con parámetros estimados de los mismos datos es anti-conservador.** Al estimar df, location y scale y luego testear el ajuste con los valores críticos estándar de KS, el p-valor está inflado (se requiere corrección de Lilliefors o bootstrap paramétrico). Un p = 0.208 así obtenido **no** demuestra buen ajuste.
3. **"Verificar" con un test no significativo confunde ausencia de evidencia con evidencia de ausencia.** No rechazar H0 no prueba que la t(0.87) sea el modelo correcto; sólo indica falta de potencia.
4. **KS es insensible en las colas**, y aquí toda la historia (df<1) es precisamente sobre las colas. Para validar colas pesadas correspondería Anderson–Darling, no KS. Además, D = 0.051 con p = 0.208 implica **n ≈ 435** (cálculo propio con la aproximación asintótica de KS): con ese n, KS tiene potencia razonable en el centro y pobre en las colas, reforzando (3)–(4).

**Se exige:** justificar por qué el error tendría df<1; mostrar el histograma/QQ y el ajuste; usar un test sensible a colas con corrección por parámetros estimados (Lilliefors/bootstrap); y demostrar que la propagación posterior no depende de una distribución con esperanza indefinida (o, si sólo se reportan medianas y percentiles empíricos, decirlo explícitamente y no llamar a los resultados "media" ni "IC").

### M3. La propagación de incertidumbre es incompleta y los "IC95%" están mal etiquetados
La Sección 2.7 solo propaga por Monte Carlo (1000 draws) la incertidumbre de **incidencia de CG y prevalencia de HP**. **No** se propaga:
- la variabilidad de conteo (Poisson) de **defunciones** y **hospitalizaciones**, que son numeradores pequeñísimos por celda (ver M5);
- la incertidumbre de los **parámetros del propio modelo IMR** (βsa, β0, σ²), usados como valores puntuales;
- la incertidumbre de la **extrapolación 2010–2014 por modelos mixtos** (M7);
- la incertidumbre de los **denominadores poblacionales FONASA** (también reconstruidos por modelos, ref. Lagos & Jofré);
- la incertidumbre de **HGmax/HGmin**, que son percentiles 1/99 estimados de datos ruidosos (M4);
- la extrapolación de UGE de clínicas privadas.

**Prueba interna (smoking gun):** el ancho relativo de los "IC" en la fila Total es UC ≈ 5.7%, EC ≈ 5.6%, pero **Q ≈ 2.3%** (Q = 0.43; "IC" 0.43–0.44). Un intervalo de ±0.005 sobre una Q agregada de razones de mortalidad, cuando las HMR de celda oscilan entre 0 y 3 con conteos de 0–2 muertes, **no es creíble**. La razón es que la incertidumbre de la HMR (que domina Q) simplemente **no se propagó**: el IC de Q refleja casi exclusivamente la incidencia que entra vía N. Como EC = Q·U/N, EC hereda el ancho de UC y Q apenas aporta varianza.

Además, los intervalos reportados son **percentiles 2.5/97.5 de una simulación**, es decir, intervalos de credibilidad/simulación condicionados a las distribuciones inyectadas, **no intervalos de confianza frecuentistas**. Etiquetarlos "95% CI" en abstract, texto y Tabla 4 es incorrecto y sobrevende la precisión.

**Se exige:** propagar (al menos) el error de conteo Poisson de defunciones y hospitalizaciones, la incertidumbre de los parámetros IMR, y la de HGmax/HGmin y de la extrapolación; re-etiquetar como "intervalos de simulación/credibilidad" o justificar la nomenclatura frecuentista; y explicar el IC implausiblemente angosto de Q.

### M4. La métrica de calidad Q está mal condicionada: censura sistemática de las peores celdas, cotas ancladas en ruido y valores degenerados
`Q = (HGmin − HG)/(HGmin − HGmax)` con HG = HMR = Deaths/Hosp, HGmax = percentil 1 de HMR y HGmin = percentil 99, capado a 1.

1. **El cap de HGmin en 1 con HMR observadas hasta 3.0 crea una masa puntual espuria en Q = 0.** Cuando HMR > 1 (= HGmin capado), el numerador `(1 − HMR)` es negativo y Q se trunca a 0. En el Anexo 4 esto ocurre en numerosísimas celdas (p.ej. HMR = 1.14, 1.25, 1.5, 2.0, 3.0 → Q = 0.0). Son precisamente las celdas de peor desempeño (rurales, ancianos) las que se colapsan a exactamente 0, sesgando Q y EC a la baja de forma **no aleatoria** justo en los grupos sobre los que descansa la conclusión de "brechas".
2. **HGmax = percentil 1 de razones con conteos minúsculos es una cota de referencia inestable.** Para varias franjas sexo–edad HGmax = 0.00 (p.ej. Mujer [80,120), Hombre/Mujer [40,50)), fijado por una única celda con 0 muertes. Eso vuelve el "máximo beneficio alcanzable" un HMR = 0 inalcanzable salvo en celdas de conteo cero; la Q de los grupos de mayor letalidad (ancianos) queda estructuralmente cerca de 0.
3. **Bordes comunes a todas las redes por sexo–edad**: HGmax/HGmin se estiman agrupando todas las celdas red×período de una franja sexo–edad; con denominadores de 1–3 hospitalizaciones, los percentiles 1 y 99 son puro ruido muestral, no "mejor/peor desempeño clínico".
4. **Celdas con N = 0 producen UC = EC = 1.0.** Ejemplos del Anexo 4: Arica Mujer [40,50) (N=0, H=3, T=1) → Q=1.0, UCT=1.0, ECT=1.0; San Felipe Mujer [40,50) (N=0) → ECT=1.0; La Serena Mujer [40,50) (N=0) → ECT=1.0; Los Andes Hombre [50,60) (N=0, H=6, T=6) → ECT=1.0. Reportar cobertura efectiva del 100% sobre una población en necesidad de **cero** es absurdo. Aunque la agregación ponderada por N anule estas celdas, aparecen en las tablas y, peor, sus tratamientos (T>0 con N=0) **sí** entran al numerador de la UC agregada (U_it/N_it) sesgándola al alza.

**Se exige:** redefinir Q con cotas robustas (p.ej. shrinkage/empirical Bayes de las HMR de celda, o bounds clínicos externos en vez de percentiles de conteos pequeños); manejar explícitamente HMR>1 sin truncar a 0 (la información de "peor que el peor" no es 0 calidad, es dato faltante o requiere otra escala); excluir o imputar celdas con N=0; y reportar cuántas celdas se truncaron a 0/1 y su peso.

### M5. Inferencia ecológica con conteos por celda de 0–2: razones inestables no reflejadas en los IC
El nivel de análisis es celda red×sexo×edad×período. El Anexo 4 muestra que la inmensa mayoría de celdas tienen N, D, H, T ∈ {0,1,2,3}. Las HMR (D/H) y las coberturas (T/N, H/N) construidas sobre estos conteos son extremadamente inestables: p.ej. San Antonio Hombre [50,60) D=3/H=1 → HMR=3.0; Limarí Mujer [50,60) D=2/H=1 → HMR=2.0; decenas de celdas con H=1–2. Un cambio de una sola muerte mueve la razón entre 0, 0.5, 1.0, 2.0.

El Monte Carlo declarado **no** captura esta variabilidad (solo incidencia/prevalencia), de modo que los IC de celda y agregados están dramáticamente subestimados (ver M3). Además, todo el estudio es ecológico y las conclusiones a menudo se redactan como si fueran individuales ("individuals who achieve the best outcome…", "the system's inability to translate diagnosis into health gains"), rozando la falacia ecológica.

**Se exige:** suavizamiento espacial/jerárquico (modelos Bayes multinivel, BYM/Poisson-gamma) para estabilizar razones con numeradores pequeños; reportar el número de celdas por conteo; y acotar explícitamente el alcance de la inferencia al nivel agregado.

### M6. Incoherencia de la cascada AC→UC→EC y doble definición de utilización (capada vs no capada)
1. **Escalas incompatibles en la cascada.** ACj=2 se reporta como razón capacidad/necesidad (p.ej. Arica 117.1; Met Central 429.3), mientras UC y EC son proporciones (<1). Una "cascada" AC = 11.710% → UC = 63% → EC = 24% mezcla peras con manzanas: AC no es una cota superior de la cobertura en la misma escala, sino endoscopias totales (de todas las indicaciones) sobre un denominador de sólo casos incidentes de CG. AC así definida no es interpretable como "cobertura disponible".
2. **La UC mostrada no es la U que alimenta EC.** A nivel de celda la UC se capa a 1 (p.ej. Valparaíso Hombre [40,50) T/N = 10/2 = 5 → UCT = 1.0), pero la UC de red se calcula como U_it/N_it **sin capar** (por eso hay UC = 1.20, 1.35). En cambio EC de red es el promedio ponderado de EC de celda con U capada. Resultado: para las redes de alta UC, **EC ≈ Q** y queda desconectada de la UC exhibida. Verificación propia (EC vs Q·UC): Met Central Q·UC = 0.804 pero EC = 0.62 (dif −0.18); San Carlos 0.634 vs 0.46 (−0.17); Osorno 0.665 vs 0.53 (−0.14); Chiloé 0.661 vs 0.54 (−0.12); Huasco 0.396 vs 0.28 (−0.12). La columna UC de la Tabla 4 no es coherente con la EC de la misma fila.

**Se exige:** homogeneizar las escalas de la cascada; usar una única definición de utilización (capada o no) consistente entre UC y EC; y aclarar por qué EC de red no equivale a Q·UC de red (¿covarianza celda a celda? cuantificarla).

### M7. Extrapolación 2010–2014 por modelos mixtos: un tercio de la serie es imputado, y las tendencias se afirman "significativas" sin test
Los datos FONASA existen sólo 2015–2024; 2010–2014 (dos de los períodos trienales, incluida gran parte de la línea base) se **imputan** con modelos mixtos, igual que las UGE privadas. Sin embargo, el manuscrito presenta tendencias 2010–2024 y afirma que "UCj=1 grew significantly", "EC decreased significantly", "coverage displayed significant disparities" — **sin un solo test de hipótesis, pendiente estimada, ni p-valor** (la Sección 2.7 sólo describe estadística descriptiva + MC). El uso reiterado de "significant/significantly" en abstract, resultados y discusión, junto a reportar IC pero concluir "increased significantly", es un uso indebido de terminología inferencial en un journal Q1.

**Por qué importa:** buena parte de la "tendencia temprana" puede ser artefacto del modelo de extrapolación, y su incertidumbre no se propaga (M3). Afirmar significancia sin prueba es rechazable de plano.

**Se exige:** o bien (a) eliminar toda mención de "significant/significantly" y hablar de cambios descriptivos, o (b) ajustar modelos de tendencia (p.ej. regresión de series, mixtos con término temporal) con IC/p reportados; y marcar visual y textualmente qué parte de la serie es observada vs imputada, propagando la incertidumbre de la imputación.

---

## Defectos menores

- **m1. Doble uso de la mortalidad.** Las defunciones de CG se usan para derivar la incidencia (denominador N, vía IMR) **y** para construir la HMR (Q). N y Q comparten la misma fuente de ruido (los conteos de muertes), induciendo correlación mecánica numerador–denominador en EC = Q·U/N que no se reconoce ni se propaga.
- **m2. Supuesto contradictorio de hospitalización.** Para la HMR se asume que "todos los casos diagnosticados se hospitalizan al menos una vez", pero luego se afirma que las hospitalizaciones subestiman la utilización en ~10% ("not all cases…are hospitalized"). Ambas cosas no pueden ser ciertas; afecta el denominador de la HMR.
- **m3. Prevalencia de HP muy antigua y de fuente única (1988–2020) aplicada como si la prevalencia de red igualara la regional**, con imputación de regiones faltantes por "promedio de regiones cercanas" sin cuantificar el error introducido.
- **m4. Discrepancia Total EC ≠ Q·UC** (0.378 vs 0.36 reportado): defendible por ponderación/capado, pero debe explicitarse; hoy no se explica.
- **m5. Sin corrección por comparaciones múltiples** en 45 redes × varias métricas × tendencias, pese a múltiples afirmaciones de "significant disparities".
- **m6. Errores de rotulación en Tabla 2:** "Maximum health gain (HGmax)" aparece dos veces (una debería ser HGmin); typo "Hospitalizactions". Menor, pero en la tabla que define las métricas centrales.
- **m7. Redondeo excesivo** en celdas (Q, UC, EC a 1–2 decimales) que, combinado con conteos de 1–2, transmite falsa precisión.
- **m8. Números de celda muestran EC*/UC* que invierten conclusiones** (ver M6/ataque): reportar ambos sin un criterio pre-especificado de cuál es el primario invita a *cherry-picking*.

---

## Clarificaciones exigidas

1. Valor de σ² del modelo IMR y derivación explícita de la corrección de sesgo con la IMR en el denominador (M1).
2. Justificación de df = 0.87; qué cantidad exactamente modela esa t (¿error de qué, en qué escala?), y si se usa en la propagación o sólo como diagnóstico (M2).
3. Definición precisa de los "95% CI": ¿percentiles de simulación o IC frecuentistas? ¿Qué fuentes de incertidumbre entran a la simulación y cuáles no? (M3).
4. Número (y peso poblacional) de celdas con N = 0, con HMR > 1 truncadas a Q = 0, y con UC de celda capada a 1 (M4, M6).
5. ¿Por qué 12/45 redes tienen UC > 1? ¿Persiste tras corregir M1? (M1, M6).
6. Prueba formal (modelo, coeficiente, IC, p) detrás de cada afirmación de "significant/significantly", o su eliminación (M7).
7. Qué períodos son observados y cuáles imputados por modelos mixtos, y cómo se propaga la incertidumbre de la imputación (M7).
8. Definición operacional de "Casos Fonasa CG" (Anexo 2) vs N incidente 40+ usado en la Tabla 4, y por qué difieren.

---

## Ataque del revisor hostil

"Los autores construyen toda la conclusión — una caída de 50 puntos entre utilización (88%) y cobertura efectiva (36%) — sobre una métrica de calidad Q que: (i) se ancla en percentiles 1/99 de razones de mortalidad calculadas con 1–2 muertes por celda; (ii) trunca a **cero** exactamente las celdas de peor desempeño (HMR>1, capando HGmin=1 pese a observar HMR hasta 3.0); y (iii) asigna cobertura efectiva del **100%** a estratos con **cero** casos en necesidad. El resultado central es, en gran medida, un artefacto de la construcción de la métrica, no un hallazgo epidemiológico.

Peor aún, la incidencia — el denominador de todo — se estima con una corrección de sesgo lognormal **aplicada en el sentido equivocado** (la IMR va en el denominador; el `+σ²/2` debía ser `−σ²/2`), lo que subestima la incidencia y produce 12 redes con cobertura >100%, una imposibilidad lógica que el manuscrito no comenta. La incertidumbre de ese modelo se describe con una t de **0.87 grados de libertad** — una distribución sin media ni varianza finitas — 'validada' con un Kolmogorov–Smirnov que es inválido con parámetros estimados, insensible a las colas que son justamente el problema, y cuyo p = 0.208 sólo prueba falta de potencia.

Los 'IC95%' no son intervalos de confianza: son percentiles de una simulación que propaga dos fuentes de incertidumbre e ignora al menos cinco (conteos Poisson de muertes y hospitalizaciones, parámetros del modelo IMR, percentiles HGmax/HGmin, extrapolación 2010–2014 y denominadores reconstruidos). La prueba está en su propia Tabla 4: un IC de Q de 0.43–0.44 sobre razones que fluctúan de 0 a 3. Y aun así el texto afirma cambios 'significativos' sin una sola prueba de hipótesis. Cuando el análisis de sensibilidad cambia la utilización de tratamientos a hospitalizaciones, cuatro redes pasan de EC = 0 a EC = 0.25–0.42: el resultado no es robusto ni a su propia definición de utilización.

Este manuscrito no está listo: sus intervalos no son intervalos, su calidad no mide calidad, y su incidencia está sesgada por un error de álgebra."

---

## Severidad global

**RECHAZAR** (en su forma actual; reconsiderable sólo con re-análisis completo = *major revision* de facto que reescribe Métodos y Resultados).

Justificación: hay **dos errores estadísticos de fondo** que invalidan los números centrales — la corrección de sesgo lognormal en sentido equivocado (M1) y una métrica de calidad mal condicionada con censura sistemática de las peores celdas (M4) — más una propagación de incertidumbre incompleta con intervalos mal etiquetados (M3) y afirmaciones de significancia sin pruebas (M7). No son ajustes cosméticos: exigen redefinir Q, recalcular incidencia, reconstruir todos los IC y re-derivar los resultados de la Tabla 4 y los Anexos 2–6. Hasta que eso ocurra, las conclusiones cuantitativas (88% vs 36%, gradientes territoriales, tendencias) no son confiables.
