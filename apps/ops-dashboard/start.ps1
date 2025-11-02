#!/usr/bin/env pwsh
# start.ps1 - Start the Ops Dashboard development server

Write-Host "Starting Ops Dashboard..." -ForegroundColor Cyan

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Start the dev server
Write-Host "Launching dev server on http://localhost:4000" -ForegroundColor Green
npm run dev
