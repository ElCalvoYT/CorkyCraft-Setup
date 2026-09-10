@echo off
setlocal EnableExtensions
title CorkyCraft Installer

REM ============================================================
REM  CorkyCraft Modpack Installer
REM  Fully automatic - just double-click. No questions asked.
REM  Works on any Windows PC (no hardcoded user paths).
REM
REM  1. Finds the .minecraft folder for the current user
REM  2. Deletes the existing mods folder
REM  3. Deletes the existing config folder
REM  4. Deletes the existing options.txt
REM  5. Copies everything from ..\minecraft into .minecraft
REM ============================================================

REM --- Resolve the pack root (parent of this installer folder) ---
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "SRC=%ROOT%\minecraft"
set "DEST=%APPDATA%\.minecraft"

echo ============================================================
echo   CorkyCraft Modpack Installer
echo ============================================================
echo.
echo   Installing from : %SRC%
echo   Installing to   : %DEST%
echo.

REM --- Verify the source folder exists ---
if not exist "%SRC%\" (
    echo [ERROR] Could not find the pack files at:
    echo         %SRC%
    echo.
    echo Keep this .bat inside the "installer" folder, next to the
    echo "minecraft" folder. If you downloaded a ZIP, extract the
    echo whole CorkyCraft-Setup folder first, then run this again.
    goto FAIL
)

REM --- Close Minecraft if it is running, so files are not locked ---
tasklist /fi "imagename eq javaw.exe" 2>nul | find /i "javaw.exe" >nul
if not errorlevel 1 (
    echo [INFO] Minecraft is running - closing it so files can be replaced.
    taskkill /f /im javaw.exe >nul 2>nul
    ping -n 4 127.0.0.1 >nul
)

REM --- Make sure .minecraft exists (create it if Minecraft never ran) ---
if not exist "%DEST%\" (
    echo [INFO] .minecraft not found - creating it.
    mkdir "%DEST%" 2>nul
    if not exist "%DEST%\" (
        echo [ERROR] Could not create "%DEST%".
        goto FAIL
    )
)

REM --- 1. Delete mods ---
if exist "%DEST%\mods\" (
    echo [1/4] Removing old mods folder...
    call :NUKE_DIR "%DEST%\mods"
    if exist "%DEST%\mods\" (
        echo       [ERROR] Could not remove the mods folder ^(files in use^).
        goto FAIL
    )
) else (
    echo [1/4] No mods folder found - nothing to remove.
)

REM --- 2. Delete config ---
if exist "%DEST%\config\" (
    echo [2/4] Removing old config folder...
    call :NUKE_DIR "%DEST%\config"
    if exist "%DEST%\config\" (
        echo       [ERROR] Could not remove the config folder ^(files in use^).
        goto FAIL
    )
) else (
    echo [2/4] No config folder found - nothing to remove.
)

REM --- 3. Delete options.txt ---
if exist "%DEST%\options.txt" (
    echo [3/4] Removing old options.txt...
    del /f /q "%DEST%\options.txt" >nul 2>nul
) else (
    echo [3/4] No options.txt found - nothing to remove.
)

REM --- 4. Copy the pack in ---
echo [4/4] Copying CorkyCraft files ^(a few hundred MB, please wait^)...
echo.

where robocopy >nul 2>nul
if errorlevel 1 goto USE_XCOPY

robocopy "%SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS /NP /R:3 /W:2
if errorlevel 8 goto COPY_FAILED
goto DONE

:USE_XCOPY
xcopy "%SRC%\*" "%DEST%\" /E /I /Y /Q
if errorlevel 1 goto COPY_FAILED
goto DONE

:COPY_FAILED
echo.
echo [ERROR] The copy did not finish successfully.
echo         Make sure Minecraft and the launcher are closed and that
echo         you have enough free disk space, then run this again.
goto FAIL

:DONE
echo.
echo ============================================================
echo   DONE - CorkyCraft installed successfully.
echo ============================================================
echo.
echo Installed to: %DEST%
echo.
echo If you have not installed Fabric 1.20.1 yet, run
echo fabric-installer-1.1.2.exe in this folder, then pick the
echo Fabric profile in the Minecraft launcher.
echo.
echo This window closes in 10 seconds.
timeout /t 10 /nobreak >nul 2>nul
exit /b 0

:FAIL
echo.
echo Installation FAILED - nothing else was changed.
echo This window stays open for 60 seconds so you can read the message.
timeout /t 60 >nul 2>nul
exit /b 1

REM ============================================================
REM  Helper: delete a folder, retrying a few times in case a
REM  file is briefly locked by antivirus or the launcher.
REM ============================================================
:NUKE_DIR
set "TARGET=%~1"
for /l %%N in (1,1,3) do (
    if exist "%TARGET%\" (
        rmdir /s /q "%TARGET%" >nul 2>nul
        if exist "%TARGET%\" ping -n 3 127.0.0.1 >nul
    )
)
exit /b 0
