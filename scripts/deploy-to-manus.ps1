# LifeQuest Deployment Script for Manus
# Connects Claude Code → Build → Manus Deploy

param(
    [string]$Environment = "production",
    [switch]$SkipBuild = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"

# Configuration
$PROJECT_NAME = "lifequest"
$BUILD_DIR = "build\web"
$MANUS_URL = "https://lifequest-dduv2x5v.manus.space"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "╔════════════════════════════════════════════╗"
Write-Info "║   LifeQuest Deployment to Manus           ║"
Write-Info "║   Environment: $Environment                    ║"
Write-Info "╚════════════════════════════════════════════╝"
Write-Host ""

# Step 1: Verify prerequisites
Write-Info "📋 Checking prerequisites..."

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Flutter not found! Install Flutter first."
    exit 1
}

$flutterVersion = flutter --version | Select-String -Pattern "Flutter (\d+\.\d+\.\d+)"
Write-Success "✅ Flutter found: $($flutterVersion.Matches.Groups[1].Value)"

# Step 2: Check Firebase configuration
if (Test-Path "lib\firebase_options.dart") {
    Write-Success "✅ Firebase configuration found"
} else {
    Write-Warning "⚠️  Firebase configuration missing"
}

# Step 3: Build Flutter web app
if (-not $SkipBuild) {
    Write-Info "`n📦 Building Flutter web application..."
    
    # Clean previous build
    Write-Info "   Cleaning previous build..."
    flutter clean | Out-Null
    
    # Get dependencies
    Write-Info "   Fetching dependencies..."
    flutter pub get
    
    # Build for web
    Write-Info "   Building release version..."
    $buildStart = Get-Date
    flutter build web --release --web-renderer html
    $buildEnd = Get-Date
    $buildTime = ($buildEnd - $buildStart).TotalSeconds
    
    Write-Success "✅ Build completed in $([math]::Round($buildTime, 2)) seconds"
} else {
    Write-Info "⏭️  Skipping build (using existing build)"
}

# Step 4: Verify build output
if (-not (Test-Path $BUILD_DIR)) {
    Write-Error "❌ Build directory not found: $BUILD_DIR"
    exit 1
}

$buildSize = (Get-ChildItem -Path $BUILD_DIR -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Info "📊 Build size: $([math]::Round($buildSize, 2)) MB"

# Step 5: Deploy to Manus
Write-Info "`n🚀 Deploying to Manus..."

# Check deployment method
$deploymentMethod = "unknown"

# Method 1: Check for Manus CLI
if (Get-Command manus -ErrorAction SilentlyContinue) {
    Write-Info "   Using Manus CLI..."
    $deploymentMethod = "cli"
    
    try {
        manus deploy --project=$PROJECT_NAME --source=$BUILD_DIR
        Write-Success "✅ Deployed via Manus CLI"
    } catch {
        Write-Error "❌ Manus CLI deployment failed: $_"
        $deploymentMethod = "failed"
    }
}

# Method 2: Check for Manus API key
elseif ($env:MANUS_API_KEY) {
    Write-Info "   Using Manus API..."
    $deploymentMethod = "api"
    
    try {
        $headers = @{
            "Authorization" = "Bearer $env:MANUS_API_KEY"
            "Content-Type" = "application/json"
        }
        
        $body = @{
            project = $PROJECT_NAME
            environment = $Environment
            source = $BUILD_DIR
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri "https://api.manus.space/v1/deploy" `
                                      -Method POST `
                                      -Headers $headers `
                                      -Body $body
        
        Write-Success "✅ Deployed via Manus API"
        Write-Info "   Deployment ID: $($response.deploymentId)"
    } catch {
        Write-Error "❌ Manus API deployment failed: $_"
        $deploymentMethod = "failed"
    }
}

# Method 3: Check for Git-based deployment
elseif ($env:MANUS_GIT_URL) {
    Write-Info "   Using Git deployment..."
    $deploymentMethod = "git"
    
    try {
        Push-Location $BUILD_DIR
        
        if (-not (Test-Path ".git")) {
            git init
            git remote add manus $env:MANUS_GIT_URL
        }
        
        git add .
        git commit -m "Deploy from Claude Code - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git push manus main --force
        
        Pop-Location
        Write-Success "✅ Deployed via Git"
    } catch {
        Pop-Location
        Write-Error "❌ Git deployment failed: $_"
        $deploymentMethod = "failed"
    }
}

# Method 4: Manual deployment instructions
else {
    Write-Warning "`n⚠️  Automatic deployment not configured"
    Write-Info "`n📋 Manual Deployment Options:"
    Write-Info ""
    Write-Info "   Option 1 - Manus CLI:"
    Write-Info "   1. Install: npm install -g @manus/cli"
    Write-Info "   2. Login: manus login"
    Write-Info "   3. Deploy: manus deploy --project=$PROJECT_NAME"
    Write-Info ""
    Write-Info "   Option 2 - Manus API:"
    Write-Info "   1. Get API key from Manus dashboard"
    Write-Info "   2. Set: `$env:MANUS_API_KEY='your-key'"
    Write-Info "   3. Re-run this script"
    Write-Info ""
    Write-Info "   Option 3 - Manual Upload:"
    Write-Info "   1. Open Manus dashboard"
    Write-Info "   2. Upload contents of: $BUILD_DIR"
    Write-Info ""
    Write-Info "   Option 4 - Git Deployment:"
    Write-Info "   1. Set: `$env:MANUS_GIT_URL='your-git-url'"
    Write-Info "   2. Re-run this script"
    Write-Info ""
    
    $deploymentMethod = "manual"
}

# Step 6: Verify deployment
if ($deploymentMethod -ne "manual" -and $deploymentMethod -ne "failed") {
    Write-Info "`n🔍 Verifying deployment..."
    Start-Sleep -Seconds 5
    
    try {
        $response = Invoke-WebRequest -Uri $MANUS_URL -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "✅ Deployment verified! Site is accessible"
        } else {
            Write-Warning "⚠️  Site returned status: $($response.StatusCode)"
        }
    } catch {
        Write-Warning "⚠️  Could not verify deployment (this might be normal during DNS propagation)"
    }
}

# Step 7: Summary
Write-Info "`n╔════════════════════════════════════════════╗"
Write-Info "║           Deployment Summary              ║"
Write-Info "╚════════════════════════════════════════════╝"
Write-Info ""
Write-Info "   Project:     $PROJECT_NAME"
Write-Info "   Environment: $Environment"
Write-Info "   Build Size:  $([math]::Round($buildSize, 2)) MB"
Write-Info "   Method:      $deploymentMethod"
Write-Info "   URL:         $MANUS_URL"
Write-Info ""

if ($deploymentMethod -eq "cli" -or $deploymentMethod -eq "api" -or $deploymentMethod -eq "git") {
    Write-Success "🎉 Deployment completed successfully!"
    Write-Info "`n🌐 Your app should be live at:"
    Write-Success "   $MANUS_URL"
    Write-Info "`n📊 Next steps:"
    Write-Info "   • Visit the URL to verify"
    Write-Info "   • Check Manus dashboard for logs"
    Write-Info "   • Test all features in production"
} elseif ($deploymentMethod -eq "manual") {
    Write-Warning "⚠️  Manual deployment required"
    Write-Info "`n   See instructions above for deployment options"
} else {
    Write-Error "❌ Deployment failed"
    Write-Info "`n   Check error messages above for details"
    exit 1
}

Write-Info ""
Write-Success "✨ Done!"
