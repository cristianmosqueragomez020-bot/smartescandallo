# ============================================================
# SMARTESCANDALLO - EXPORTADOR PARA IA
# ============================================================
# Uso:
# 1. Guarda este archivo como: export-project.ps1
# 2. Colócalo en la carpeta raíz de SmartEscandallo
# 3. En VS Code -> Terminal -> PowerShell
# 4. Ejecuta:
#       Set-ExecutionPolicy -Scope Process Bypass
#       .\export-project.ps1
#
# Resultado:
#       SMARTESCANDALLO_AI_CONTEXT.zip
#
# El exportador:
# - Conserva código y configuración útil para una IA
# - Genera estructura del proyecto
# - Genera un CODEBASE.md con el contenido textual
# - Excluye dependencias, builds, .git y secretos
# - NO incluye archivos .env ni claves privadas
# ============================================================

$ErrorActionPreference = "Stop"

$ProjectRoot = (Get-Location).Path
$ExportName = "SMARTESCANDALLO_AI_CONTEXT"
$ExportDir = Join-Path $ProjectRoot $ExportName
$ZipPath = Join-Path $ProjectRoot "$ExportName.zip"

# Carpetas que NO deben exportarse
$ExcludedDirectories = @(
    "node_modules",
    ".git",
    ".github",
    "dist",
    "build",
    ".next",
    ".nuxt",
    ".output",
    ".vite",
    "coverage",
    ".turbo",
    ".cache",
    "__pycache__",
    ".idea",
    ".vscode"
)

# Archivos que NO deben exportarse
$ExcludedFileNames = @(
    ".env",
    ".env.local",
    ".env.development",
    ".env.production",
    ".env.test",
    ".env.example.local",
    "*.pem",
    "*.key",
    "*.p12",
    "*.pfx",
    "*.crt",
    "*.cer",
    "*.der",
    "*.jks",
    "*.keystore",
    "id_rsa",
    "id_rsa.pub"
)

# Extensiones binarias/no útiles para el análisis de código
$ExcludedExtensions = @(
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico",
    ".mp3", ".mp4", ".wav", ".mov", ".avi",
    ".zip", ".rar", ".7z", ".tar", ".gz",
    ".exe", ".dll", ".so", ".dylib",
    ".woff", ".woff2", ".ttf", ".otf",
    ".pdf"
)

# Archivos demasiado grandes para meter dentro del CODEBASE.md
$MaxTextFileSizeMB = 2
$MaxTextFileSizeBytes = $MaxTextFileSizeMB * 1MB

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " SMARTESCANDALLO - EXPORTADOR PARA IA" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Evitar que el propio export anterior se copie
if (Test-Path $ExportDir) {
    Remove-Item $ExportDir -Recurse -Force
}

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

New-Item -ItemType Directory -Path $ExportDir | Out-Null

function Test-ExcludedPath {
    param([string]$FullPath)

    $relative = $FullPath.Substring($ProjectRoot.Length).TrimStart('\','/')

    foreach ($dir in $ExcludedDirectories) {
        $escaped = [regex]::Escape($dir)
        if ($relative -match "(^|[\\/])$escaped([\\/]|$)") {
            return $true
        }
    }

    return $false
}

function Test-ExcludedFile {
    param([System.IO.FileInfo]$File)

    if ($ExcludedExtensions -contains $File.Extension.ToLower()) {
        return $true
    }

    foreach ($pattern in $ExcludedFileNames) {
        if ($File.Name -like $pattern) {
            return $true
        }
    }

    return $false
}

# Obtener archivos válidos
$Files = Get-ChildItem -Path $ProjectRoot -Recurse -File |
    Where-Object {
        -not (Test-ExcludedPath $_.FullName) -and
        -not (Test-ExcludedFile $_) -and
        $_.FullName -ne $ZipPath
    } |
    Sort-Object FullName

Write-Host "Archivos detectados: $($Files.Count)" -ForegroundColor Green

# ------------------------------------------------------------
# 01 - ESTRUCTURA DEL PROYECTO
# ------------------------------------------------------------

$StructurePath = Join-Path $ExportDir "01_PROJECT_STRUCTURE.md"

$structure = @"
# SmartEscandallo — Estructura del proyecto

Exportado: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Directorios y archivos incluidos

"@

foreach ($file in $Files) {
    $relative = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\','/')
    $structure += "- ``$relative```n"
}

Set-Content -Path $StructurePath -Value $structure -Encoding UTF8

# ------------------------------------------------------------
# 02 - CODEBASE COMPLETO
# ------------------------------------------------------------

$CodebasePath = Join-Path $ExportDir "02_CODEBASE.md"

$header = @"
# SmartEscandallo — CODEBASE

Este documento contiene el código/configuración textual exportable del proyecto.

## Reglas para la IA

- Analiza primero la arquitectura existente.
- No asumas que una funcionalidad no existe sin comprobar el código.
- No reescribas código funcional innecesariamente.
- Identifica dependencias entre frontend, backend, base de datos y módulos compartidos.
- Antes de modificar código, explica el diagnóstico y el impacto.
- Mantén las decisiones arquitectónicas existentes salvo que exista una razón técnica clara.
- Los archivos sensibles y secretos han sido excluidos deliberadamente.

---

"@

Set-Content -Path $CodebasePath -Value $header -Encoding UTF8

foreach ($file in $Files) {

    $relative = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\','/')
    $extension = $file.Extension.TrimStart('.')

    if ([string]::IsNullOrWhiteSpace($extension)) {
        $extension = "text"
    }

    Add-Content -Path $CodebasePath -Value "`n## FILE: $relative`n" -Encoding UTF8

    if ($file.Length -gt $MaxTextFileSizeBytes) {
        Add-Content -Path $CodebasePath -Value "[ARCHIVO OMITIDO DEL CODEBASE.md: supera $MaxTextFileSizeMB MB. El archivo se conserva en la estructura del ZIP.]" -Encoding UTF8
        continue
    }

    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

        # Evitar que una secuencia de backticks rompa el bloque Markdown
        $fence = "````"

        Add-Content -Path $CodebasePath -Value "$fence$extension" -Encoding UTF8
        Add-Content -Path $CodebasePath -Value $content -Encoding UTF8
        Add-Content -Path $CodebasePath -Value "$fence" -Encoding UTF8
    }
    catch {
        Add-Content -Path $CodebasePath -Value "[No se pudo leer como texto: $($_.Exception.Message)]" -Encoding UTF8
    }
}

