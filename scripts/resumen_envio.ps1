$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Instale Git antes de consultar el commit.' }
if (-not (Test-Path -LiteralPath '.git')) {
    Write-Output 'No hay repositorio Git inicializado en esta carpeta. Consulte docs/GUIA_GITHUB_PALOMAR.md.'
    return
}
$commitForPalomarTask = (& git rev-parse --verify HEAD 2>$null)
if ($LASTEXITCODE -ne 0) { throw 'Todavía no hay un commit. Confirme los archivos y haga commit primero.' }
$remoteForPalomarTask = (& git remote get-url origin 2>$null)
if ($LASTEXITCODE -ne 0) { throw 'No hay remoto origin. Configure el repositorio público antes del envío.' }
$commitForPalomarTask = $commitForPalomarTask.Trim()
$remoteForPalomarTask = $remoteForPalomarTask.Trim()
if ($commitForPalomarTask -notmatch '^[0-9a-f]{40}$') { throw 'Se requiere el SHA completo de 40 caracteres.' }
if ($remoteForPalomarTask -match '^https://github\.com/([^/]+)/([^/]+?)(?:\.git)?$') {
    $repositoryForPalomarTask = $Matches[1] + '/' + $Matches[2]
} elseif ($remoteForPalomarTask -match '^git@github\.com:([^/]+)/([^/]+?)(?:\.git)?$') {
    $repositoryForPalomarTask = $Matches[1] + '/' + $Matches[2]
} else { throw 'origin debe ser un repositorio github.com sin credenciales en la URL.' }
[pscustomobject]@{
    repository = $repositoryForPalomarTask
    commit = $commitForPalomarTask
    project_path = '.'
    comparator_config_path = 'comparator.json'
    formalization_metadata_path = 'formalization.yaml'
    authorization_relationship = 'Debe declararla el autor o mantenedor al solicitar el envío'
    note = 'Estos valores locales no acreditan push público ni preflight aprobado. Este script no envía ni registra.'
} | ConvertTo-Json
