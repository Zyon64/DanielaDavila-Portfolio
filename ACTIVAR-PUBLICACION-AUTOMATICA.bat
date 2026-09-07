@echo off
title Activar publicacion automatica
cd /d "%~dp0"

rem ---------------------------------------------------------------
rem  Se usa la carpeta de Inicio del USUARIO, no una tarea programada:
rem  crear una tarea con "schtasks /sc onlogon" pide permisos de
rem  administrador. La carpeta de Inicio es del usuario y no pide nada.
rem
rem  El acceso directo apunta DIRECTO a powershell con la ventana
rem  oculta. Antes habia un archivo .vbs intermedio, pero los .vbs son
rem  de lo primero que borran los antivirus y las politicas de equipo.
rem ---------------------------------------------------------------
set "INICIO=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "ACCESO=%INICIO%\Portafolio - Publicador.lnk"

echo ===========================================
echo    PUBLICACION AUTOMATICA
echo ===========================================
echo.
echo Esto hace que el publicador arranque solo cada vez
echo que inicies sesion en Windows, en segundo plano.
echo.
echo A partir de ahi, el boton Guardar del editor publica
echo directo: no hay que abrir ningun archivo.
echo.
echo No hace falta ser administrador.
echo.

if exist "%ACCESO%" (
  echo   Estado actual: ACTIVADO
) else (
  echo   Estado actual: desactivado
)
echo.
echo   1 = Activar
echo   2 = Desactivar
echo   3 = Salir
echo.
set /p op="Elegi una opcion (1-3): "

if "%op%"=="1" goto ACTIVAR
if "%op%"=="2" goto DESACTIVAR
exit /b

:ACTIVAR
if not exist "%INICIO%" mkdir "%INICIO%" 2>nul

rem El acceso directo se arma con PowerShell y se borra a si mismo:
rem no queda ningun archivo suelto en la carpeta del proyecto.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$s=New-Object -ComObject WScript.Shell;" ^
  "$l=$s.CreateShortcut('%ACCESO%');" ^
  "$l.TargetPath='powershell.exe';" ^
  "$l.Arguments='-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%~dp0publicador.ps1\"';" ^
  "$l.WorkingDirectory='%~dp0';" ^
  "$l.Description='Publicador del portafolio de Daniela Davila';" ^
  "$l.Save()"

if not exist "%ACCESO%" goto ERROR

echo.
echo ===========================================
echo    ACTIVADO
echo ===========================================
echo.
echo Arranca solo al iniciar sesion. Lo arranco ahora
echo tambien para que no tengas que reiniciar.
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0publicador.ps1"
echo.
echo Ya podes cerrar esto y usar el editor normalmente.
echo.
echo Para comprobar que esta corriendo, en el editor el
echo cartel de arriba te va a decir si esta activo.
echo.
pause
exit /b

:DESACTIVAR
del "%ACCESO%" >nul 2>&1

rem Por si quedo activado con alguno de los metodos viejos
schtasks /delete /tn "PortafolioPublicador" /f >nul 2>&1
del "%INICIO%\publicador-oculto.vbs.lnk" >nul 2>&1

taskkill /fi "WINDOWTITLE eq Publicador del portafolio*" /f >nul 2>&1
echo.
echo Desactivado. Para publicar vas a tener que abrir
echo PUBLICADOR.bat a mano cuando quieras.
echo.
pause
exit /b

:ERROR
echo.
echo No se pudo crear el acceso directo en:
echo   %INICIO%
echo.
echo Alternativa a mano, sin permisos especiales:
echo   1. Apreta Windows + R
echo   2. Escribi:  shell:startup   y dale Enter
echo   3. Se abre la carpeta de Inicio. Arrastra ahi
echo      PUBLICADOR.bat de esta carpeta con el boton
echo      DERECHO y elegi "Crear iconos de acceso directo aqui".
echo.
pause
