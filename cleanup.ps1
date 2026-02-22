# Windows System Cleanup Tool - Work in Progress
# v1: basic temp file cleanup

function Get-FolderSize($path) {
    if (Test-Path $path) {
        (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    } else { 0 }
}

function Format-Bytes($bytes) {
    if ($bytes -ge 1GB) { "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { "{0:N2} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { "{0:N2} KB" -f ($bytes / 1KB) }
    else { "$bytes bytes" }
}

Write-Host "Starting cleanup..." -ForegroundColor Cyan

# Clean user temp
$before = Get-FolderSize $env:TEMP
Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$after = Get-FolderSize $env:TEMP
Write-Host "User Temp freed: $(Format-Bytes ($before - $after))" -ForegroundColor Green

# Clean windows temp
$before = Get-FolderSize "C:\Windows\Temp"
Get-ChildItem "C:\Windows\Temp" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
$after = Get-FolderSize "C:\Windows\Temp"
Write-Host "Windows Temp freed: $(Format-Bytes ($before - $after))" -ForegroundColor Green

Write-Host "Done." -ForegroundColor Cyan
