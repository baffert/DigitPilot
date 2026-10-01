@echo off
chcp 65001 >nul
title Digit'Pilot - Mise à jour forcée v0.1.2

echo ========================================================================
echo    DIGIT'PILOT - INSTALLATION FORCÉE v0.1.2 (Mode Administrateur)
echo ========================================================================
echo.
echo  Ce script installe la version 0.1.2 (Moteur Hybride Build / Version / Hash).
echo.

:: Vérifier qu'on est bien en mode admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  [!] Relancement en mode Administrateur...
    echo.
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo  [OK] Mode Administrateur confirmé.
echo.

set "NEW_EXE=%~dp0DigitPilot_Client\DigitPilot.exe"
set "INSTALL_DIR=C:\Program Files\DigitPilot"
set "TARGET_EXE=%INSTALL_DIR%\DigitPilot.exe"
set "TARGET_VER=%INSTALL_DIR%\VERSION.txt"

:: Vérifier que le nouvel exe existe
if not exist "%NEW_EXE%" (
    echo  [ERREUR] Fichier source introuvable : %NEW_EXE%
    echo  Assurez-vous que ce script est dans le dossier 2teste.
    pause
    exit /b 1
)

:: Vérifier que le dossier d'installation existe
if not exist "%INSTALL_DIR%" (
    echo  [ERREUR] Dossier d'installation introuvable : %INSTALL_DIR%
    echo  Digit'Pilot ne semble pas installé dans Program Files.
    pause
    exit /b 1
)

:: Fermer l'application si elle tourne
echo  [1/3] Fermeture de Digit'Pilot en cours...
taskkill /F /IM DigitPilot.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

:: Copie avec boucle de réessai
echo  [2/3] Installation du nouveau fichier exécutable...
set ATTEMPTS=0
:COPY_LOOP
set /a ATTEMPTS+=1
copy /y "%NEW_EXE%" "%TARGET_EXE%" >nul 2>&1
if errorlevel 1 (
    if %ATTEMPTS% LEQ 10 (
        ping 127.0.0.1 -n 2 >nul
        goto COPY_LOOP
    )
    echo  [ERREUR] Impossible de copier après 10 tentatives.
    pause
    exit /b 1
)

echo 0.1.2> "%TARGET_VER%"
echo  [OK] Fichier installé avec succès (tentative %ATTEMPTS%).
echo.

:: Vérification de l'intégrité
for %%A in ("%TARGET_EXE%") do set SIZE=%%~zA
echo  Taille vérifiée : %SIZE% bytes
echo.

echo  [3/3] Relancement de Digit'Pilot v0.1.2...
ping 127.0.0.1 -n 2 >nul
start "" /D "%INSTALL_DIR%" "%TARGET_EXE%"

echo.
echo ========================================================================
echo  [SUCCÈS] Digit'Pilot v0.1.2 est maintenant installé !
echo ========================================================================
echo.
pause
