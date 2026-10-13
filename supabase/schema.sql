-- Doctors Clinic backend. Run once in Supabase > SQL Editor.
create extension if not exists pgcrypto;

create table public.appointments(
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 80),
  phone text not null check (phone ~ '^[0-9]{10}$'),
  service text not null check (char_length(service) <= 80),
  date date not null,
  time text not null,
  note text check (char_length(note) <= 500),
  status text not null default 'Requested' check (status in ('Requested','Confirmed','Completed','Cancelled')),
  reminder_sent boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index one_booking_per_slot on public.appointments(date,time) where status <> 'Cancelled';

create table public.messages(
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 80),
  phone text not null check (phone ~ '^[0-9]{10}$'),
  subject text not null check (char_length(subject) between 1 and 120),
  body text not null check (char_length(body) between 1 and 2000),
  reply text,
  replied_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.appointments enable row level security;
alter table public.messages enable row level security;
revoke all on public.appointments, public.messages from anon;

-- Only the doctor's signed-in account can read or change data directly.
create or replace function public.is_doctor() returns boolean language sql stable as
$$ select coalesce(auth.jwt()->>'email','') = 'salikrafiq@gmail.com' $$;
create policy doctor_all on public.appointments for all to authenticated using (public.is_doctor()) with check (public.is_doctor());
create policy doctor_all on public.messages for all to authenticated using (public.is_doctor()) with check (public.is_doctor());

-- Patients (not signed in) use these narrow, validated functions only.
create or replace function public.book_appointment(p_name text,p_phone text,p_service text,p_date date,p_time text,p_note text)
returns uuid language plpgsql security definer set search_path = public as $$
declare new_id uuid;
begin
  if p_date < (now() at time zone 'Asia/Kolkata')::date then raise exception 'Date is in the past'; end if;
  if extract(dow from p_date) = 0 then raise exception 'Closed on Sundays'; end if;
  if p_time <> all (array['10:00','10:30','11:00','11:30','12:00','12:30','13:00','16:30','17:00','17:30','18:00','18:30']) then raise exception 'Invalid time'; end if;
  if (select count(*) from appointments where phone = p_phone and status in ('Requested','Confirmed')) >= 3 then raise exception 'Too many open appointments for this number'; end if;
  insert into appointments(name,phone,service,date,time,note) values (trim(p_name),p_phone,p_service,p_date,p_time,nullif(trim(p_note),'')) returning id into new_id;
  return new_id;
end $$;

create or replace function public.taken_slots(d date) returns setof text language sql security definer set search_path = public as
$$ select time from appointments where date = d and status <> 'Cancelled' $$;

create or replace function public.my_appointments(ids uuid[]) returns setof public.appointments language sql security definer set search_path = public as
$$ select * from appointments where id = any(ids) $$;

create or replace function public.cancel_appointment(p_id uuid) returns void language sql security definer set search_path = public as
$$ update appointments set status = 'Cancelled' where id = p_id and status in ('Requested','Confirmed') $$;

create or replace function public.send_message(p_name text,p_phone text,p_subject text,p_body text)
returns uuid language plpgsql security definer set search_path = public as $$
declare new_id uuid;
begin
  if (select count(*) from messages where phone = p_phone and created_at > now() - interval '1 day') >= 5 then raise exception 'Daily message limit reached'; end if;
  insert into messages(name,phone,subject,body) values (trim(p_name),p_phone,trim(p_subject),trim(p_body)) returning id into new_id;
  return new_id;
end $$;

create or replace function public.my_messages(ids uuid[]) returns setof public.messages language sql security definer set search_path = public as
$$ select * from messages where id = any(ids) $$;

grant execute on function public.book_appointment, public.taken_slots, public.my_appointments, public.cancel_appointment, public.send_message, public.my_messages to anon, authenticated;
