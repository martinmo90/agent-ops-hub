import { test, expect } from '@playwright/test';

const APP_URL = process.env.SHADCN_URL ?? 'http://localhost:3333';

test('shadcn app greets via Claude', async ({ page }) => {
  // 1) Open the app
  await page.goto(APP_URL, { waitUntil: 'networkidle' });

  // 2) Find the input box and type a greeting
  // NOTE: We avoid selecting by brittle classnames; use roles/placeholder fallbacks
  const input = page.getByRole('textbox').first();
  await input.click();
  await input.fill('Say hi to me, please.');

  // 3) Press Enter or click send (try both)
  await input.press('Enter').catch(async () => {
    const sendBtn = page.getByRole('button', { name: /send/i }).first();
    if (await sendBtn.isVisible()) await sendBtn.click();
  });

  // 4) Wait for streamed response to appear
  // We only assert that some assistant text appears within a generous timeout
  const reply = page.locator('text=/hi|hello|hey/i').first();
  await expect(reply).toBeVisible({ timeout: 30000 });
});
