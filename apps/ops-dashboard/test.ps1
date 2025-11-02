#!/usr/bin/env pwsh
# test.ps1 - Run tests for Ops Dashboard

Write-Host "Running Ops Dashboard tests..." -ForegroundColor Cyan

# Build the application first
Write-Host "Building application..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!" -ForegroundColor Green

    # Run Playwright tests from root
    Write-Host "Running smoke tests..." -ForegroundColor Yellow
    Set-Location ../..
    npx playwright test tests/ops-dashboard-smoke.spec.ts

    if ($LASTEXITCODE -eq 0) {
        Write-Host "All tests passed!" -ForegroundColor Green
    } else {
        Write-Host "Tests failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
