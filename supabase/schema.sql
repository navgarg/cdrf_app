-- Extensions
create extension if not exists pgcrypto;

-- USERS
create table if not exists public.users (
  uid uuid primary key references auth.users(id) on delete cascade,
  phone_number text not null default '',
  name text,
  profile_pic_url text,
  device_token text,
  created_at timestamptz not null default now(),
  last_login_at timestamptz not null default now(),
  business_domain text,

  -- Rollback idea (previous approach): keep onboarding question columns on `users`.
  -- Commented out because onboarding is now normalized into `user_onboarding`.
  /*
  language text,
  education text,
  age_range text,
  respondent_name text,
  age text,
  education_level text,
  years_running_business text,
  num_employees text,
  ownership_type text,
  digital_payments text,
  social_media_promotion text,
  record_income_expenses text,
  financial_records_method text,
  monthly_profit text,
  separate_business_household_money text,
  save_reinvest_for_growth text,
  access_to_credit_loans text,
  product_availability_knowledge text,
  stock_check_frequency text,
  run_out_of_products text,
  check_expiry_dates text,
  purchase_supplies_in_bulk text,
  track_product_sales text,
  maintain_customer_list text,
  remember_customer_preferences text,
  inform_customers_about_offers text,
  ask_for_feedback text,
  give_discounts_to_repeat_customers text,
  handle_customer_complaints text,
  onboarding_completed boolean not null default false,
  */

  favourite_customer_ids text[] not null default '{}',
  financial_transactions_enabled boolean not null default true,
  is_admin boolean not null default false
);

-- Helper: check if current auth user is admin
-- NOTE: Must be created after `public.users` exists.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(
    select 1
    from public.users u
    where u.uid = auth.uid() and coalesce(u.is_admin, false) = true
  );
$$;

-- ONBOARDING (separate table)
create table if not exists public.user_onboarding (
  user_id uuid primary key references public.users(uid) on delete cascade,
  language text,
  education text,
  age_range text,
  respondent_name text,
  age text,
  education_level text,
  years_running_business text,
  num_employees text,
  ownership_type text,
  digital_payments text,
  social_media_promotion text,
  record_income_expenses text,
  financial_records_method text,
  monthly_profit text,
  separate_business_household_money text,
  save_reinvest_for_growth text,
  access_to_credit_loans text,
  product_availability_knowledge text,
  stock_check_frequency text,
  run_out_of_products text,
  check_expiry_dates text,
  purchase_supplies_in_bulk text,
  track_product_sales text,
  maintain_customer_list text,
  remember_customer_preferences text,
  inform_customers_about_offers text,
  ask_for_feedback text,
  give_discounts_to_repeat_customers text,
  handle_customer_complaints text,
  onboarding_completed boolean not null default false
);

create index if not exists idx_users_created_at on public.users (created_at desc);

-- Auto-provision profile rows when a new auth user is created.
-- This avoids relying on client-side insertion and makes OTP/OAuth flows more reliable.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (uid, phone_number, created_at, last_login_at, is_admin)
  values (new.id, coalesce(new.phone, ''), now(), now(), false)
  on conflict (uid) do nothing;

  insert into public.user_onboarding (user_id, onboarding_completed)
  values (new.id, false)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- STORAGE: buckets + RLS policies
-- NOTE: In some Supabase projects, `storage.objects` is owned by a system role.
-- If you run this script as a non-owner role, Postgres will error with:
--   "must be owner of table objects"
-- We wrap Storage DDL in a best-effort block so the rest of the schema still applies.
-- To fully apply these policies, run this script in Supabase Studio SQL Editor as `postgres`.
do $$
begin
  begin
    -- Buckets (idempotent). Set `public=true` because the app uses `getPublicUrl()`.
    insert into storage.buckets (id, name, public)
    values ('resources', 'resources', true)
    on conflict (id) do update set public = excluded.public;

    insert into storage.buckets (id, name, public)
    values ('profile-images', 'profile-images', true)
    on conflict (id) do update set public = excluded.public;

    -- Objects policies
    execute 'alter table storage.objects enable row level security';

    -- Public read for resources and profile images
    execute 'drop policy if exists storage_public_read_resources on storage.objects';
    execute 'create policy storage_public_read_resources on storage.objects for select to public using (bucket_id = ''resources'')';

    execute 'drop policy if exists storage_public_read_profile_images on storage.objects';
    execute 'create policy storage_public_read_profile_images on storage.objects for select to public using (bucket_id = ''profile-images'')';

    -- Admin-only write for resources bucket (matches `resource_center` table policy)
    execute 'drop policy if exists storage_resources_insert_admin on storage.objects';
    execute 'create policy storage_resources_insert_admin on storage.objects for insert to authenticated with check (bucket_id = ''resources'' and public.is_admin())';

    execute 'drop policy if exists storage_resources_update_admin on storage.objects';
    execute 'create policy storage_resources_update_admin on storage.objects for update to authenticated using (bucket_id = ''resources'' and public.is_admin()) with check (bucket_id = ''resources'' and public.is_admin())';

    execute 'drop policy if exists storage_resources_delete_admin on storage.objects';
    execute 'create policy storage_resources_delete_admin on storage.objects for delete to authenticated using (bucket_id = ''resources'' and public.is_admin())';

    -- Profile images: authenticated users can write only within their own top-level folder: `<uid>/...`
    execute 'drop policy if exists storage_profile_images_insert_own on storage.objects';
    execute 'create policy storage_profile_images_insert_own on storage.objects for insert to authenticated with check (bucket_id = ''profile-images'' and (storage.foldername(name))[1] = auth.uid()::text)';

    execute 'drop policy if exists storage_profile_images_update_own on storage.objects';
    execute 'create policy storage_profile_images_update_own on storage.objects for update to authenticated using (bucket_id = ''profile-images'' and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id = ''profile-images'' and (storage.foldername(name))[1] = auth.uid()::text)';

    execute 'drop policy if exists storage_profile_images_delete_own on storage.objects';
    execute 'create policy storage_profile_images_delete_own on storage.objects for delete to authenticated using (bucket_id = ''profile-images'' and (storage.foldername(name))[1] = auth.uid()::text)';
  exception
    when insufficient_privilege then
      raise notice 'Skipping Storage bucket/policies due to insufficient_privilege. Run this script in Supabase Studio SQL Editor as role postgres to apply storage.objects policies.';
    when undefined_table then
      raise notice 'Storage schema not available (storage.objects missing). Enable Storage in Supabase, then re-run this script as postgres.';
    when others then
      raise notice 'Skipping Storage setup due to error: %', sqlerrm;
  end;
