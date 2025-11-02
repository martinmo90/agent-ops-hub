import { test, expect } from '@playwright/test';

const APP_URL = process.env.OPS_DASHBOARD_URL ?? 'http://localhost:4000';

test.describe('Ops Dashboard Smoke Tests', () => {
  test('should load the overview page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Check for main heading
    await expect(page.locator('h1').first()).toContainText('Agent Ops');

    // Check for KPI cards
    await expect(page.getByText('Active Tasks')).toBeVisible();
    await expect(page.getByText('Blocked')).toBeVisible();
    await expect(page.getByText('Merges Today')).toBeVisible();

    // Check for recommended actions section
    await expect(page.getByText('Recommended Actions')).toBeVisible();
  });

  test('should navigate to Tasks page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Click on Tasks in sidebar
    await page.getByRole('link', { name: /tasks/i }).first().click();

    // Verify we're on the tasks page
    await expect(page.locator('h1')).toContainText('Tasks');
    await expect(page.getByText('All Tasks')).toBeVisible();
  });

  test('should navigate to Approvals page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Click on Approvals in sidebar
    await page.getByRole('link', { name: /approvals/i }).click();

    // Verify we're on the approvals page
    await expect(page.locator('h1')).toContainText('Approvals');
    await expect(page.getByText('Pending Approvals')).toBeVisible();
  });

  test('should navigate to Artifacts page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Click on Artifacts in sidebar
    await page.getByRole('link', { name: /artifacts/i }).click();

    // Verify we're on the artifacts page
    await expect(page.locator('h1')).toContainText('Artifacts');
    await expect(page.getByText('Latest Artifacts')).toBeVisible();
  });

  test('should navigate to Runs & Logs page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Click on Runs & Logs in sidebar
    await page.getByRole('link', { name: /runs/i }).click();

    // Verify we're on the runs page
    await expect(page.locator('h1')).toContainText('Runs & Logs');
    await expect(page.getByText('Recent Runs')).toBeVisible();
  });

  test('should navigate to Settings page', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Click on Settings in sidebar
    await page.getByRole('link', { name: /settings/i }).click();

    // Verify we're on the settings page
    await expect(page.locator('h1')).toContainText('Settings');
    await expect(page.getByText('General')).toBeVisible();
  });

  test('should display dark theme by default', async ({ page }) => {
    await page.goto(APP_URL, { waitUntil: 'networkidle' });

    // Check that dark mode is applied
    const htmlElement = page.locator('html');
    await expect(htmlElement).toHaveClass(/dark/);
  });
});
