-- ============================================
-- وصلت – صلاحيات لوحة الأدمن
-- الصق الملف ده في Supabase → SQL Editor → Run
-- (بعد ملف supabase.sql)
-- ============================================

-- الإيميلات المسموح لها تدخل لوحة الأدمن
create table if not exists public.admins (
  email text primary key
);
alter table public.admins enable row level security;

-- أضف إيميلات الأدمن هنا (ولازم كل إيميل يكون عنده حساب في Authentication → Users)
insert into public.admins (email) values
  ('ibrahim@weslat.net')
on conflict do nothing;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where lower(email) = lower(auth.jwt() ->> 'email')
  );
$$;

-- الأدمن يقرأ ويعدّل ويحذف التسجيلات
drop policy if exists "admins read" on public.driver_registrations;
create policy "admins read" on public.driver_registrations
  for select to authenticated using (public.is_admin());

drop policy if exists "admins update" on public.driver_registrations;
create policy "admins update" on public.driver_registrations
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins delete" on public.driver_registrations;
create policy "admins delete" on public.driver_registrations
  for delete to authenticated using (public.is_admin());

-- الأدمن يشوف الصور
drop policy if exists "admins read driver docs" on storage.objects;
create policy "admins read driver docs" on storage.objects
  for select to authenticated using (bucket_id = 'driver-docs' and public.is_admin());
