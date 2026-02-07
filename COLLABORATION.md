# 💎 Jewelry Project: Development Roadmap & Requirements

This guide outlines exactly what needs to be built and how you will work together to ensure a smooth launch.

---

## 🛠️ Syncing Your Local Environment (IMPORTANT)
The project structure has been **flattened**. Everything that was inside the `Admin/` folder is now in the **root** directory.

### How to update your local laptop:
1. **Save your `.env`**: Copy your existing `.env` content somewhere safe.
2. **Fetch and Reset**: To avoid "folder moved" conflicts, run these commands in your terminal:
   ```bash
   git fetch origin
   git reset --hard origin/main
   ```
3. **Restore `.env`**: Create a new `.env` file in the **root** folder and paste your settings back.
4. **Run Server**:
   ```bash
   php artisan serve
   ```
   *Your site will now be at `http://127.0.0.1:8000` (No more `/admin` folder prefix in the URL needed).*

---

## 🏆 Module 1: Gold Savings SIP Scheme (Aditya)
**Goal:** Allow users to invest small amounts periodically to accumulate gold.

### Key Features:
1. **KYC Verification**: Users must upload ID proof (PAN/Aadhar) before starting a SIP.
2. **SIP Plan Selection**:
   - Monthly investment (e.g., ₹1000/month)
   - Daily investment options
   - Fixed period (e.g., 11 months + 1 month bonus)
3. **Automated Gold Purchase**: On successful payment, convert the amount to gold grams based on the **Live Gold Rate**.
4. **SIP Dashboard**: User view of total accumulated grams and transaction history.
5. **Admin SIP Management**: Monitor all active subscriptions and verify KYC documents.

---

## 🚀 Module 2: Metal API & Rate Management (Friend)
**Goal:** Provide real-time pricing foundation for the entire platform using **[MetalPriceAPI](https://metalpriceapi.com/documentation)**.

### Key Features:
1. **Live Rate Integration**: Connect to `https://api.metalpriceapi.com/v1/latest` to fetch rates.
   - Symbols: `XAU` (Gold), `XAG` (Silver), `XPT` (Platinum).
   - Use the `carat` endpoint (`/v1/carat`) for specific gold purities (24K, 22K, 18K).
2. **Manual Rate Overwrite**: Admin panel to manually set rates in case of API failure or local premiums.
3. **Product Price Formula**: Update the product system to calculate dynamic price:
   `Price = (Metal Weight * Live Rate) + Making Charges + Tax`
4. **Metal Rate Widget**: A widget for the Flutter home screen showing current market rates.
5. **Rate History**: Use the `/v1/historical` or `/v1/timeframe` endpoints for trend analysis.

---

## 🏗️ The "Local First" Workflow (CRITICAL)

> [!IMPORTANT]
> **Always test locally first!**
> Do not deploy directly to the Hostinger server without local verification.

### Professional Workflow:
1.  **Develop Locally**: Run `php artisan serve` and your Flutter emulator.
2.  **Test Locally**: Ensure your feature works and doesn't break existing features.
3.  **Commit & Push**: Push to your feature branch on GitHub.
4.  **Merge**: Create a Pull Request into `main`.
5.  **Deploy**: Once `main` is updated, pull the code to Hostinger for the final live test.

---

## 📂 Conflict Prevention Strategy

| Resource | Who Touches It? | How to stay safe? |
|----------|-----------------|-------------------|
| **Database** | Both | Always use **Migrations**. Never share SQL dumps. |
| **Routes** | Both | Keep SIP routes in `routes/api/v1/sip.php` and Metal routes in `routes/api/v1/metal.php`. |
| **Product Model** | Both | Use Laravel **Traits** to add functionalities separately. |
| **Flutter Providers** | Both | Create separate `SipProvider` and `MetalProvider`. |

---

## 📅 Immediate Next Steps

1.  **Aditya**: Start by creating the `KycDocument` and `SipPlan` database migrations.
2.  **Friend**: Create the `MetalRate` table and the Admin UI to update these rates manually.
3.  **Both**: Share the `MetalRate` model access so Aditya can use it for SIP calculations.
