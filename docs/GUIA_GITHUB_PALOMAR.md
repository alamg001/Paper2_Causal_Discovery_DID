# Guía de GitHub y Palomar

Instrucciones de carga actualizadas el 12 de noviembre de 2026, America/Lima.
Los registros de ejecución conservan sus fechas originales.

Esta guía permite al autor preparar una publicación posterior. La entrega no
publica un repositorio, no autentica cuentas y no envía solicitudes. La
verificación protegida del servidor, la revisión editorial y el registro de
Palomar siguen pendientes.

## Estructura del repositorio

Use **el contenido de `Palomar_Rg/` como raíz del repositorio público `Paper2_Causal_Discovery_DID`**.
No añada una carpeta `Lean/` o `Palomar_Rg/` entre la raíz de GitHub y
`lakefile.toml`. Así se mantienen las rutas de scripts, configuración y CI.

```text
Paper2_Causal_Discovery_DID/    raíz del repositorio GitHub
├── .github/workflows/
│   ├── verify.yml
│   └── palomar-preflight.yml
├── docs/
│   ├── MATHEMATICAL_ACCOUNT.md
│   └── GUIA_GITHUB_PALOMAR.md
├── scripts/
│   ├── requirements-validation.txt
│   ├── validate_repository.py
│   └── resumen_envio.ps1
├── Math/
├── evidence/
├── Challenge.lean
├── Solution.lean
├── Audit.lean
├── AuditChallenge.lean
├── lakefile.toml
├── lake-manifest.json
├── lean-toolchain
├── comparator.json
├── formalization.yaml
├── LICENSE
├── README.md
├── LEER_PRIMERO.md
├── SHA256SUMS.txt
├── validar.ps1
└── validar.sh
```

`LICENSE` conserva la licencia MIT confirmada para el código y las pruebas
Lean. Las publicaciones citadas y las dependencias conservan sus licencias.
El dataset y el preprint completo pertenecen al archivo de replicación
separado; no son dependencias Lean. `.lake/`, credenciales y binarios generados
no deben incorporarse al repositorio.

## Carga mediante el navegador

Siga primero los ocho pasos de [`LEER_PRIMERO.md`](../LEER_PRIMERO.md). El contenido descomprimido debe quedar en la raíz, incluida `.github/`. Los comandos siguientes son una alternativa para quien utiliza Git localmente.

## Comprobar localmente

Instale Git y Elan, y Python 3.10 o posterior para el chequeo estático.
Desde la raíz preparada:

```powershell
python -m pip install -r scripts/requirements-validation.txt
python scripts/validate_repository.py --root .
python scripts/validate_repository.py --root . --check-hashes
.\validar.ps1
```

Los requisitos fijan PyYAML 6.0.3 y, cuando se necesita compatibilidad TOML,
tomli 2.4.0. El validador Python imprime un JSON de
comprobaciones estáticas preliminares; no sustituye compilar Lean ni aprobar
Palomar. Si modifica archivos, el manifiesto debe actualizarse para esa nueva
instantánea antes de interpretar su comprobación de hashes.

`./validar.ps1 -ComparatorWindows` agrega el comparador local explícitamente
sin aislamiento. En Linux use `bash validar.sh --comparator` para solicitar
la comprobación aislada configurada. El toolchain y las dependencias están
fijados; pueden requerir descarga. No copie `.olean` de versiones distintas.
Challenge y Solution se compilan y auditan por separado: declaran los mismos
nombres `Paper2.*`.

## Crear y publicar una instantánea: instrucciones para el autor

Revise la licencia, `formalization.yaml`, la cuenta matemática y los archivos
que Git incluirá. Cree en GitHub un repositorio público vacío llamado `Paper2_Causal_Discovery_DID`,
sin generar otro README o licencia. Los comandos siguientes son instrucciones
para una acción posterior del autor; esta entrega no los ha ejecutado.
Si ya existe un repositorio, preserve su historial y revise los remotos antes
de cambiarlos. Para uno nuevo, desde esta carpeta:

```powershell
git init -b main
git status --short
git add .
git diff --cached --stat
git status --short
git commit -m "Prepare Paper2 finite Lean formalization"
```

Revise el contenido preparado antes de confirmar el commit. Sustituya
`USUARIO` por su cuenta y use la URL de su repositorio vacío:

```powershell
git remote add origin https://github.com/USUARIO/Paper2_Causal_Discovery_DID.git
git remote -v
git push -u origin main
git rev-parse HEAD
```

La autenticación se realiza mediante el flujo habitual de Git/GitHub en su
equipo. No coloque tokens en el chat, comandos guardados, archivos o capturas.
El `push` publica cuando el autor lo ejecuta; no se ha realizado desde esta
entrega.

## Ejecutar los workflows manuales

En la pestaña **Actions** del repositorio publicado:

1. Ejecute **Lean checks (ordinary CI)**, definido en
   `.github/workflows/verify.yml`: compila, audita y compara las declaraciones.
2. Ejecute **Palomar full mechanical preflight**, definido en
   `.github/workflows/palomar-preflight.yml`. El operador debe confirmar de
   forma veraz su relación de autor o mantenedor responsable.
3. Revise el informe del artefacto `mechanical-report-preflight001`; debe
   indicar `status: pass`. No basta una tarea distinta que aparezca verde.

El segundo workflow usa `mode: full`, `execution_profile: palomar-standard-v1`
y el commit `github.sha` del evento. Su `uses` y su `pipeline_commit` están
fijados a la misma revisión upstream; no cambie solo uno. El preflight es
predictivo: no crea por sí solo una solicitud, decide interés científico ni
registra el resultado. Los dos workflows se entregan configurados, sin
ejecución remota declarada.

Después de modificar fuentes, configuración o metadatos, haga un commit nuevo
y repita las comprobaciones para ese SHA. La eventual solicitud debe referirse
a la misma instantánea cuya evidencia se revisó.

## Resumir los datos de una eventual solicitud

```powershell
.\scripts\resumen_envio.ps1
```

Este script imprime el remoto y el SHA de HEAD si existen, junto con las rutas
de configuración. No autentica, publica ni envía nada. Compruebe que el SHA
completo tenga 40 caracteres y conserve los enlaces a los resultados de Actions.

La evidencia más reciente de esta carpeta se resume en
`evidence/validacion_repositorio.json`. Distinga esa revalidación de los
registros anteriores conservados con sus fechas históricas: un log anterior
no demuestra por sí solo que un commit posterior se haya comprobado.

Las declaraciones seleccionadas son `Paper2.finite_cell_CATT_bias` y
`Paper2.finite_orthogonal_product_bound`; la configuración es `comparator.json`.
La cuenta para revisión es [`MATHEMATICAL_ACCOUNT.md`](MATHEMATICAL_ACCOUNT.md).
El dominio sigue siendo finito y la identificación causal y el exceso de
riesgo conservan sus hipótesis. Cerrar huecos no certifica CPT ni aprende el
PAG aumentado.

Para la etapa externa consulte [`ESTADO_PALOMAR.md`](../ESTADO_PALOMAR.md) y la
[guía de envío oficial](https://palomar-registry.org/how-to-submit). Preparación,
publicación, preflight y registro son etapas distintas. Esta carpeta se
entrega sin publicación ni verificación protegida del servidor.
