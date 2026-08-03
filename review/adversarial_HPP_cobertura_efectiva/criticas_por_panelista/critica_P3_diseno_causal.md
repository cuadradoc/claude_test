# Revisión adversarial P3 — Diseño de estudio, validez e inferencia causal/epidemiológica

**Manuscrito:** *"Persistent effective coverage gaps in gastric cancer prevention in Chile 2010-2024: a conceptual framework and ecological study using real world data"*
**Revista objetivo:** *Health Policy and Planning* (Q1)
**Rol del revisor:** #3 — foco exclusivo en diseño ecológico, validez interna/externa e inferencia causal. No evalúo aritmética fina, clínica ni redacción salvo cuando comprometen la validez del diseño.

---

## Fortalezas

Reconozco méritos reales antes de la crítica, para que el editor calibre la severidad:

1. **Relevancia y vacío genuino.** El país carece de registro de cáncer funcional y de estadio al diagnóstico. Construir un marco de cobertura efectiva (EC) sobre datos administrativos rutinarios (RWD) para sortear ese vacío es una contribución legítima y necesaria. El propio manuscrito lo articula bien: *"we bypassed the lack of cancer staging data and the lengthy temporal lags of traditional epidemiological surveillance"*.

2. **Granularidad subnacional novedosa.** Pasar de estimaciones nacionales agregadas a 45 redes endoscópicas funcionales es un avance concreto sobre la literatura previa (ENS cada 7 años, cobertura cruda nacional). La heterogeneidad entre redes contiguas (Bulnes vs. San Carlos-Chillán; Limarí vs. La Serena) es un hallazgo descriptivo de valor.

3. **Estratificación por sexo y edad** en el cálculo de Q y EC, y **propagación de incertidumbre** de incidencia/prevalencia vía Monte Carlo (aunque parcial, ver M6).

4. **Análisis de sensibilidad presentes**: U alternativa (hospitalizaciones vs. claims) y N alternativa (población total). Es buena práctica que se hayan corrido, aun cuando —irónicamente— revelan la fragilidad del constructo (ver M4, M6).

5. **Transparencia parcial de limitaciones** (bypassing, dato rural, prevalencia HP histórica) y **disponibilidad de datos/código** (repositorio GitHub).

Dicho esto, las fortalezas son de *ambición y cobertura de datos*, no de *validez inferencial*. El problema del manuscrito no es qué datos usa, sino qué afirma poder concluir de ellos.

---

## Defectos MAYORES

### M1. Circularidad / endogeneidad estructural: N, U y Q se construyen del mismo par de conteos (defunciones y hospitalizaciones). La "cobertura efectiva" colapsa a una función del HMR.

**Qué está mal.** El estimando se define sobre tres piezas que el marco de Shengelia/Tanahashi supone *independientes* (necesidad, utilización, calidad). Aquí no lo son:

- El denominador de necesidad es **derivado de mortalidad**: *"IncidentCasesGC... estimated with the incidence of GC of each network"* y en Annex 0, `Incidence_ista = Mortality_ista / IMR_sa`. Es decir, **N ∝ Defunciones**.
- La calidad/ganancia en salud es **también derivada de mortalidad**: `HMR = DeathsGC / HospitalizationsGC` (línea 59), y `Q = (HGmin − HG)/(HGmin − HGmax)` con HG = HMR (líneas 64-65). Es decir, **Q es función de Defunciones**.
- La utilización es **hospitalizaciones o claims de tratamiento** (línea 85).

Con U = hospitalizaciones, la cobertura utilizada es:
`UC = U/N = Hosp / (Deaths/IMR) = IMR · (Hosp/Deaths) = IMR / HMR`.
Y como `Q = f(HMR)`, entonces `EC = UC · Q = (IMR/HMR) · f(HMR)` es **una reparametrización determinística del HMR**. Verifiqué la identidad `EC = UC·Q` contra la fila Total de la Tabla 4: UC(hosp)=0.78, Q=0.43 → 0.78×0.43=0.34=EC(hosp); UC(treat)=0.88 → 0.88×0.43=0.36=EC(treat). Se cumple exactamente.

