# Setup guide (no coding experience needed)

You do **not** need a paid plan. Everything below works on free plans. Total time: about 30–40 minutes.

You will use three services:
- **Supabase**: stores patient data and handles the doctor's login (the "backend").
- **Netlify**: puts the website on the internet (the "hosting").
- **GitHub**: keeps a backup of the code (see `GITHUB.md`).

---
## Part 1: Create the database (Supabase)

1. Go to **supabase.com** → **Start your project** → sign in (GitHub or email).
2. Click **New project**. Fill in:
   - Name: `doctors-clinic`
   - Database password: click **Generate** and **save it in a password manager**
   - Region: **South Asia (Mumbai)** or Singapore
   - Plan: **Free**
3. Wait 1–2 minutes until the project is ready.
4. In the left menu click **SQL Editor** → **New query**.
5. Open `supabase/schema.sql` from this folder, copy **everything**, paste it in the editor and click **Run**. You should see "Success. No rows returned".
6. Left menu → **Table Editor**: you should see `appointments` and `messages`. Both will show a "RLS enabled" tag. That is the security lock.

## Part 2: Create the doctor's login

1. Left menu → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Email: `salikrafiq@gmail.com`. Password: a strong one (12+ characters, not `doctor123`). Tick **Auto Confirm User**. Click **Create**.
3. Go to **Authentication** → **Sign In / Providers** → open **Email**. Turn **"Allow new users to sign up" OFF** and save. This stops anyone else creating an account.
4. (For the "email me a code" option to arrive reliably) **Authentication** → **Emails/SMTP** → set up a sender (for example a free Brevo or Resend account). The password login works without this.

## Part 3: Connect the website to your database

1. In Supabase: **Project Settings** (gear icon) → **API**.
2. Copy the **Project URL** and the **anon public** key.
3. Open `index.html` in Notepad (or VS Code) and find this line near the top of the script:
   `const SB_URL='PASTE_PROJECT_URL',SB_KEY='PASTE_ANON_KEY';`
   Replace both values with what you copied (keep the quotes). Save.
   > The anon key is designed to be public. Your data is protected by the database security rules, not by hiding this key.
   > **Never** paste the `service_role` key into `index.html` or GitHub.

## Part 4: Put it online (Netlify)

1. Go to **app.netlify.com** → sign up (free).
2. **Add new site** → **Deploy manually**. Drag in a folder that contains your edited `index.html`. (A folder with just that one file is fine.)
3. Netlify gives you a link like `random-name.netlify.app`. Open it.
4. **Site configuration → Change site name** to something nicer, for example `doctorsclinic-srinagar`.
5. Back in Supabase: **Authentication → URL Configuration** → set **Site URL** to your Netlify link.
6. Optional: buy a domain (GoDaddy, Namecheap, Hostinger) and add it under Netlify → **Domain management**. HTTPS is automatic.

## Part 5: Test everything

1. On your phone, open the site and book an appointment, then send a consultation message.
2. Open `your-site/#staff` (or the small **Staff** link in the footer) and sign in as the doctor.
3. The booking should appear. Press ✓ to confirm it. Reply to the message.
4. Back on the phone, check that the status changed to Confirmed and the reply shows.
5. Try signing in with a wrong password; it should fail.

---
## Part 6: Reminders

### Option A: One-click WhatsApp reminder (works now, free)
In the doctor dashboard, every appointment has a green **WhatsApp** button. It opens WhatsApp with a ready-made reminder to that patient. The doctor or receptionist just presses Send. No setup needed.

### Option B: Automatic WhatsApp reminders (optional)
Sends a message by itself at 9:00 AM the day before every **Confirmed** appointment.
> Why WhatsApp and not SMS? In India, bulk SMS requires DLT registration (TRAI), which takes days. WhatsApp Cloud API is simpler to start.

1. Go to **developers.facebook.com** → **My Apps → Create App** → type **Business** → add the **WhatsApp** product. You also need a Meta Business account.
2. In **WhatsApp → API Setup** note the **Phone number ID** and create a **permanent access token** (System User in Business Settings).
3. In **WhatsApp Manager → Message templates → Create template**: category **Utility**, name `appointment_reminder`, language English, body:
   `Hello {{1}}, this is a reminder from Doctors Clinic (Dr. Abdul Rafiq). Your appointment is on {{2}} at {{3}}. Qamawari Chowk, near D&D Mall. Reply to this message to reschedule.`
   Wait for approval (usually minutes to a day).
4. In Supabase → **Edge Functions → Deploy a new function → Via Editor**. Name it `send-reminders`, paste `supabase/functions/send-reminders/index.ts`, and **turn "Verify JWT" OFF**. Deploy.
5. **Edge Functions → Secrets**, add: `WA_PHONE_ID`, `WA_TOKEN`, and `CRON_SECRET` (any long random text).
6. Open `supabase/reminders-cron.sql`, replace `YOUR-PROJECT` and `YOUR_SECRET`, paste it in the SQL Editor and Run.
7. To test: Edge Functions → `send-reminders` → Test with header `x-cron-secret: <your secret>` while a Confirmed appointment exists for tomorrow.
> Patients must be reachable on WhatsApp on their phone number. Meta charges small per-message fees after a free monthly allowance.

---
## Keeping it secure (checklist)
- [ ] Strong, unique password for the doctor account (and for Supabase, Netlify and GitHub)
- [ ] Sign-ups turned off in Supabase
- [ ] `service_role` key, WhatsApp token and database password never saved in GitHub
- [ ] Two-factor authentication on your Supabase, Netlify and GitHub accounts
- [ ] Only the doctor's device is used for the dashboard; always press **Sign out**
- [ ] Add a privacy policy page before real patients use the site
