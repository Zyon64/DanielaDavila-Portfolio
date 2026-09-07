@echo off
title Activar publicacion automatica
cd /d "%~dp0"

rem ---------------------------------------------------------------
rem  Se usa la carpeta de Inicio del USUARIO, no una tarea programada.
rem  Motivo: crear una tarea con "schtasks /sc onlogon" pide permisos
rem  de administrador. La carpeta de Inicio es del usuario y no pide
rem  nada, asi que esto funciona igual en una cuenta estandar.
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
rem Lanzador invisible: evita que quede una ventana negra abierta
> "%~dp0publicador-oculto.vbs" echo CreateObject("WScript.Shell").Run """%~dp0PUBLICADOR.bat""", 0, False

if not exist "%INICIO%" mkdir "%INICIO%" 2>nul

rem El acceso directo se crea con un VBS de un solo uso y despues se borra
set "TMPVBS=%TEMP%\crear-acceso-portafolio.vbs"
> "%TMPVBS%" echo Set sh = CreateObject("WScript.Shell")
>>"%TMPVBS%" echo Set lnk = sh.CreateShortcut("%ACCESO%")
>>"%TMPVBS%" echo lnk.TargetPath = "wscript.exe"
>>"%TMPVBS%" echo lnk.Arguments = """%~dp0publicador-oculto.vbs"""
>>"%TMPVBS%" echo lnk.WorkingDirectory = "%~dp0"
>>"%TMPVBS%" echo lnk.Description = "Publicador del portafolio de Daniela Davila"
>>"%TMPVBS%" echo lnk.Save
wscript.exe //nologo "%TMPVBS%"
del "%TMPVBS%" >nul 2>&1

if not exist "%ACCESO%" goto ERROR

echo.
echo ===========================================
echo    ACTIVADO
echo ===========================================
echo.
echo Arranca solo al iniciar sesion. Lo arranco ahora
echo tambien para que no tengas que reiniciar.
start "" wscript.exe "%~dp0publicador-oculto.vbs"
echo.
echo Ya podes cerrar esto y usar el editor normalmente.
echo.
pause
exit /b

:DESACTIVAR
del "%ACCESO%" >nul 2>&1

rem Por si quedo activado con el metodo viejo, que usaba una tarea
schtasks /delete /tn "PortafolioPublicador" /f >nul 2>&1

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
echo   3. Arrastra ahi el archivo publicador-oculto.vbs
echo      de esta carpeta, con boton derecho, y elegi
echo      "Crear iconos de acceso directo aqui".
echo.
pause