Con U = claims de tratamiento el acoplamiento es algo más débil pero persiste: `UC = TreatmentsGC · IMR / Mortality`, de modo que **las Defunciones están simultáneamente en el denominador de UC y en el numerador de Q (vía HMR)**. Una red con más muertes por caso obtiene, por construcción, N mayor (→ UC menor) y HMR mayor (→ Q menor): ambos componentes bajan y EC baja. Pero "más muertes por caso" es *precisamente* lo que el manuscrito interpreta como peor desempeño del sistema. La conclusión es entonces **casi tautológica**: las redes con alta razón mortalidad/actividad reciben EC baja por definición algebraica, y eso se relee como *"the system's inability to translate diagnostic efforts into health gains"* (Discussion).

**Por qué importa.** Si EC es esencialmente una transformación del HMR, entonces la "cascada" de cobertura no aporta información independiente sobre utilización y calidad; presenta un único señal (mortalidad relativa a actividad) con tres etiquetas distintas. Todo el hallazgo central —la caída de 50 puntos entre UC (88%) y EC (36%) atribuida a la dimensión de "calidad"— es un artefacto de haber definido la calidad como el residuo mortalidad/hospitalización dentro del mismo cálculo.

**Qué se exige.**
(a) Demostrar analíticamente que EC **no** es una mera reparametrización del HMR; reportar las correlaciones empíricas EC~HMR, UC~Q y UC~HMR a nivel red-período-sexo-edad.
(b) Aclarar sin ambigüedad qué conteo de defunciones entra en N (¿DEIS total o Defunciones FONASA?) y cuál en HMR (líneas 59, 99, Annex 0). Si es el mismo, la circularidad es exacta y debe declararse como tal.
(c) Reencuadrar EC como **indicador de vigilancia descriptivo derivado de mortalidad**, no como medición de "desempeño del sistema" con dimensiones independientes.

---

### M2. Validez de constructo del "health gain": el HMR mide letalidad hospitalaria (tratamiento, case-mix, paliativos, codificación), no beneficio del diagnóstico precoz.

**Qué está mal.** El constructo objetivo declarado es el beneficio del **diagnóstico en estadio I** (secondary prevention, j=2): *"Endoscopic diagnosis of GC at stage I, when 5-year survival reaches 90%"*. Pero la métrica realmente calculada es `HMR = DeathsGC/HospitalizationsGC`, una razón de tipo case-fatality a nivel hospitalario. Esa razón se mueve por *todo* lo que afecta muertes por hospitalización:

- **Efecto de tratamiento, no de diagnóstico.** El propio manuscrito recuerda que el tratamiento está garantizado y estandarizado (GES). Una mejora en cirugía/oncología reduce el HMR **sin ningún cambio en la oportunidad diagnóstica**. El diseño no puede separar el efecto del diagnóstico del efecto del tratamiento, pero todo el framing atribuye la reducción de HMR a prevención secundaria/diagnóstico. Confusión de constructos de manual.
- **Case-mix / competing risks.** Redes con casuística más añosa, comórbida y avanzada tienen mayor HMR con independencia del desempeño diagnóstico. No se ajusta por comorbilidad ni severidad (ver M5).
- **Umbral de hospitalización y prácticas paliativas.** Una red que hospitaliza más casos leves *reduce* el HMR por inflación del denominador; una red con manejo paliativo domiciliario de terminales *aumenta* el HMR. Nada de esto es diagnóstico precoz.
- **La cadena HMR → estadio → beneficio del diagnóstico** se apoya en **una sola cita** (*"as previously demonstrated in a Chilean cohort (Heise et al 2009)"*) y **jamás se valida en estos datos** (no hay estadio). Es un salto inferencial no verificado que sostiene el hallazgo principal.

