param([switch]$ComparatorWindows)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
New-Item -ItemType Directory -Force -Path '.lake/validation' | Out-Null
$projectLeanFiles = Get-ChildItem -LiteralPath $PSScriptRoot -Recurse -File -Filter '*.lean' |
  Where-Object { $_.FullName -notlike "$PSScriptRoot\.lake\*" }
$admissions = $projectLeanFiles | Select-String -Pattern '\b(sorry|admit)\b' -CaseSensitive
if ($admissions) {
  $admissions | ForEach-Object { Write-Error "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
  throw 'Se encontraron admisiones en fuentes Lean'
}
& lean --version | Set-Content -Encoding utf8 '.lake/validation/lean_version.log'
if ($LASTEXITCODE -ne 0) { throw 'Lean no disponible' }
& lake --version | Set-Content -Encoding utf8 '.lake/validation/lake_version.log'
& lake build *> '.lake/validation/lake_build.log'
if ($LASTEXITCODE -ne 0) { Get-Content '.lake/validation/lake_build.log' -Tail 40; throw 'Falló lake build' }
& lake env lean Audit.lean *> '.lake/validation/audit.log'
if ($LASTEXITCODE -ne 0) { throw 'Falló Audit.lean' }
if (Select-String -Path '.lake/validation/audit.log' -Pattern 'sorryAx' -Quiet) { throw 'Prueba con sorryAx' }
& lake env lean AuditChallenge.lean *> '.lake/validation/audit_challenge.log'
if ($LASTEXITCODE -ne 0) { throw 'Falló AuditChallenge.lean' }
if (Select-String -Path '.lake/validation/audit_challenge.log' -Pattern 'sorryAx' -Quiet) { throw 'Challenge depende de sorryAx' }
if ($ComparatorWindows) {
  # Windows lacks bwrap; this is explicitly a local unisolated check.
  # Upstream whichExe invokes Unix which. Use the native Windows locator.
  New-Item -ItemType Directory -Force -Path '.lake/windows-tools' | Out-Null
  Copy-Item -LiteralPath "$env:WINDIR/System32/where.exe" -Destination '.lake/windows-tools/which.exe'
  $leanPrefixTask = (& lean --print-prefix).Trim()
  $gitUsrTask = Join-Path $env:ProgramFiles 'Git/usr/bin'
  if (!(Test-Path -LiteralPath (Join-Path $gitUsrTask 'env.exe'))) { throw 'Git for Windows con usr/bin/env.exe requerido' }
  $env:PATH = ((@((Join-Path $PSScriptRoot '.lake/windows-tools'),(Join-Path $leanPrefixTask 'bin'),$gitUsrTask) + $env:PATH.Split(';')) | Select-Object -Unique) -join ';'
  & lake comparator --config comparator.json --inadvisably-no-sandbox *> '.lake/validation/comparator_windows_unisolated.log'
  if ($LASTEXITCODE -ne 0) { throw 'Comparator rechazó o no pudo comprobar el proyecto; consulte el log' }
}
Write-Output 'Compilación, Challenge y auditorías terminadas sin admisiones. Consultar .lake/validation/.'
