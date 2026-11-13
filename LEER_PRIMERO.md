# Paper2_Causal_Discovery_DID: archivos para GitHub y Palomar

Empaquetado e instrucciones actualizados el 12 de noviembre de 2026, America/Lima.
La evidencia de ejecución Lean conserva su fecha original del 8 de noviembre.

Esta carpeta contiene el proyecto Lean autónomo. Use **su contenido como raíz
del repositorio público `Paper2_Causal_Discovery_DID`**: `lakefile.toml`, `LICENSE`, `formalization.yaml`
y `.github/` deben quedar directamente en esa raíz. El ZIP completo de datos y
preprint se conserva como material de replicación separado, no como dependencia
del proyecto Lean.

## Subir este paquete mediante el navegador

1. Descomprima el ZIP en una carpeta nueva y entre al nivel que contiene
   `Challenge.lean` y `lakefile.toml`.
2. Cree un repositorio público vacío llamado **Paper2_Causal_Discovery_DID** en su cuenta de GitHub.
   No genere otro README, archivo .gitignore ni licencia: ya están incluidos.
   Si el repositorio ya existe, revise su contenido antes de reemplazar archivos.
3. Pulse **uploading an existing file** o **Add file > Upload files**.
4. Arrastre todo el contenido descomprimido, incluidas las carpetas y los archivos
   que empiezan por punto. No cargue el ZIP ni una carpeta contenedora adicional.
5. Compruebe que `Challenge.lean`, `LICENSE` y `lakefile.toml` estén en la raíz;
   los workflows deben quedar en `.github/workflows/`. Confirme la carga con
   **Commit changes**.
6. En **Actions**, ejecute manualmente **Lean checks (ordinary CI)** y después
   **Palomar full mechanical preflight**. Revise los informes del mismo commit.
7. En **Code > Commits**, copie **Copy the full SHA**, de 40 caracteres.
8. Para Palomar, el repositorio será `TU_USUARIO/Paper2_Causal_Discovery_DID`, sustituyendo
   `TU_USUARIO` por la cuenta real. Seleccione `comparator.json` y deje vacías
   las rutas opcionales de proyecto y metadatos para usar esta raíz.

El nombre externo de GitHub no cambia el namespace Lean `Paper2` ni los nombres
de los teoremas. Esta entrega contiene **61 archivos** y selecciona dos resultados
finitos en una configuración Comparator. La verificación protegida y el registro
son etapas posteriores; la corrección estructural no asegura aceptación editorial.

Empiece por estos documentos:

- [`README.md`](README.md): resultados, procedencia, reproducción y alcance.
- [`docs/MATHEMATICAL_ACCOUNT.md`](docs/MATHEMATICAL_ACCOUNT.md): cuenta
  matemática autocontenida en inglés de los dos resultados seleccionados.
- [`docs/GUIA_GITHUB_PALOMAR.md`](docs/GUIA_GITHUB_PALOMAR.md): estructura del
  repositorio, instrucciones de publicación posterior y comprobaciones.
- [`ESTADO_PALOMAR.md`](ESTADO_PALOMAR.md): preparación y pasos externos pendientes.

Instale Git, Elan y Python 3.10 o posterior. Desde esta carpeta:

```powershell
python -m pip install -r scripts/requirements-validation.txt
python scripts/validate_repository.py --root .
python scripts/validate_repository.py --root . --check-hashes
.\validar.ps1
```

El validador Python realiza comprobaciones estáticas preliminares. La
compilación Lean y sus auditorías son comprobaciones separadas. Para agregar
el comparador local en Windows use `./validar.ps1 -ComparatorWindows`; ese
modo es explícitamente sin aislamiento. En Linux use
`bash validar.sh --comparator`. Las versiones están fijadas y las dependencias
pueden requerir descarga. No copie `.olean` de otros toolchains; `.lake/` se
regenera y no se publica.

Los 11 archivos Lean propios no tienen admisiones. Se cerraron los dos huecos
de `Challenge.lean` con las pruebas que ya existían en `Solution.lean`, sin
alterar firmas ni añadir hipótesis. Ambos módulos tienen pruebas completas y
se auditan por separado porque declaran los mismos nombres. La auditoría de
Math/Solution contiene 26 declaraciones; la de Challenge contiene seis
declaraciones paralelas, no otros seis resultados matemáticos distintos.

Consulte primero `evidence/validacion_repositorio.json` para la revalidación
de esta carpeta. Los registros previos de `evidence/` conservan sus fechas
históricas y la evidencia local anterior de Lean default/NanoDa; no sustituyen
comprobar el commit que vaya a publicarse. `SHA256SUMS.txt` permite verificar
la integridad de la entrega.

La licencia MIT está confirmada para el código y las pruebas Lean. La cota
producto sigue siendo para `X=W` finito y mantiene una hipótesis explícita
de exceso de riesgo. La identificación causal, las medidas generales y el
aprendizaje de un PAG aumentado no quedan certificados por cerrar huecos.

Los workflows manuales de CI y preflight completo están configurados en
`.github/workflows/`, sin ejecución remota declarada. El comando
`./scripts/resumen_envio.ps1` muestra el remoto y el commit disponibles, sin
publicar, autenticar ni enviar solicitudes. **La carpeta se entrega sin
publicación, sin verificación protegida del servidor y sin registro de Palomar.**