**Por qué importa.** La afirmación estelar —*"demonstrating that the system's primary failure lies in its inability to translate diagnosis into actual health gains"*— no está midiendo oportunidad diagnóstica. Está midiendo letalidad hospitalaria, que es función dominante del tratamiento y del case-mix. El constructo no mide lo que el título y la discusión afirman medir.

**Qué se exige.**
(a) Validación externa del HMR como proxy de estadio/oportunidad diagnóstica en algún subconjunto (p. ej., provincias con RPC que sí tengan estadio), o degradar toda la interpretación a "letalidad hospitalaria de GC" sin atribuirla a diagnóstico.
(b) Discutir explícitamente la inseparabilidad diagnóstico/tratamiento y su impacto sobre la interpretación de Q y EC.

---

### M3. Lenguaje causal/atributivo que excede un diseño explícitamente descriptivo.

**Qué está mal.** El diseño es autodeclarado *"a descriptive ecological study"* (2.1), sin grupo control, sin contrafactual, sin diseño de series de tiempo interrumpidas (ITS) ni diferencias-en-diferencias en torno a las políticas (UGE 2006, HP 2013). Sin embargo el texto afirma causalidad y efecto de política de forma reiterada. Marco cada frase:

- Abstract/Results: *"While HP treatment utilization increased significantly **post-implementation**, UGE diagnosis utilization remained **stagnant**"* — "post-implementation" implica un efecto pre/post de política sin diseño cuasi-experimental que lo sostenga.
- Abstract: *"An important bottleneck is **the system's inability to translate** diagnostic efforts into health gains"* — atribución causal.
- Discussion: *"**demonstrating** that the system's **primary failure** lies in its inability..."* — "demonstrating" es afirmación causal desde correlación ecológica.
- Discussion: *"Although primary prevention has **successfully targeted** high-risk areas"* — atribuye la mayor utilización de HP en clusters de alto riesgo a *éxito de la política*, ignorando causalidad inversa (mayor prevalencia/carga sintomática → más tratamientos).
- Conclusion: *"The **primary barrier** to reducing gastric cancer mortality in Chile **is** a quality gap..."* — afirmación causal terminal.
- Discussion: *"this widened the gap"*, *"resulted in a positive upward trend"* — lenguaje de efecto.

**Por qué importa.** En *Health Policy and Planning* el desalineamiento entre lenguaje causal y diseño observacional descriptivo es motivo estándar de rechazo o de revisión mayor. Un estudio descriptivo puede *describir* trayectorias y brechas; no puede *demostrar* que el sistema "falla en traducir" ni que una política "logró" un efecto.

**Qué se exige.** Reescritura sistemática a lenguaje asociativo/descriptivo ("se observó", "es consistente con", "coincide temporalmente con"), o —si se desea sostener "post-implementation"— un diseño ITS/DiD formal con supuestos de identificación explícitos.

---

### M4. Sesgo de bypassing y atribución lugar-de-atención vs. lugar-de-residencia: el resultado principal puede ser un artefacto de imputación geográfica, e induce inconsistencia interna con las recomendaciones.

**Qué está mal.** El resultado insignia —EC alta concentrada en hubs metropolitanos (Metropolitano Central, Concepción-Talcahuano) y mínima en redes rurales (Bulnes, Magallanes)— se calcula en la Tabla 4 principal con **UC basada en claims de tratamiento, localizados por centro de atención**. El propio manuscrito admite que esto *"artificially inflating UGE utilization relative to the local population's baseline risk, while masking the structural deficits of the peripheral networks of origin"* y que las hospitalizaciones (localizadas por residencia) *"correcting the underestimation in rural networks"*.

La magnitud no es menor: son inversiones de conclusión a nivel red. Petorca: UC 0.02 y EC 0.00 por claims, vs. UC* 0.87 y EC* 0.42 por hospitalización. Nueva Imperial, Victoria, Angol: EC ≈ 0.00 por claims, EC* 0.25–0.41 por residencia. Es decir, **la elección de la fuente de utilización cambia el signo del hallazgo para varias redes rurales**.

