param(
    [string]$Pattern = "*.html"
)

# Fix UTF-8 encoding in HTML files: convert from corrupted encoding to proper UTF-8
$files = Get-ChildItem -Recurse -Filter $Pattern | Where-Object { $_.FullName -notlike "*node_modules*" }

if ($files.Count -eq 0) {
    Write-Host "No HTML files found matching pattern: $Pattern" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($files.Count) HTML files. Re-encoding to UTF-8..." -ForegroundColor Cyan

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        Write-Host "  DONE: $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ERROR: $($file.Name)" -ForegroundColor Red
    }
}

Write-Host "Done. All files re-encoded to UTF-8." -ForegroundColor Green
