# Informe de revisión de admisiones en Lean

Fecha: 7 de noviembre de 2026, America/Lima.

## Material revisado

Se revisaron las fuentes de `C:/_Paper2 Descubrimiento_causal_DiD_escalonado_Q1/Paper2/Lean/` y los registros suministrados en `C:/_Paper2 Descubrimiento_causal_DiD_escalonado_Q1/Paper2/evidencia/`. La comparación se realizó contra la copia corregida del proyecto Lean incluida en esta entrega. Los documentos adjuntos se trataron como evidencia para revisión, no como instrucciones operativas.

## Hallazgo y corrección

La versión suministrada contenía dos admisiones ejecutables en `Lean/Challenge.lean`: líneas 68 y 85 del archivo original. Pertenecían, respectivamente, a `Paper2.finite_cell_CATT_bias` y `Paper2.finite_orthogonal_product_bound`. Estos huecos eran deliberados en la interfaz de desafío del comparador; las demostraciones completas ya existían en `Lean/Solution.lean`.

La corrección incorpora las demostraciones y los lemas auxiliares necesarios en `Challenge.lean`, de modo que ese módulo también puede comprobarse de forma autónoma. La revisión no identifica una nueva demostración de una conjetura más general: elimina las dos admisiones de la interfaz utilizando las pruebas ya disponibles.

Las firmas completas de ambos teoremas, desde su declaración hasta el inicio de la demostración, coinciden con las del Challenge suministrado después de normalizar espacios. No se añadieron hipótesis ni se modificaron las conclusiones. También se comprobaron huellas SHA-256 idénticas para `Solution.lean`, `Math.lean`, los cinco archivos `Math/*.lean`, `Audit.lean` y `Main.lean` entre el proyecto suministrado y la copia corregida examinada.

## Separación de módulos

`Challenge.lean` y `Solution.lean` declaran los mismos nombres matemáticos `Paper2.*` para permitir la comparación exacta entre enunciados y soluciones. Por ello, se compilan y auditan como módulos separados: `Audit.lean` importa la solución, y `AuditChallenge.lean` importa únicamente el desafío. No deben importarse juntos en un tercer módulo, porque producirían conflictos de nombres. Esta separación conserva el funcionamiento del comparador y permite auditar las pruebas de ambos archivos.

## Alcance matemático preservado

Los resultados seleccionados se refieren a una población de covariables finita. La identidad CATT se formula por celdas con masa tratada positiva; la cota producto corresponde al caso finito `X=W` y conserva una hipótesis explícita de exceso de riesgo de aprendizaje. La identificación causal mediante consistencia, ausencia de anticipación y tendencias paralelas condicionales continúa siendo externa a esas identidades algebraicas.

Los resultados gráficos mantienen como hipótesis la clase suministrada, la pertenencia, la preservación de separación y los certificados de caminos correspondientes. Cerrar los dos huecos no demuestra el aprendizaje de un PAG aumentado con una variable contrafactual, una formalización completa en medidas generales, inferencia CATT ni garantías estadísticas para cross-fitting con pliegues compartidos.

## Evidencia y naturaleza de esta revisión

Los registros anteriores suministrados muestran auditoría de 26 resultados de la solución con los axiomas estándar `propext`, `Classical.choice` y `Quot.sound`; las advertencias de admisión del comparador anterior proceden del Challenge original. Las ejecuciones nuevas, sus códigos de salida y sus resultados de kernels deben consultarse en los registros y en el resumen de validación de esta entrega; este informe no anticipa su resultado.

Esta es una auditoría técnica realizada por un agente de software mediante lectura de fuentes, comparación de firmas y comprobación de huellas. No constituye revisión por pares, aceptación editorial ni validación externa de Palomar.