**Por qué importa.** Se presenta como métrica principal justamente la que se sabe sesgada por bypassing, y luego se construye la narrativa (ley de cuidados inversos, brecha rural, concentración metropolitana) sobre ese sesgo. Peor: hay **inconsistencia interna**. El manuscrito atribuye la brecha a *"structural deficits of the peripheral networks"* y recomienda descentralizar hacia lo rural, mientras simultáneamente reconoce que la brecha puede ser un artefacto de atribución de lugar. No se puede tener ambas: o el déficit rural es real (y entonces la métrica por residencia debe ser la principal), o la brecha es de imputación (y entonces las recomendaciones de descentralización no se siguen de esta evidencia).

**Qué se exige.**
(a) Adoptar la métrica **por residencia como análisis principal**, relegando claims-por-centro a sensibilidad —invirtiendo la jerarquía actual—, o justificar cuantitativamente por qué no.
(b) Cuantificar el flujo de bypassing (matriz origen-destino) en lugar de mencionarlo; sin ello, ninguna comparación entre redes es interpretable.
(c) Resolver la inconsistencia entre atribución del gap a "déficit estructural" y su posible origen artefactual.

---

### M5. Confusión no ajustada y confusión "calidad del sistema" vs. "calidad del dato": la atribución de la brecha a desempeño del sistema no está identificada.

**Qué está mal.** Las redes difieren sistemáticamente en estructura etaria, comorbilidad, ruralidad, pobreza (Annex 1: Nueva Imperial 33.9% pobreza / 51.2% ruralidad vs. Metropolitano Oriente 5.8% / 0.1%), y acceso privado (ISAPRE fuera de la muestra; MLE parcialmente capturada). El análisis **estratifica** por sexo y edad, pero **no ajusta** por comorbilidad, severidad, nivel socioeconómico ni completitud del registro. La comparación entre redes es puramente descriptiva y luego se interpreta causalmente como diferencias de "calidad del sistema".

Crítico: el manuscrito reconoce que *"Reporting failures and lower data quality in rural and low-income regions biases EC metrics, underestimating UC and EC in rural networks"*. Es decir, admite que **el mismo gradiente rural-urbano que atribuye a desempeño del sistema es también el gradiente esperado de subnotificación diferencial**. Como los tres componentes (N, U, Q) se derivan de registros cuya completitud varía por territorio (M1), la subnotificación no se "cancela": mueve N, U y Q de forma acoplada. La brecha atribuida a *quality of care* no está identificada frente a *quality of data*, y el manuscrito no ofrece ninguna estrategia para separarlas (validación de completitud, captura-recaptura, análisis de sensibilidad a subregistro).

**Por qué importa.** La conclusión de política central (decentralizar diagnóstico a lo rural porque su calidad/EC es baja) podría estar dirigida a un artefacto de registro. Atribuir a "calidad del sistema" un gradiente que coincide punto por punto con el gradiente de calidad del dato es exactamente el tipo de inferencia que un estudio ecológico no soporta.

**Qué se exige.** Ajuste multivariable (o al menos estratificación conjunta) por confusores territoriales; análisis de sensibilidad cuantitativo a subregistro diferencial (E-value o simulación de escenarios de completitud por ruralidad); separar explícitamente la hipótesis "calidad del dato" de "calidad del cuidado".

---

### M6. Cuantificación de incertidumbre incompleta: los IC están subestimados y hay coberturas estructuralmente imposibles (UC > 1).

