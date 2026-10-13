-- Optional: automatic WhatsApp reminders. Run AFTER deploying the send-reminders function.
-- Replace YOUR-PROJECT and YOUR_SECRET (same value you saved as CRON_SECRET). 03:30 UTC = 9:00 AM IST daily.
create extension if not exists pg_cron;
create extension if not exists pg_net;
select cron.schedule('daily-reminders','30 3 * * *', $$
  select net.http_post(
    url := 'https://YOUR-PROJECT.supabase.co/functions/v1/send-reminders',
    headers := '{"x-cron-secret":"YOUR_SECRET"}'::jsonb
  ) $$);
