@echo off
chcp 65001 > nul
title YT-DLP Downloader by Kratostia
setlocal enabledelayedexpansion

:: Ejecutables
set YTDLP=yt-dlp.exe
set FFMPEG_DIR=ffmpeg-bin
set FFMPEG_EXE=%FFMPEG_DIR%\bin\ffmpeg.exe

:: Añadir ffmpeg al PATH si existe
if exist "%FFMPEG_EXE%" (
    set "PATH=%CD%\%FFMPEG_DIR%\bin;%PATH%"
)

:: Función para mostrar progreso de descarga con PowerShell
:download_with_progress
:: %1 = URL, %2 = destino
powershell -Command "$client = New-Object System.Net.WebClient; $client.DownloadProgressChanged += { Write-Progress -Activity 'Descargando %~nx2' -Status $_.ProgressPercentage -PercentComplete $_.ProgressPercentage }; $client.DownloadFileAsync([Uri]'%1', '%2'); while ($client.IsBusy) { Start-Sleep -Milliseconds 100 }"
exit /b
:: Función para mostrar el menú principal
:inicio
cls
color 0A
echo.
echo ██╗   ██╗████████╗    ██████╗ ██╗     ██████╗ 
echo ╚██╗ ██╔╝╚══██╔══╝    ██╔══██╗██║     ██╔══██╗
echo  ╚████╔╝    ██║       ██║  ██║██║     ██║  ██║
echo   ╚██╔╝     ██║       ██║  ██║██║     ██║  ██║
echo    ██║      ██║       ██████╔╝███████╗██████╔╝
echo    ╚═╝      ╚═╝       ╚═════╝ ╚══════╝╚═════╝ 
echo                 YT DLD
echo                              By Kratostia
echo.
echo ==================== MENÚ PRINCIPAL =========================
echo [1] Descargar vídeo (URL directa)
echo [2] Descargar vídeo con cookies
echo [3] Extraer audio en MP3
echo [4] Descargar lista de reproducción
echo [5] Elegir calidad de vídeo
echo [6] Instalar/Actualizar dependencias
echo [7] Salir
echo =============================================================
set /p opcion=Selecciona una opción (1-7): 

if "%opcion%"=="1" goto solo_url
if "%opcion%"=="2" goto url_con_cookies
if "%opcion%"=="3" goto audio_mp3
if "%opcion%"=="4" goto playlist
if "%opcion%"=="5" goto calidad
if "%opcion%"=="6" goto instalar_dependencias
if "%opcion%"=="7" exit
goto inicio

:check_ffmpeg
where ffmpeg > nul 2>&1
if %errorlevel% NEQ 0 (
    echo ffmpeg no esta instalado. Algunas funciones pueden fallar.
    echo Deseas instalarlo ahora? (s/n)
    set /p instalarffmpeg=Opcion: 
    if /i "!instalarffmpeg!"=="s" (
        goto instalar_dependencias
    )
)
goto:eof

:solo_url
cls
call :check_ffmpeg
echo Introduce la URL del video a descargar:
set /p video_url=URL: 
%YTDLP% "%video_url%"
pause
goto inicio

:url_con_cookies
cls
call :check_ffmpeg
echo Introduce la URL del video a descargar:
set /p video_url=URL: 
echo Introduce la ruta del archivo de cookies (ej: C:\cookies.txt):
set /p cookie_file=Ruta cookies: 
%YTDLP% --cookies "%cookie_file%" "%video_url%"
pause
goto inicio

:audio_mp3
cls
call :check_ffmpeg
echo Introduce la URL del video para extraer el audio:
set /p video_url=URL: 
echo Deseas usar un archivo de cookies? (s/n)
set /p usar_cookies=Opcion: 
set "usar_cookies=!usar_cookies:~0,1!"

if /i "!usar_cookies!"=="s" (
    echo Introduce la ruta del archivo de cookies:
    set /p cookie_file=Ruta cookies: 
    %YTDLP% --cookies "%cookie_file%" -x --audio-format mp3 "%video_url%"
) else (
    %YTDLP% -x --audio-format mp3 "%video_url%"
)
pause
goto inicio

:playlist
cls
call :check_ffmpeg
echo Introduce la URL de la lista de reproduccion:
set /p lista_url=URL: 
%YTDLP% "%lista_url%"
pause
goto inicio

:calidad
cls
call :check_ffmpeg
echo Introduce la URL del video:
set /p video_url=URL: 
echo Deseas usar un archivo de cookies? (s/n)
set /p usar_cookies=Opcion: 
set "usar_cookies=!usar_cookies:~0,1!"

if /i "!usar_cookies!"=="s" (
    echo Introduce la ruta del archivo de cookies:
    set /p cookie_file=Ruta cookies: 
    %YTDLP% --cookies "%cookie_file%" -F "%video_url%"
    echo Introduce el ID del formato deseado:
    set /p formato_id=ID: 
    %YTDLP% --cookies "%cookie_file%" -f %formato_id% "%video_url%"
) else (
    %YTDLP% -F "%video_url%"
    echo Introduce el ID del formato deseado:
    set /p formato_id=ID: 
    %YTDLP% -f %formato_id% "%video_url%"
)
pause
goto inicio

:instalar_dependencias
cls
set instalar_ffmpeg=0
set instalar_ytdlp=0

if not exist "%YTDLP%" (
    set instalar_ytdlp=1
)
if not exist "%FFMPEG_EXE%" (
    set instalar_ffmpeg=1
)

if %instalar_ytdlp%==1 (
    echo Descargando yt-dlp...
    call :download_with_progress https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe yt-dlp.exe
)

if %instalar_ffmpeg%==1 (
    echo Descargando ffmpeg...
    call :download_with_progress https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip ffmpeg.zip
    powershell -Command "Expand-Archive -Path ffmpeg.zip -DestinationPath ffmpeg-bin"
    del ffmpeg.zip > nul
)

if %instalar_ytdlp%==0 (
    echo Actualizando yt-dlp...
    %YTDLP% -U
)

echo Dependencias instaladas o actualizadas correctamente.
pause
goto inicio