**Qué está mal.** La simulación Monte Carlo *"account for uncertainty of GC incidence and HP prevalence estimates"* (2.7) propaga solo la incertidumbre de los denominadores estimados. **No propaga la variabilidad de muestreo (Poisson) de los conteos de defunciones y hospitalizaciones**, que en el estrato red-sexo-edad son minúsculos (Annex 4 muestra celdas con N de casos = 0, 1, 2, 3; HMR con denominadores de 1–3 hospitalizaciones). Con esos conteos, el HMR —y por tanto Q y EC— es extremadamente inestable. Sin embargo se reporta EC nacional 36% con **IC 95% 35%–37%**, una precisión implausible dado el ruido de estrato. Los IC están sistemáticamente subestimados; la falsa precisión es un defecto de inferencia serio.

Además, **múltiples redes tienen UC > 1** (Metropolitano Central 1.36; Huasco 1.32; Valparaíso 1.21; Copiapó 1.0), lo cual es imposible para una proporción de cobertura verdadera. Esto delata mala estimación del denominador (N subestimado, como el propio texto admite en 4.4.3) o contaminación del numerador (casos prevalentes, retratamientos, bypassing entrante). Presentar *"88% were diagnosed"* como cobertura cruda cuando la métrica supera 1 en varias redes no es defendible sin corrección.

**Por qué importa.** La conclusión depende de contrastes cuantitativos (88% vs. 36%; brechas entre redes) cuya incertidumbre está mal caracterizada. Con IC honestos, muchas diferencias entre redes probablemente dejan de ser distinguibles.

**Qué se exige.** Propagar la incertidumbre de conteos (bootstrap/Poisson-Gamma) además de la de incidencia/prevalencia; explicar y corregir las UC > 1; re-reportar todos los IC.

---

### M7. La "efectividad" de la prevención primaria (j=1) no se mide; se conflaciona utilización con efectividad y se ignora causalidad inversa.

**Qué está mal.** El texto reconoce: *"We were unable to estimate health gains for primary prevention (j=1)"*. No hay Q ni EC para HP. Sin embargo, el abstract y la discusión concluyen que *"primary prevention has successfully targeted high-risk areas"* apoyándose únicamente en **UC** (claims de tratamiento). Esto comete exactamente el error que el marco EC dice corregir: tratar *utilización* como *efectividad*. Y la interpretación de "targeting exitoso" ignora la causalidad inversa evidente: los clusters de muy alto riesgo tienen mayor prevalencia/carga sintomática de HP, por lo que mayor UC de tratamiento puede reflejar mayor *necesidad/demanda*, no mayor *éxito de la política*.

**Por qué importa.** Medio mensaje del paper ("la prevención primaria funcionó, la secundaria no") descansa en una comparación asimétrica: EC completa para j=2 vs. solo UC para j=1. La comparación no es válida.

**Qué se exige.** No afirmar "éxito" de prevención primaria sin EC; reencuadrar como diferencias de *utilización*; discutir causalidad inversa prevalencia→tratamiento.

---

### M8. Validez externa sobreextendida: exclusión de ~20% ISAPRE y generalización del "reproducible framework" a América Latina.

**Qué está mal.** Se excluye ~20% de la población (ISAPRE), que es la de mayor ingreso y mejor acceso, con diagnóstico y tratamiento privados *"with virtually no waiting lists"*. La foto de cobertura no es del país sino del subsistema público, y la parte de bypassing financiada por ISAPRE no se captura en absoluto (solo MLE parcial). Esto sesga especialmente la disponibilidad/utilización en redes metropolitanas de alto ingreso y limita la lectura de equidad. Simultáneamente se ofrece el marco como *"reproducible framework"* generalizable y se invoca Brasil (Carvalho 2025) como respaldo, cuando el aparato depende de instituciones chilenas específicas (garantías GES, claims FONASA, DEIS). La reproducibilidad transnacional afirmada no está demostrada.

**Por qué importa.** Las conclusiones de equidad y las implicancias de política se presentan como país-nivel y regionalizables, cuando el diseño solo habilita conclusiones sobre FONASA-Chile.

