# LifeQuest Helper Script
# Quick commands for working with Claude Code and deployment

Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        LifeQuest Development Helper       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$projectDir = "C:\Users\wsk\Documents\lqq\Life-Quest-Alpha-df"

function Show-Menu {
    Write-Host "Available Commands:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Deploy to Manus" -ForegroundColor Green
    Write-Host "  2. Build Web Version" -ForegroundColor Green
    Write-Host "  3. Run Locally" -ForegroundColor Green
    Write-Host "  4. Run Tests" -ForegroundColor Green
    Write-Host "  5. Check Deployment Status" -ForegroundColor Green
    Write-Host "  6. Open in Claude Code Chat" -ForegroundColor Green
    Write-Host "  7. Ask Claude Code a Question" -ForegroundColor Green
    Write-Host "  8. View Project Context" -ForegroundColor Green
    Write-Host "  9. Open Manus Dashboard" -ForegroundColor Green
    Write-Host "  0. Exit" -ForegroundColor Red
    Write-Host ""
}

function Deploy-ToManus {
    Write-Host "`nDeploying to Manus..." -ForegroundColor Cyan
    Set-Location $projectDir
    pwsh scripts\deploy-to-manus.ps1
}

function Build-Web {
    Write-Host "`nBuilding web version..." -ForegroundColor Cyan
    Set-Location $projectDir
    flutter build web --release
}

function Run-Locally {
    Write-Host "`nRunning locally in Chrome..." -ForegroundColor Cyan
    Set-Location $projectDir
    flutter run -d chrome
}

function Run-Tests {
    Write-Host "`nRunning tests..." -ForegroundColor Cyan
    Set-Location $projectDir
    flutter test
}

function Check-Deployment {
    Write-Host "`nChecking deployment status..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "https://lifequest-dduv2x5v.manus.space" -Method Head
        Write-Host "✅ Site is UP! Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Site is DOWN or not found (404)" -ForegroundColor Red
    }
}

function Open-ClaudeChat {
    Write-Host "`nOpening Claude Code chat..." -ForegroundColor Cyan
    Set-Location $projectDir
    claude chat
}

function Ask-Claude {
    $question = Read-Host "`nWhat would you like to ask Claude Code?"
    Write-Host "`nAsking Claude..." -ForegroundColor Cyan
    Set-Location $projectDir
    claude $question
}

function View-Context {
    Write-Host "`nProject Context:" -ForegroundColor Cyan
    Get-Content "$projectDir\.claude\context.md"
}

function Open-ManusDashboard {
    Write-Host "`nOpening Manus dashboard..." -ForegroundColor Cyan
    Start-Process "https://manus.space/dashboard"
}

# Main loop
Set-Location $projectDir

while ($true) {
    Show-Menu
    $choice = Read-Host "Select option (0-9)"
    
    switch ($choice) {
        "1" { Deploy-ToManus }
        "2" { Build-Web }
        "3" { Run-Locally }
        "4" { Run-Tests }
        "5" { Check-Deployment }
        "6" { Open-ClaudeChat }
        "7" { Ask-Claude }
        "8" { View-Context }
        "9" { Open-ManusDashboard }
        "0" { 
            Write-Host "`nGoodbye! 👋" -ForegroundColor Cyan
            exit 
        }
        default {
            Write-Host "`n❌ Invalid option" -ForegroundColor Red
        }
    }
    
    Write-Host "`nPress Enter to continue..." -ForegroundColor Gray
    Read-Host
    Clear-Host
}
