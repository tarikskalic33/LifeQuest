# LifeQuest Deployment to Manus - Simple Version
param(
    [switch]$SkipBuild = $false
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   LifeQuest Deployment to Manus" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$PROJECT_NAME = "lifequest"
$BUILD_DIR = "build\web"
$MANUS_URL = "https://lifequest-dduv2x5v.manus.space"

# Check Flutter
Write-Host "Checking Flutter..." -ForegroundColor Yellow
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter not found!" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Flutter found" -ForegroundColor Green
Write-Host ""

# Build if needed
if (!$SkipBuild) {
    Write-Host "Building Flutter web app..." -ForegroundColor Yellow
    flutter clean
    flutter pub get
    flutter build web --release
    Write-Host "OK: Build complete" -ForegroundColor Green
} else {
    Write-Host "Skipping build (using existing)" -ForegroundColor Yellow
}
Write-Host ""

# Check build output
if (!(Test-Path $BUILD_DIR)) {
    Write-Host "ERROR: Build directory not found: $BUILD_DIR" -ForegroundColor Red
    exit 1
}
Write-Host "OK: Build directory exists" -ForegroundColor Green
Write-Host ""

# Deployment
Write-Host "Checking deployment method..." -ForegroundColor Yellow
Write-Host ""

$deployed = $false

# Try Manus CLI
if (Get-Command manus -ErrorAction SilentlyContinue) {
    Write-Host "Using Manus CLI..." -ForegroundColor Cyan
    manus deploy --project=$PROJECT_NAME --source=$BUILD_DIR
    $deployed = $true
}
# Try API
elseif ($env:MANUS_API_KEY) {
    Write-Host "Using Manus API..." -ForegroundColor Cyan
    try {
        $headers = @{"Authorization" = "Bearer $env:MANUS_API_KEY"}
        $body = @{project=$PROJECT_NAME; source=$BUILD_DIR} | ConvertTo-Json
        Invoke-RestMethod -Uri "https://api.manus.space/v1/deploy" -Method POST -Headers $headers -Body $body
        $deployed = $true
    } catch {
        Write-Host "ERROR: API deployment failed - $_" -ForegroundColor Red
    }
}
# Manual instructions
else {
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host "   MANUAL DEPLOYMENT REQUIRED" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "No automatic deployment configured." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Manus CLI:" -ForegroundColor White
    Write-Host "   npm install -g @manus/cli" -ForegroundColor Gray
    Write-Host "   manus login" -ForegroundColor Gray
    Write-Host "   manus deploy" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Manus API:" -ForegroundColor White
    Write-Host "   Get API key from Manus dashboard" -ForegroundColor Gray
    Write-Host "   Set: `$env:MANUS_API_KEY='your-key'" -ForegroundColor Gray
    Write-Host "   Re-run this script" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Manual Upload:" -ForegroundColor White
    Write-Host "   Open: https://manus.space/dashboard" -ForegroundColor Gray
    Write-Host "   Upload: $BUILD_DIR" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Build ready at: $BUILD_DIR" -ForegroundColor Cyan
    Write-Host ""
}

if ($deployed) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "URL: $MANUS_URL" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Verifying..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    try {
        $response = Invoke-WebRequest -Uri $MANUS_URL -Method Head -TimeoutSec 10
        Write-Host "OK: Site is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "WARNING: Could not verify (may need DNS propagation)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