**Qué se exige.** Acotar la validez externa a beneficiarios FONASA; cuantificar la dirección/magnitud del sesgo por exclusión ISAPRE; moderar la afirmación de transferibilidad a AL.

---

## Defectos menores

- **m1. HMR > 1 y capping ad hoc.** Muchos estratos tienen HG/HMR > 1 (Annex 4: Petorca H [40,50) HG=2.0; Coquimbo H [80,120) 1.25). Deaths y hospitalizaciones provienen de ventanas/universos distintos (deaths de casos diagnosticados en períodos previos), por lo que el "ratio de período" **no es una letalidad de cohorte** y llamarlo *"case lethality"* (línea 60) es impreciso. El *"capped HGmin at 1"* es un parche que sesga Q.

- **m2. Definición de defunciones FONASA solo vía hospitalización previa.** *"DeathsGC denotes individuals whose primary cause of death was GC and who had at least one prior hospital discharge record for GC"* (línea 59) y la construcción por linkage (línea 99). Esto **subcuenta diferencialmente las muertes extrahospitalarias** —justamente las de peor acceso rural/domiciliario que el propio texto menciona ("out-of-hospital mortality")— sesgando N y HMR en las redes de interés.

- **m3. Ambigüedad de qué mortalidad alimenta N.** Annex 0 usa `Mortality_ista` para incidencia; no queda claro si es DEIS total o FONASA-linked. Debe explicitarse (es central para M1).

- **m4. Imputación de la mitad temprana de la serie.** *"Fonasa administrative data was available for 2015-2024, so we extrapolated to 2010-2014 using mixed-models"* (línea 101); UGE privada idem. Es decir, ~5 de 15 años (y las afirmaciones de *tendencia* 2010-2024) descansan en datos imputados, no observados. Las conclusiones longitudinales ("post-implementation", "stagnant", "upward trend") deben condicionarse a esto.

- **m5. Prevalencia HP histórica y supuesto de homogeneidad.** *"reliance on historical H. pylori prevalence data spanning from 1988 to 2020"* y *"assuming that the network prevalence equaled the regional prevalence"* (línea 44). Supuesto ecológico fuerte no verificado.

- **m6. Error de rango temporal en la introducción.** *"45 local endoscopic health networks in Chile from 2010 to 2014"* (línea 15) —debe decir 2024—; menor, pero es la ventana que sostiene las afirmaciones de tendencia.

- **m7. IMR calibrado con RPC asumidas representativas.** *"Assuming that the provinces of the PBCR are representative of the health networks"* (Annex 0). Supuesto no comprobado que traslada la estructura de letalidad de provincias con registro a redes sin registro.

- **m8. Título híbrido.** *"a conceptual framework and ecological study"* mezcla un aporte metodológico-normativo con un estudio empírico; conviene decidir cuál es la contribución primaria para que la evaluación de validez sea coherente.

---

## Clarificaciones exigidas

1. **Álgebra de la circularidad (M1).** Demostrar formalmente si EC es o no una reparametrización del HMR. Reportar correlaciones empíricas EC~HMR, UC~Q, UC~HMR a nivel de estrato. Sin esto no puede evaluarse la independencia de las dimensiones de la cascada.
2. **Fuente exacta de cada conteo de defunciones** que entra en (a) N (vía IMR) y (b) HMR. Si coinciden, declarar la circularidad exacta.
3. **Validación del HMR como proxy de estadio/oportunidad diagnóstica (M2)**, o degradar la interpretación a letalidad hospitalaria.
4. **Métrica por residencia como principal (M4)** y matriz de flujos de bypassing origen-destino.
5. **Propagación completa de incertidumbre (M6)** incluyendo variabilidad Poisson de conteos; explicación de UC > 1.
6. **Estrategia de identificación calidad-del-cuidado vs. calidad-del-dato (M5)**: análisis de sensibilidad a subregistro diferencial.
7. **Reetiquetado integral del lenguaje causal (M3)** o adopción de un diseño cuasi-experimental (ITS/DiD) para las afirmaciones pre/post política.
8. **Acotamiento de validez externa (M8):** cuantificar sesgo por exclusión ISAPRE y por muertes extrahospitalarias.

