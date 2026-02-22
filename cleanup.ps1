# Windows System Cleanup Tool
# Clears temp files, junk files, recycle bin, DNS cache
# Runs System File Checker and schedules Check Disk on next reboot

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

function Remove-FolderContents($path, $label) {
    if (Test-Path $path) {
        $before = Get-FolderSize $path
        Write-Host "[*] Cleaning $label..." -ForegroundColor Yellow
        Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        $after = Get-FolderSize $path
        $saved = $before - $after
        Write-Host "    Freed: $(Format-Bytes $saved)" -ForegroundColor Green
        return $saved
    } else {
        Write-Host "[*] $label not found, skipping..." -ForegroundColor DarkGray
        return 0
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "      WINDOWS SYSTEM CLEANUP TOOL       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalSaved = 0

# --- USER TEMP ---
$totalSaved += Remove-FolderContents $env:TEMP "User Temp Folder"

# --- WINDOWS TEMP ---
$totalSaved += Remove-FolderContents "C:\Windows\Temp" "Windows Temp Folder"

# --- WINDOWS UPDATE CACHE ---
Write-Host "[*] Cleaning Windows Update cache..." -ForegroundColor Yellow
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
$totalSaved += Remove-FolderContents "C:\Windows\SoftwareDistribution\Download" "Windows Update Cache"
Start-Service wuauserv -ErrorAction SilentlyContinue

# --- WINDOWS ERROR REPORTS ---
$totalSaved += Remove-FolderContents "C:\ProgramData\Microsoft\Windows\WER\ReportArchive" "Windows Error Reports (Archive)"
$totalSaved += Remove-FolderContents "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" "Windows Error Reports (Queue)"

# --- RECYCLE BIN ---
Write-Host "[*] Emptying Recycle Bin..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "    Done" -ForegroundColor Green

# --- DNS CACHE ---
Write-Host "[*] Flushing DNS Cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "    Done" -ForegroundColor Green

# --- DELIVERY OPTIMISATION CACHE ---
$totalSaved += Remove-FolderContents "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache" "Delivery Optimisation Cache"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "      CLEANUP COMPLETE                  " -ForegroundColor Cyan
Write-Host "   Total space recovered: $(Format-Bytes $totalSaved)" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- SYSTEM FILE CHECKER ---
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      RUNNING SYSTEM FILE CHECKER       " -ForegroundColor Magenta
Write-Host "   This may take several minutes...     " -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
sfc /scannow
Write-Host ""

# --- CHECK DISK ---
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "      SCHEDULING CHECK DISK             " -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "[*] chkdsk can scan C: now but cannot fix errors while Windows is running." -ForegroundColor Yellow
Write-Host "    Scheduling chkdsk /f /r to run on next reboot." -ForegroundColor Yellow
Write-Output "Y" | chkdsk C: /f /r | Out-Null
Write-Host "    Scheduled. chkdsk will scan and repair your drive on next restart." -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ALL TASKS COMPLETE                   " -ForegroundColor Cyan
Write-Host "   Restart your PC to run Check Disk    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
