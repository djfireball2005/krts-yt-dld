@echo off
chcp 65001 > nul
title YT-DLP Downloader by Kratostia
setlocal enabledelayedexpansion

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
echo                 YT DL
echo                              By Kratostia
echo.
echo ==================== MENÚ PRINCIPAL =========================
echo [1] Descargar vídeo (URL directa)
echo [2] Descargar vídeo con cookies
echo [3] Extraer audio en MP3
echo [4] Descargar lista de reproducción
echo [5] Elegir calidad de vídeo
echo [6] Instalar ffmpeg
echo [7] Salir
echo =============================================================
set /p opcion=Selecciona una opción (1-7): 

if "%opcion%"=="1" goto solo_url
if "%opcion%"=="2" goto url_con_cookies
if "%opcion%"=="3" goto audio_mp3
if "%opcion%"=="4" goto playlist
if "%opcion%"=="5" goto calidad
if "%opcion%"=="6" goto instalar_ffmpeg
if "%opcion%"=="7" exit
goto inicio

:check_ffmpeg
where ffmpeg > nul 2>&1
if %errorlevel% NEQ 0 (
    echo ffmpeg no está instalado. Algunas funciones pueden fallar.
    echo ¿Deseas instalarlo ahora? (s/n)
    set /p instalarffmpeg=Opción: 
    if /i "!instalarffmpeg!"=="s" (
        goto instalar_ffmpeg
    )
)
goto:eof

:solo_url
cls
color 0B
call :check_ffmpeg
echo Introduce la URL del vídeo a descargar:
set /p video_url=URL: 
echo.
echo ▶️ Descargando...
yt-dlp "%video_url%"
echo.
pause
goto inicio

:url_con_cookies
cls
color 0E
call :check_ffmpeg
echo Introduce la URL del vídeo a descargar:
set /p video_url=URL: 
echo.
echo Introduce la ruta completa del archivo de cookies (ej: C:\cookies.txt):
set /p cookie_file=Ruta cookies: 
echo.
echo ▶️ Descargando con cookies...
yt-dlp --cookies "%cookie_file%" "%video_url%"
echo.
pause
goto inicio

:audio_mp3
cls
color 0D
call :check_ffmpeg
echo Introduce la URL del vídeo del que quieres extraer el audio:
set /p video_url=URL: 
echo ¿Deseas usar un archivo de cookies? (s/n)
set /p usar_cookies=Opción: 
set "usar_cookies=!usar_cookies:~0,1!"

if /i "!usar_cookies!"=="s" (
    echo Introduce la ruta del archivo de cookies:
    set /p cookie_file=Ruta cookies: 
    echo ▶️ Extrayendo audio con cookies...
    yt-dlp --cookies "%cookie_file%" -x --audio-format mp3 "%video_url%"
) else (
    echo ▶️ Extrayendo audio sin cookies...
    yt-dlp -x --audio-format mp3 "%video_url%"
)
echo.
pause
goto inicio

:playlist
cls
color 0C
call :check_ffmpeg
echo Introduce la URL de la lista de reproducción:
set /p lista_url=URL: 
echo.
echo ▶️ Descargando lista completa...
yt-dlp "%lista_url%"
echo.
pause
goto inicio

:calidad
cls
color 0F
call :check_ffmpeg
echo Introduce la URL del vídeo:
set /p video_url=URL: 
echo ¿Deseas usar un archivo de cookies? (s/n)
set /p usar_cookies=Opción: 
set "usar_cookies=!usar_cookies:~0,1!"

if /i "!usar_cookies!"=="s" (
    echo Introduce la ruta del archivo de cookies:
    set /p cookie_file=Ruta cookies: 
    echo Mostrando las opciones de calidad disponibles...
    yt-dlp --cookies "%cookie_file%" -F "%video_url%"
    echo.
    echo Introduce el ID del formato deseado (ej: 22):
    set /p formato_id=ID formato: 
    echo ▶️ Descargando con formato %formato_id%...
    yt-dlp --cookies "%cookie_file%" -f %formato_id% "%video_url%"
) else (
    echo Mostrando las opciones de calidad disponibles...
    yt-dlp -F "%video_url%"
    echo.
    echo Introduce el ID del formato deseado (ej: 22):
    set /p formato_id=ID formato: 
    echo ▶️ Descargando con formato %formato_id%...
    yt-dlp -f %formato_id% "%video_url%"
)
echo.
pause
goto inicio

:instalar_ffmpeg
cls
color 0C
echo Comprobando si ffmpeg ya está instalado...
where ffmpeg > nul 2>&1
if %errorlevel%==0 (
    echo ✔ ffmpeg ya está disponible en el sistema.
    pause
    goto inicio
)

echo ❌ ffmpeg no está instalado.
echo.
echo Descargando ffmpeg (build portable)...
powershell -Command "Invoke-WebRequest -Uri https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip -OutFile ffmpeg.zip"
if not exist ffmpeg.zip (
    echo ❌ Error al descargar ffmpeg. Revisa tu conexión.
    pause
    goto inicio
)

echo Extrayendo ffmpeg...
powershell -Command "Expand-Archive -Path ffmpeg.zip -DestinationPath ffmpeg-bin"
del ffmpeg.zip > nul

for /d %%D in (ffmpeg-bin\ffmpeg-*) do (
    set "ffmpeg_folder=%%D\bin"
    goto found_ffmpeg
)

:found_ffmpeg
echo ffmpeg extraído correctamente.
echo Añadiendo ffmpeg al PATH para esta sesión...
set "PATH=!cd!\%ffmpeg_folder%;%PATH%"

echo ✔ ffmpeg instalado y listo para usar.
pause
goto inicio