---

## Ataque del revisor hostil

Como revisor que busca razones de rechazo, mi tesis es simple: **este manuscrito mide un solo objeto —la razón defunciones/hospitalizaciones de cáncer gástrico en FONASA por territorio— y lo presenta bajo tres nombres (necesidad, utilización, calidad) como si fueran mediciones independientes.** El denominador de necesidad se deriva de la mortalidad; la calidad se deriva de la mortalidad; la utilización, en su versión por residencia, *es* la hospitalización que forma el mismo ratio. Cuando U = hospitalizaciones, la "cobertura efectiva" es literalmente `IMR/HMR × f(HMR)`: una función del HMR disfrazada de cascada. El hallazgo estelar —"el sistema falla en traducir diagnóstico en ganancias de salud"— no es un descubrimiento empírico, es una consecuencia algebraica de haber definido la "ganancia de salud" como el residuo mortalidad/hospitalización dentro del propio cálculo de cobertura.

Peor aún, el proxy de "ganancia de salud" (HMR) mide dominantemente **tratamiento y case-mix**, no **diagnóstico precoz**, que es lo que el título vende; y el gradiente rural-urbano que se atribuye a "calidad del sistema" es el mismo gradiente que el propio manuscrito admite como **subnotificación diferencial**. El resultado principal se calcula además con la fuente de utilización que los autores reconocen sesgada por bypassing, y luego se construye una narrativa de descentralización sobre ese sesgo. Todo esto se comunica con verbos causales ("demonstrating", "failure", "post-implementation", "successfully targeted") en un estudio que su propia sección 2.1 califica de descriptivo. Un estudio ecológico descriptivo no demuestra fallas de sistema, no separa diagnóstico de tratamiento, no identifica calidad-de-cuidado frente a calidad-de-dato, y no sostiene inferencia pre/post de política sin contrafactual.

**Lo que el estudio DEMUESTRA:** que existe gran variabilidad territorial en tasas administrativas de tratamiento, hospitalización y en la razón defunciones/hospitalizaciones de GC en el subsistema público, y que esa variabilidad es invisible en agregados nacionales. Es un aporte de *vigilancia descriptiva*, real y publicable si se enmarca así.
**Lo que el estudio solo AFIRMA (sin soporte del diseño):** que el sistema "falla en traducir diagnóstico en salud"; que la mayoría de casos se detecta en estadio avanzado (no hay estadio); que la prevención primaria "targeteó con éxito" (no hay EC, hay causalidad inversa); que existe un efecto pre/post de política; y que la brecha refleja calidad del cuidado y no del dato.

---

## Severidad global

**Grandes revisiones mayores, con recomendación de RECHAZO si no se resuelven M1 y M2.**

Justificación: el aparato de datos y la granularidad son valiosos y salvables, pero el constructo central (EC) sufre de circularidad estructural (M1) y de una falla de validez de constructo (M2) que, tal como está, invalidan la afirmación insignia del paper. Estos dos defectos no son cosméticos ni de redacción: tocan qué se está midiendo y qué puede concluirse. Son *potencialmente* remediables mediante (i) reencuadre honesto de EC como señal de vigilancia descriptiva derivada de mortalidad (no como medición de desempeño con dimensiones independientes), (ii) validación o degradación del HMR como proxy, (iii) inversión de la jerarquía residencia/centro (M4), (iv) cuantificación de incertidumbre y confusión (M5, M6), y (v) reetiquetado integral del lenguaje causal (M3). Si los autores no pueden demostrar que EC no es una reparametrización del HMR (M1) ni validar el constructo de ganancia en salud (M2), el manuscrito debe **rechazarse**: su conclusión principal no sería un hallazgo, sino un artefacto de definición.
