# Windows System Cleanup

PowerShell script that clears out the usual junk that builds up on Windows over time.

Clears temp files, error logs, memory dumps, recycle bin, DNS cache and the 
Delivery Optimisation cache, then shows how much space was freed. Finishes by 
running System File Checker to catch any corrupted system files.

## How to run

Open PowerShell as Administrator:

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine
    .\cleanup.ps1

## What it clears out

- User and Windows temp folders
- Windows error report logs
- Memory dump files
- Recycle bin
- DNS cache
- Delivery Optimisation cache

## System check

Runs sfc /scannow at the end to scan for and repair any corrupted system files.
