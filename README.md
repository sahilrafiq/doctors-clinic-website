# 🦷 Doctors Clinic: Dental Clinic Website & Patient Portal

A full-stack website for **Doctors Clinic** (Dr. Abdul Rafiq, Qamawari Chowk, Srinagar): a cinematic, hospital-style front page plus online booking, appointment tracking, a consultation message board and a secure doctor dashboard.

## Features
**For patients**
- Responsive, animated clinic website (about, services, location, working hours)
- Online booking with live slot availability (Mon–Sat, 10:00–1:30 and 4:30–7:00)
- Appointment tracking: Requested → Confirmed → Completed, with self-cancel
- Consultation message board with replies from the doctor

**For the doctor (secure admin dashboard)**
- Email + password login, or a one-time email code
- Schedule, today's count, pending confirmations, patient list and visit counts
- Confirm / complete / cancel appointments and reply to patient messages
- One-click WhatsApp reminder button, plus optional automated WhatsApp reminders

## Tech stack
| Layer | Tech |
|---|---|
| Frontend | HTML, CSS, vanilla JavaScript (single file, no build step) |
| Backend | Supabase (PostgreSQL, Auth, Edge Functions, pg_cron) |
| Messaging | WhatsApp Cloud API (Meta) |
| Hosting | Netlify / Vercel / Cloudflare Pages |

## Security design
- **Row Level Security**: only the doctor's authenticated account can read patient data.
- Public visitors can only call validated database functions (`book_appointment`, `send_message`, …) and see their own records through unguessable UUIDs kept on their device.
- Server-side validation: no double-booking (unique index), no Sundays, past dates or invalid slots, and rate limits per phone number.
- Sign-ups disabled, HTML-escaped output against XSS, and admin auto-logout after 10 minutes idle.
- Secrets (WhatsApp token, service key) live only in Supabase secrets, never in this repo.

## Project structure
```
index.html                                   # the whole frontend
supabase/schema.sql                          # tables, security rules, booking functions
supabase/reminders-cron.sql                  # daily reminder schedule (optional)
supabase/functions/send-reminders/index.ts   # WhatsApp reminder job (optional)
docs/SETUP.md                                # step-by-step deployment guide
docs/GITHUB.md                               # how to put this on GitHub
```

## Getting started
Follow **[docs/SETUP.md](docs/SETUP.md)**. In short: create a free Supabase project, run `supabase/schema.sql`, add the doctor user, paste the project URL and anon key into `index.html`, and deploy the folder to Netlify.

## Screenshots
_Add Not added._

## License
MIT. See [LICENSE](LICENSE).
