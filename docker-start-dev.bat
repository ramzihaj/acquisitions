@echo off
REM Docker Development Start Script (Windows)
REM This script starts the development environment with Neon Local

echo.
echo Starting Acquisitions Development Environment...
echo ==================================================

REM Check if .env.development exists
if not exist .env.development (
    echo Warning: .env.development not found!
    echo Creating from .env...
    
    if exist .env (
        copy .env .env.development
        echo Created .env.development - please review settings
        echo Note: Update DATABASE_URL to: postgres://postgres:postgres@neon-local:5432/main
    ) else (
        echo Error: .env file not found. Please create .env.development manually.
        exit /b 1
    )
)

REM Stop any existing containers
echo.
echo Stopping any existing containers...
docker-compose -f docker-compose.dev.yml down

REM Start services
echo.
echo Building and starting services...
docker-compose -f docker-compose.dev.yml up --build -d

REM Wait for services
echo.
echo Waiting for services to start...
timeout /t 5 /nobreak >nul

REM Check service status
echo.
echo Service Status:
docker-compose -f docker-compose.dev.yml ps

REM Show logs
echo.
echo Recent logs:
docker-compose -f docker-compose.dev.yml logs --tail=20

echo.
echo ===============================================
echo Development environment is running!
echo ===============================================
echo Application: http://localhost:3000
echo Health Check: http://localhost:3000/health
echo View logs: docker-compose -f docker-compose.dev.yml logs -f
echo Stop: docker-compose -f docker-compose.dev.yml down
echo ===============================================
