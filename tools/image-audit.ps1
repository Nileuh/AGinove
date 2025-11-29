param(
    [int]$ThresholdMB = 0.2,
    [switch]$Convert
n)

# Image audit script: lists images in ./images larger than threshold and optionally converts them to WebP using ImageMagick (magick)
$thresholdBytes = $ThresholdMB * 1MB
$imagesDir = Join-Path $PSScriptRoot "..\images"
if (-not (Test-Path $imagesDir)) {
    Write-Error "Images directory not found: $imagesDir"
    exit 1
}

$files = Get-ChildItem -Path $imagesDir -File | Where-Object { $_.Length -gt $thresholdBytes }
if ($files.Count -eq 0) {
    Write-Host "No images larger than $ThresholdMB MB found." -ForegroundColor Green
    exit 0
}

Write-Host "Images larger than $ThresholdMB MB:" -ForegroundColor Yellow
$files | Sort-Object Length -Descending | Format-Table Name, @{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}}, FullName -AutoSize

if ($Convert) {
    # Check for ImageMagick 'magick'
    $magick = Get-Command magick -ErrorAction SilentlyContinue
    if (-not $magick) {
        Write-Error "ImageMagick 'magick' command not found. Install ImageMagick or remove -Convert flag."
        exit 2
    }

    foreach ($f in $files) {
        $input = $f.FullName
        $webp = [System.IO.Path]::ChangeExtension($input, '.webp')
        if (Test-Path $webp) {
            Write-Host "WebP already exists for $($f.Name), skipping." -ForegroundColor Cyan
            continue
        }
        Write-Host "Converting $($f.Name) -> $(Split-Path $webp -Leaf) ..." -NoNewline
        $proc = Start-Process -FilePath magick -ArgumentList @("`"$input`"","-quality","85","`"$webp`"") -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -eq 0) { Write-Host " done." -ForegroundColor Green } else { Write-Host " failed (exit $($proc.ExitCode))." -ForegroundColor Red }
    }

    Write-Host "Conversion complete. Review files and replace references if desired." -ForegroundColor Green
}

Write-Host "Done." -ForegroundColor Green
