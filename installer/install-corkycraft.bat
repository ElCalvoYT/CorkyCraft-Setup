@echo off
setlocal EnableExtensions
title CorkyCraft Installer

REM ============================================================
REM  CorkyCraft Modpack Installer
REM  Works on any Windows PC - no hardcoded user paths.
REM
REM  What it does:
REM    1. Finds the .minecraft folder for the current user
REM    2. Deletes the existing mods folder
REM    3. Deletes the existing config folder
REM    4. Deletes the existing options.txt
REM    5. Copies everything from ..\minecraft into .minecraft
REM ============================================================

REM --- Resolve the pack root (parent of this installer folder) ---
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "SRC=%ROOT%\minecraft"
set "DEST=%APPDATA%\.minecraft"

echo ============================================================
echo   CorkyCraft Modpack Installer
echo ============================================================
echo.
echo   Source : %SRC%
echo   Target : %DEST%
echo.

REM --- Verify the source folder exists ---
if not exist "%SRC%\" (
    echo [ERROR] Could not find the pack files at:
    echo         %SRC%
    echo.
    echo Make sure this .bat stays inside the "installer" folder,
    echo next to the "minecraft" folder. Do not run it from a ZIP -
    echo extract the whole CorkyCraft-Setup folder first.
    echo.
    pause
    exit /b 1
)

REM --- Make sure .minecraft exists (create it if Minecraft never ran) ---
if not exist "%DEST%\" (
    echo [INFO] .minecraft not found - creating it.
    mkdir "%DEST%" 2>nul
    if not exist "%DEST%\" (
        echo [ERROR] Could not create "%DEST%".
        pause
        exit /b 1
    )
)

echo ------------------------------------------------------------
echo   WARNING: This will PERMANENTLY DELETE from .minecraft:
echo     - the "mods" folder
echo     - the "config" folder
echo     - the "options.txt" file
echo.
echo   Your worlds (saves), screenshots and logs are NOT touched.
echo ------------------------------------------------------------
echo.
set "CONFIRM="
set /p "CONFIRM=Type Y and press Enter to continue (anything else cancels): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo Cancelled. Nothing was changed.
    pause
    exit /b 0
)
echo.

REM --- Warn if Minecraft / launcher is running (file locks) ---
tasklist /fi "imagename eq javaw.exe" 2>nul | find /i "javaw.exe" >nul
if not errorlevel 1 (
    echo [WARNING] Minecraft appears to be running.
    echo           Close Minecraft and the launcher, then press a key.
    pause
)

REM --- 1. Delete mods ---
if exist "%DEST%\mods\" (
    echo [1/4] Deleting old mods folder...
    rmdir /s /q "%DEST%\mods"
    if exist "%DEST%\mods\" (
        echo       [ERROR] Could not delete the mods folder.
        echo       Close Minecraft / the launcher and run this again.
        pause
        exit /b 1
    )
) else (
    echo [1/4] No existing mods folder - skipping.
)

REM --- 2. Delete config ---
if exist "%DEST%\config\" (
    echo [2/4] Deleting old config folder...
    rmdir /s /q "%DEST%\config"
    if exist "%DEST%\config\" (
        echo       [ERROR] Could not delete the config folder.
        echo       Close Minecraft / the launcher and run this again.
        pause
        exit /b 1
    )
) else (
    echo [2/4] No existing config folder - skipping.
)

REM --- 3. Delete options.txt ---
if exist "%DEST%\options.txt" (
    echo [3/4] Deleting old options.txt...
    del /f /q "%DEST%\options.txt"
) else (
    echo [3/4] No existing options.txt - skipping.
)

REM --- 4. Copy the pack in ---
echo [4/4] Copying CorkyCraft files into .minecraft...
echo       (this can take a minute - the pack is a few hundred MB)
echo.

where robocopy >nul 2>nul
if errorlevel 1 goto USE_XCOPY

robocopy "%SRC%" "%DEST%" /E /NFL /NDL /NJH /NJS /NP /R:2 /W:2
if errorlevel 8 goto COPY_FAILED
goto DONE

:USE_XCOPY
xcopy "%SRC%\*" "%DEST%\" /E /I /Y /Q
if errorlevel 1 goto COPY_FAILED
goto DONE

:COPY_FAILED
echo.
echo [ERROR] The copy did not finish successfully.
echo         Close Minecraft / the launcher, check you have enough
echo         disk space, then run this installer again.
echo.
pause
exit /b 1

:DONE
echo.
echo ============================================================
echo   DONE - CorkyCraft installed successfully.
echo ============================================================
echo.
echo Installed to: %DEST%
echo.
echo Next step: run the Fabric installer in this folder
echo (fabric-installer-1.1.2.exe) if you have not installed
echo Fabric 1.20.1 yet, then pick the Fabric profile in the
echo Minecraft launcher.
echo.
pause
exit /b 0
