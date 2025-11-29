param(
    [string]$SourceIcon = "..\images\aginove-icone.png",
    [switch]$SkipMagick
)

# Optimize favicon: resize source icon to multiple sizes and update HTML files with proper favicon tags
$sourceIcon = Join-Path $PSScriptRoot $SourceIcon
$imagesDir = Split-Path $sourceIcon
$rootDir = Split-Path $imagesDir

if (-not (Test-Path $sourceIcon)) {
    Write-Error "Source icon not found: $sourceIcon"
    exit 1
}

Write-Host "Optimizing favicon from: $sourceIcon" -ForegroundColor Yellow

# Check for ImageMagick 'magick'
$magick = Get-Command magick -ErrorAction SilentlyContinue
if (-not $magick -and -not $SkipMagick) {
    Write-Error "ImageMagick 'magick' not found. Install it or use -SkipMagick flag."
    exit 2
}

if ($magick) {
    # Generate optimized favicon sizes: 32x32, 64x64, 180x180 (Apple Touch Icon)
    $sizes = @(32, 64, 180)
    foreach ($size in $sizes) {
        $output = Join-Path $imagesDir "favicon-$($size)x$($size).png"
        Write-Host "Resizing to $($size)x$($size)..." -NoNewline
        $proc = Start-Process -FilePath magick `
            -ArgumentList @("`"$sourceIcon`"", "-resize", "$($size)x$($size)^", "-gravity", "center", "-extent", "$($size)x$($size)", "-quality", "90", "`"$output`"") `
            -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -eq 0) {
            $fileSize = (Get-Item $output).Length / 1KB
            Write-Host " done ($($fileSize)KB)." -ForegroundColor Green
        } else {
            Write-Host " failed (exit $($proc.ExitCode))." -ForegroundColor Red
        }
    }

    # List generated files
    Write-Host "`nGenerated favicon files:" -ForegroundColor Cyan
    Get-ChildItem -Path $imagesDir -Filter "favicon-*.png" | ForEach-Object {
        $size = $_.Length / 1KB
        Write-Host "  - $($_.Name) ($([math]::Round($size, 1))KB)"
    }
} else {
    Write-Host "Skipped ImageMagick resizing (use online tool or local image editor instead)." -ForegroundColor Cyan
}

# Update HTML files with proper favicon tags
Write-Host "`nUpdating HTML files with favicon tags..." -ForegroundColor Yellow

$htmlFiles = @(
    "index.html",
    "nos-services.html",
    "contact.html",
    "mentions-legales.html",
    "politique-confidentialite.html"
)

$newFaviconTags = "        " + '<link rel="icon" type="image/png" sizes="32x32" href="images/favicon-32x32.png">' + "`r`n" + `
                "        " + '<link rel="icon" type="image/png" sizes="64x64" href="images/favicon-64x64.png">' + "`r`n" + `
                "        " + '<link rel="apple-touch-icon" href="images/favicon-180x180.png">'

foreach ($file in $htmlFiles) {
    $filePath = Join-Path $rootDir $file
    if (Test-Path $filePath) {
        $content = Get-Content -Path $filePath -Raw
        $oldFaviconPattern = '<link rel="icon"[^>]*href="images/aginove-icone\.png"[^>]*>'
        $updated = $content -replace $oldFaviconPattern, $newFaviconTags
        
        if ($updated -ne $content) {
            Set-Content -Path $filePath -Value $updated -Encoding UTF8
            Write-Host "  DONE: $file" -ForegroundColor Green
        } else {
            Write-Host "  SKIPPED: $file (no old favicon tag)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ERROR: $file not found" -ForegroundColor Red
    }
}

Write-Host "`nFavicon optimization complete!" -ForegroundColor Green