end $$;

-- INVENTORY ITEMS
create table if not exists public.inventory_items (
  id bigint generated by default as identity primary key,
  user_id uuid not null references public.users(uid) on delete cascade,
  business_id uuid not null,
  name text not null,
  description text,
  price numeric not null default 0,
  cost numeric not null default 0,
  stock_quantity integer not null default 0,
  reorder_threshold integer not null default 0,
  unit text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

alter table public.inventory_items
add column if not exists image_url text;

create index if not exists idx_inventory_items_user_id on public.inventory_items (user_id);
create index if not exists idx_inventory_items_business_id on public.inventory_items (business_id);

-- SERVICES
create table if not exists public.services (
  id bigint generated by default as identity primary key,
  user_id uuid not null references public.users(uid) on delete cascade,
  business_id uuid not null,
  name text not null,
  description text,
  price numeric not null default 0,
  duration integer not null default 0,
  image_url text,
  created_at timestamptz not null default now()
);

alter table public.services
add column if not exists image_url text;

create index if not exists idx_services_user_id on public.services (user_id);
create index if not exists idx_services_business_id on public.services (business_id);

-- FAVOURITE CUSTOMERS
create table if not exists public.favourite_customers (
  id bigint generated by default as identity primary key,
  user_id uuid not null references public.users(uid) on delete cascade,
  business_id uuid not null,
  name text not null,
  phone_number text,
  credit_outstanding numeric,
  last_purchase_date timestamptz,
  avg_monthly_spend numeric,
  loyalty_status text,
  created_at timestamptz not null default now()
);

create index if not exists idx_favourite_customers_user_id on public.favourite_customers (user_id);
create index if not exists idx_favourite_customers_business_id on public.favourite_customers (business_id);

-- APPOINTMENTS
create table if not exists public.appointments (
  id bigint generated by default as identity primary key,
  user_id uuid not null references public.users(uid) on delete cascade,
  title text not null,
  date_time timestamptz not null,
  business_domain text not null,
  customer_id text,
  created_at timestamptz not null default now()
);

create index if not exists idx_appointments_user_id on public.appointments (user_id);
create index if not exists idx_appointments_date_time on public.appointments (date_time);

-- TRANSACTIONS
create table if not exists public.transactions (
  id bigint generated by default as identity primary key,
  -- Shared id for grouping multiple line-items into a single order/checkout.
  transaction_id uuid not null default gen_random_uuid(),
  user_id uuid not null references public.users(uid) on delete cascade,
  business_id uuid not null,
  product_id text not null,
  item_name text,
  quantity integer not null default 0,
  price numeric not null default 0,
  cost numeric not null default 0,
  transaction_type text not null,
  payment_method text,
  timestamp timestamptz not null default now(),
  customer_id text,
  created_at timestamptz not null default now()
);

create index if not exists idx_transactions_user_id on public.transactions (user_id);
create index if not exists idx_transactions_user_transaction_id on public.transactions (user_id, transaction_id);
create index if not exists idx_transactions_timestamp on public.transactions (timestamp desc);
create index if not exists idx_transactions_customer_id on public.transactions (customer_id);

-- RESOURCE CENTER (global)
create table if not exists public.resource_center (
  id bigint generated by default as identity primary key,
  name text not null,
  url text not null,
  uploaded_by text not null,
  timestamp timestamptz not null default now(),
  size bigint
);

create index if not exists idx_resource_center_timestamp on public.resource_center (timestamp desc);

-- RLS
alter table public.users enable row level security;
alter table public.user_onboarding enable row level security;
alter table public.inventory_items enable row level security;
alter table public.services enable row level security;
alter table public.favourite_customers enable row level security;
alter table public.appointments enable row level security;
alter table public.transactions enable row level security;
alter table public.resource_center enable row level security;

-- USERS policies
drop policy if exists "users_select_own_or_admin" on public.users;
create policy "users_select_own_or_admin"
on public.users for select
to authenticated
using (uid = auth.uid() or public.is_admin());

drop policy if exists "users_insert_self" on public.users;
create policy "users_insert_self"
on public.users for insert
to authenticated
with check (uid = auth.uid());

drop policy if exists "users_update_self_or_admin" on public.users;
create policy "users_update_self_or_admin"
on public.users for update
to authenticated
using (uid = auth.uid() or public.is_admin())
with check (uid = auth.uid() or public.is_admin());

-- user_onboarding policies
drop policy if exists "onboarding_select_own_or_admin" on public.user_onboarding;
create policy "onboarding_select_own_or_admin"
on public.user_onboarding for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "onboarding_insert_own_or_admin" on public.user_onboarding;
create policy "onboarding_insert_own_or_admin"
on public.user_onboarding for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "onboarding_update_own_or_admin" on public.user_onboarding;
create policy "onboarding_update_own_or_admin"
on public.user_onboarding for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "onboarding_delete_own_or_admin" on public.user_onboarding;
create policy "onboarding_delete_own_or_admin"
on public.user_onboarding for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- OWNER tables policies helper macro pattern
-- inventory_items
drop policy if exists "inventory_select_own_or_admin" on public.inventory_items;
create policy "inventory_select_own_or_admin"
on public.inventory_items for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "inventory_insert_own_or_admin" on public.inventory_items;
create policy "inventory_insert_own_or_admin"
on public.inventory_items for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "inventory_update_own_or_admin" on public.inventory_items;
create policy "inventory_update_own_or_admin"
on public.inventory_items for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "inventory_delete_own_or_admin" on public.inventory_items;
create policy "inventory_delete_own_or_admin"
on public.inventory_items for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- services
drop policy if exists "services_select_own_or_admin" on public.services;
create policy "services_select_own_or_admin"
on public.services for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "services_insert_own_or_admin" on public.services;
create policy "services_insert_own_or_admin"
on public.services for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "services_update_own_or_admin" on public.services;
create policy "services_update_own_or_admin"
on public.services for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "services_delete_own_or_admin" on public.services;
create policy "services_delete_own_or_admin"
on public.services for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- favourite_customers
drop policy if exists "favcust_select_own_or_admin" on public.favourite_customers;
create policy "favcust_select_own_or_admin"
on public.favourite_customers for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "favcust_insert_own_or_admin" on public.favourite_customers;
create policy "favcust_insert_own_or_admin"
on public.favourite_customers for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "favcust_update_own_or_admin" on public.favourite_customers;
create policy "favcust_update_own_or_admin"
on public.favourite_customers for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "favcust_delete_own_or_admin" on public.favourite_customers;
create policy "favcust_delete_own_or_admin"
on public.favourite_customers for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- appointments
drop policy if exists "appointments_select_own_or_admin" on public.appointments;
create policy "appointments_select_own_or_admin"
on public.appointments for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "appointments_insert_own_or_admin" on public.appointments;
create policy "appointments_insert_own_or_admin"
on public.appointments for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "appointments_update_own_or_admin" on public.appointments;
create policy "appointments_update_own_or_admin"
on public.appointments for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "appointments_delete_own_or_admin" on public.appointments;
create policy "appointments_delete_own_or_admin"
on public.appointments for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- transactions
drop policy if exists "transactions_select_own_or_admin" on public.transactions;
create policy "transactions_select_own_or_admin"
on public.transactions for select
to authenticated
using (user_id = auth.uid() or public.is_admin());

drop policy if exists "transactions_insert_own_or_admin" on public.transactions;
create policy "transactions_insert_own_or_admin"
on public.transactions for insert
to authenticated
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "transactions_update_own_or_admin" on public.transactions;
create policy "transactions_update_own_or_admin"
on public.transactions for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "transactions_delete_own_or_admin" on public.transactions;
create policy "transactions_delete_own_or_admin"
on public.transactions for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- resource_center: everyone logged in can read; only admins can write
drop policy if exists "resources_select_authenticated" on public.resource_center;
create policy "resources_select_authenticated"
on public.resource_center for select
to authenticated
using (true);

drop policy if exists "resources_write_admin_only" on public.resource_center;
create policy "resources_write_admin_only"
on public.resource_center for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Enable real-time for relevant tables
BEGIN;
  drop publication if exists supabase_realtime;
  create publication supabase_realtime;
COMMIT;
alter publication supabase_realtime add table public.users;
alter publication supabase_realtime add table public.user_onboarding;
alter publication supabase_realtime add table public.inventory_items;
alter publication supabase_realtime add table public.services;
alter publication supabase_realtime add table public.favourite_customers;
alter publication supabase_realtime add table public.appointments;
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.resource_center;
