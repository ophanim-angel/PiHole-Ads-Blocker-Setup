@echo off
REM Pi-hole Docker Quick Start Script for Windows
REM This script provides easy commands to manage Pi-hole

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Colors are not supported in batch, using text instead
set "CMD=%1"
if "!CMD!"=="" set "CMD=help"

goto !CMD!

:start
echo [Pi-hole] Starting Pi-hole container...
docker-compose up -d
echo [Pi-hole] Pi-hole is starting. Access it at: http://localhost/admin
echo [WARNING] Default password: admin123 (change it immediately!)
goto end

:stop
echo [Pi-hole] Stopping Pi-hole container...
docker-compose down
echo [Pi-hole] Pi-hole stopped.
goto end

:restart
echo [Pi-hole] Restarting Pi-hole container...
docker-compose restart pihole
echo [Pi-hole] Pi-hole restarted.
goto end

:logs
echo [Pi-hole] Showing Pi-hole logs...
docker-compose logs -f pihole
goto end

:status
echo [Pi-hole] Pi-hole container status:
docker-compose ps pihole
goto end

:clean
echo [WARNING] This will remove all Pi-hole data!
set /p confirm="Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    docker-compose down -v
    rmdir /s /q etc-pihole 2>nul
    rmdir /s /q etc-dnsmasq.d 2>nul
    echo [Pi-hole] Pi-hole cleaned up.
) else (
    echo [Pi-hole] Cleanup cancelled.
)
goto end

:rebuild
echo [Pi-hole] Rebuilding Pi-hole container...
docker-compose build --no-cache pihole
docker-compose up -d pihole
echo [Pi-hole] Pi-hole rebuilt and started.
goto end

:help
echo Pi-hole Docker Quick Start for Windows
echo.
echo Usage: pihole.bat [command]
echo.
echo Commands:
echo   start     - Start Pi-hole container
echo   stop      - Stop Pi-hole container
echo   restart   - Restart Pi-hole container
echo   logs      - Show Pi-hole logs (follow mode)
echo   status    - Show container status
echo   rebuild   - Rebuild and restart container
echo   clean     - Remove container and all data
echo   help      - Show this help message
echo.
echo Examples:
echo   pihole.bat start
echo   pihole.bat logs
echo   pihole.bat status
goto end

:end
endlocal
