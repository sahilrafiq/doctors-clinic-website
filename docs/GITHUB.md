# Putting this project on GitHub

## Easiest way: upload in the browser
1. Sign up or log in at **github.com**.
2. Click **+** (top right) → **New repository**.
   - Repository name: `doctors-clinic-website`
   - Description: `Dental clinic website with online booking, patient tracking and secure doctor dashboard (Supabase)`
   - Choose **Public** (for your portfolio) and leave "Add a README" **unchecked**.
   - Click **Create repository**.
3. Click **uploading an existing file**.
4. Unzip `doctors-clinic-repo.zip` on your computer, open the folder, select **everything inside it** (`index.html`, `README.md`, `LICENSE`, `.gitignore`, `docs`, `supabase`) and drag it into the browser page.
   > Hidden files like `.gitignore` may not show: on Windows tick *View → Hidden items*, on Mac press Cmd+Shift+. 
5. Type the commit message `Initial commit` and click **Commit changes**.
6. Your README now appears on the repo's front page.

## Before you make it public: safety check
- In `index.html` keep `PASTE_PROJECT_URL` / `PASTE_ANON_KEY` in the GitHub copy and put your real values only in the copy you upload to Netlify. (The anon key is public by design, but this keeps the repo clean and re-usable.)
- Search the files for `service_role`, `WA_TOKEN` or any password. There must be none.
- Use fake names and numbers in any screenshots.

## Using the command line instead (optional)
```bash
cd doctors-clinic-repo
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/doctors-clinic-website.git
git push -u origin main
```

## Make the repo look professional
- On the repo page click the gear next to **About** → add the website link and topics: `dental`, `healthcare`, `supabase`, `appointment-booking`, `javascript`.
- Add 2–3 screenshots to the README (drag images into the README editor).
- Pin the repository on your GitHub profile.
- Keep working in small commits so the history shows real progress.