# ------------------------------------------------------------
# 03 - CONTEXTO PARA LA IA
# ------------------------------------------------------------

$InstructionsPath = Join-Path $ExportDir "03_INSTRUCTIONS_FOR_AI.md"

$instructions = @"
# SmartEscandallo — Instrucciones para la IA

## Objetivo

Analizar el proyecto SmartEscandallo como un programador senior y asistente técnico permanente.

## Orden obligatorio de análisis

1. Arquitectura general.
2. Frontend.
3. Backend.
4. Base de datos y ORM.
5. Autenticación/autorización.
6. APIs y servicios externos.
7. Estado y gestión de datos.
8. Componentes compartidos.
9. Flujos principales de usuario.
10. Tests y calidad.
11. Seguridad.
12. Deuda técnica.
13. Funcionalidades incompletas.
14. Riesgos antes de modificar código.

## Reglas de trabajo

### Antes de programar
- Diagnostica primero.
- Localiza dónde está implementada actualmente cada funcionalidad.
- Comprueba si existen servicios/hooks/componentes equivalentes.
- Evita duplicar lógica.
- Explica qué archivos modificarías y por qué.

### Durante la programación
- Cambios pequeños y controlados.
- Mantén compatibilidad con lo existente.
- No elimines funcionalidades sin autorización.
- No cambies el esquema de base de datos sin explicar migración e impacto.
- No introduzcas dependencias innecesarias.
- Respeta el patrón arquitectónico existente.

### Después de programar
- Explica exactamente qué cambiaste.
- Enumera archivos creados/modificados/eliminados.
- Explica posibles efectos secundarios.
- Indica cómo probarlo.
- Señala cualquier punto que no hayas podido verificar.

## Seguridad

Nunca solicites ni reproduzcas secretos, contraseñas, API keys, tokens o claves privadas.

Los archivos de entorno y certificados han sido excluidos del export.

## Criterio fundamental

No confundas:

- "no lo encuentro"
con
- "no existe".

Antes de concluir que algo falta, busca en toda la arquitectura.

---

# PRIMERA TAREA PARA LA IA

NO modificar código todavía.

Realizar una auditoría inicial del proyecto y entregar:

1. Resumen ejecutivo.
2. Arquitectura actual.
3. Tecnologías detectadas.
4. Estructura de carpetas.
5. Flujo principal de la aplicación.
6. Estado del frontend.
7. Estado del backend.
8. Estado de la base de datos.
9. Funcionalidades ya implementadas.
10. Funcionalidades incompletas.
11. Errores potenciales.
12. Riesgos de seguridad.
13. Deuda técnica.
14. Dependencias críticas.
15. Tests existentes.
16. Qué debería hacerse primero.
17. Qué NO debería tocarse porque funciona correctamente.
18. Roadmap técnico recomendado.

Después de entregar este diagnóstico, esperar instrucciones antes de realizar cambios estructurales.
"@

Set-Content -Path $InstructionsPath -Value $instructions -Encoding UTF8

# ------------------------------------------------------------
# 04 - MANIFIESTO
# ------------------------------------------------------------

$ManifestPath = Join-Path $ExportDir "00_MANIFEST.txt"

$manifest = @"
SMARTESCANDALLO - AI CONTEXT EXPORT

Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Proyecto: SmartEscandallo
Archivos incluidos: $($Files.Count)

Contenido:
00_MANIFEST.txt
01_PROJECT_STRUCTURE.md
02_CODEBASE.md
03_INSTRUCTIONS_FOR_AI.md

Exclusiones:
- node_modules
- .git
- builds/dist
- caches
- archivos .env
- certificados y claves privadas
- archivos multimedia
- PDFs y binarios

IMPORTANTE:
Este paquete NO sustituye una revisión del repositorio original.
Antes de compartirlo, revisa especialmente:
- URLs privadas
- tokens hardcodeados
- contraseñas
- claves API
- datos reales de clientes
- información personal
"@

Set-Content -Path $ManifestPath -Value $manifest -Encoding UTF8

# ------------------------------------------------------------
# CREAR ZIP
# ------------------------------------------------------------

Write-Host ""
Write-Host "Creando ZIP..." -ForegroundColor Yellow

Compress-Archive -Path (Join-Path $ExportDir "*") -DestinationPath $ZipPath -CompressionLevel Optimal

Write-Host ""
Write-Host "==============================================" -ForegroundColor Green
Write-Host " EXPORTACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Carpeta:" -NoNewline
Write-Host " $ExportDir"
Write-Host ""
Write-Host "ZIP:" -NoNewline
Write-Host " $ZipPath" -ForegroundColor Green
Write-Host ""
Write-Host "Archivos incluidos: $($Files.Count)"
Write-Host ""
Write-Host "IMPORTANTE: revisa el ZIP antes de enviarlo a una IA." -ForegroundColor Yellow
Write-Host ""
