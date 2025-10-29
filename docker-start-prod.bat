@echo off
REM Docker Production Start Script (Windows)
REM This script starts the production environment with Neon Cloud

echo.
echo Starting Acquisitions Production Environment...
echo ==================================================

REM Check if .env.production exists
if not exist .env.production (
    echo Error: .env.production not found!
    echo.
    echo Please create .env.production with the following variables:
    echo   NODE_ENV=production
    echo   PORT=3000
    echo   LOG_LEVEL=info
    echo   DATABASE_URL=^<your-neon-cloud-url^>
    echo   ARCJET_KEY=^<your-arcjet-key^>
    echo.
    exit /b 1
)

REM Stop any existing containers
echo.
echo Stopping any existing containers...
docker-compose -f docker-compose.prod.yml down

REM Start services
echo.
echo Building and starting production services...
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d

REM Wait for services
echo.
echo Waiting for services to start...
timeout /t 10 /nobreak >nul

REM Check service status
echo.
echo Service Status:
docker-compose -f docker-compose.prod.yml ps

REM Test health endpoint
echo.
echo Testing health endpoint...
timeout /t 2 /nobreak >nul
curl -s http://localhost:3000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo Health check passed!
) else (
    echo Warning: Health check failed - check logs for details
)

REM Show logs
echo.
echo Recent logs:
docker-compose -f docker-compose.prod.yml logs --tail=20

echo.
echo ===============================================
echo Production environment is running!
echo ===============================================
echo Application: http://localhost:3000
echo Health Check: http://localhost:3000/health
echo View logs: docker-compose -f docker-compose.prod.yml logs -f
echo Stop: docker-compose -f docker-compose.prod.yml down
echo ===============================================
