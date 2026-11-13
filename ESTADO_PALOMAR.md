# Estado de preparación para Palomar

Actualizado el 8 de noviembre de 2026, America/Lima.

El proyecto está preparado para repetir sus comprobaciones y publicar una
instantánea revisable. No se ha creado un repositorio público, enviado una
solicitud ni autorizado el registro de Paper2 desde este paquete.

| Elemento | Estado y alcance |
|---|---|
| Pruebas Lean | Once fuentes propias sin admisiones; dos huecos del Challenge original cerrados sin cambiar firmas ni hipótesis. |
| Evidencia local | Compilación, auditorías separadas y comparación con Lean default/NanoDa registradas en `evidence/`; Windows explícitamente sin aislamiento. |
| Revisión técnica | Revisión de firmas, huellas y límites por agente, descrita en `INFORME_REVISION_SORRY.md`; no revisión por pares. |
| Metadatos | `formalization.yaml` v0.4 con autor humano, MIT, fuentes, métodos, estado de pruebas, correspondencia y limitaciones. |
| CI propia | `.github/workflows/verify.yml`, configurada para ejecución manual; no se ha ejecutado remotamente. |
| Preflight oficial | `.github/workflows/palomar-preflight.yml`, configurado con `mode: full`; no se ha ejecutado remotamente. |
| Palomar | Verificación del servidor, renderizado, revisión editorial y registro pendientes. |

## Publicar y comprobar la instantánea

Utilice el contenido de esta carpeta como raíz del repositorio público
`Paper2_Causal_Discovery_DID`. Esa estructura coloca la licencia MIT y `.github/workflows/` en su lugar
correcto. El ZIP completo de datos y preprint puede conservarse como material
de replicación separado; no hace falta incorporarlo como dependencia Lean.

Después de publicar y hacer commit de todos los archivos previstos, ejecute
manualmente `Lean checks (ordinary CI)` y después `Palomar full mechanical
preflight` desde GitHub Actions. El segundo usa el commit del evento de ejecución
(`github.sha`) y requiere que el operador confirme su relación de autor o
mantenedor responsable. No se enviará una solicitud de registro al ejecutarlo.

Revise el artefacto `mechanical-report-preflight001`: debe informar
`status: pass`. Un resultado parcial, omitido, fallido o meramente verde por
otra tarea no sustituye ese informe. Si cambia las fuentes o metadatos, genere
y compruebe un nuevo commit. El SHA de esa instantánea debe copiarse completo
(40 caracteres) para la eventual solicitud.

## Workflow oficial fijado

Se verificó por lectura de la fuente oficial la interfaz `workflow_call` de
[`submission.yml` en el commit fijado](https://github.com/PalomarRegistry/PalomarSubmission/blob/14aa8d6b3c2f14a8540605e37144560b9a00e7e7/.github/workflows/submission.yml).
La revisión seleccionada es `14aa8d6b3c2f14a8540605e37144560b9a00e7e7`.
No se presenta como una garantía de ser la última revisión disponible.

La llamada mantiene ese mismo SHA en `uses` y `pipeline_commit`, y selecciona
`mode: full` y `execution_profile: palomar-standard-v1`. `request_id` vale
`preflight001`, con doce caracteres alfanuméricos en minúscula. Los parámetros
asumen el proyecto en la raíz y `comparator.json` en su ruta convencional.

El preflight oficial es predictivo. No sustituye la verificación posterior de
Palomar, no renderiza el Challenge para la revisión editorial, no decide interés
científico y no registra el resultado. La corrección local tampoco amplía el
alcance: la cota de riesgo formalizada es finita con `X=W`, y la identificación
causal y la garantía de aprendizaje siguen siendo hipótesis explícitas.

Fuentes oficiales consultadas:

- [Guía de envío](https://palomar-registry.org/how-to-submit).
- [Política vinculante](https://github.com/PalomarRegistry/PalomarPolicy/blob/main/CONTRIBUTING.md).
- [Protocolo para agentes y preflight mecánico](https://submit.palomar-registry.org/llms.txt).
- [README de PalomarSubmission](https://github.com/PalomarRegistry/PalomarSubmission).
- [Estándar formalization.yaml](https://github.com/mathlib-initiative/formalization.yaml).

La plantilla oficial aplica Apache-2.0 en su propio contrato de CI. Paper2
conserva la licencia MIT confirmada por su autor y utiliza esta configuración
propia, sin copiar ese contrato de licencia de la plantilla.
