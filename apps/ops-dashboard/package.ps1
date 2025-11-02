#!/usr/bin/env pwsh
# package.ps1 - Build and package Ops Dashboard for deployment

Write-Host "Packaging Ops Dashboard..." -ForegroundColor Cyan

# Clean previous build
if (Test-Path ".next") {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force ".next"
}

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

# Build for production
Write-Host "Building for production..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Package ready in .next/" -ForegroundColor Green
    Write-Host "To start production server: npm run start" -ForegroundColor Cyan
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
