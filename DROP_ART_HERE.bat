@echo off
setlocal
cd /d "%~dp0"

echo.
echo ========================================
echo       THE BIBLE SORT OF - ART DROP
echo ========================================
echo.
echo Put the image in BibleSortOfDrop first.
echo.
set /p CATEGORY="Type [background/sprite/effect]: "
set /p NAME="Asset name (example: burning_bush): "

echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\art-drop.ps1" "%CATEGORY%" "%NAME%"

echo.
pause
