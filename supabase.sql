-- ============================================
-- وصلت – تسجيل السائقين والعربات
-- الصق الملف ده كامل في Supabase → SQL Editor → Run
-- ============================================

create table if not exists public.driver_registrations (
  id                    uuid primary key default gen_random_uuid(),
  created_at            timestamptz not null default now(),
  status                text not null default 'جديد',   -- جديد / تم التواصل / مقبول / مرفوض

  full_name             text not null,
  phone                 text not null,
  whatsapp              text,
  residence_city        text not null,
  residence_area        text not null,
  license_type          text not null,
  experience_years      int,

  vehicle_type          text not null,
  vehicle_model         text not null,
  vehicle_year          int,
  capacity_tons         numeric not null,
  cover_type            text not null,
  plate_number          text not null,
  ownership             text not null,
  vehicle_photo_path    text,
  license_photo_path    text,

  work_scope            text not null,
  route_from            text not null,
  route_to              text not null,
  other_routes          text,
  cities                text[] not null default '{}',
  availability          text,
  pricing_method        text not null,
  approx_price          numeric,
  worked_with_companies text,
  notes                 text,
  admin_notes           text
);

-- الحماية: الزوار يقدروا يضيفوا فقط، وما يقدروا يقروا أي بيانات
alter table public.driver_registrations enable row level security;

drop policy if exists "public can register" on public.driver_registrations;
create policy "public can register"
  on public.driver_registrations
  for insert to anon
  with check (status = 'جديد');

-- مخزن الصور (خاص – ما بيظهر للعامة)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('driver-docs', 'driver-docs', false, 8388608, array['image/jpeg','image/png','image/webp','image/heic','image/heif'])
on conflict (id) do nothing;

drop policy if exists "public can upload driver docs" on storage.objects;
create policy "public can upload driver docs"
  on storage.objects
  for insert to anon
  with check (bucket_id = 'driver-docs');

-- رفع الصور يحتاج قراءة الملف بعد رفعه مباشرة؛ نسمح بذلك لدقيقتين فقط بعد الرفع
drop policy if exists "anon read fresh driver docs" on storage.objects;
create policy "anon read fresh driver docs"
  on storage.objects
  for select to anon
  using (bucket_id = 'driver-docs' and created_at > now() - interval '2 minutes');
