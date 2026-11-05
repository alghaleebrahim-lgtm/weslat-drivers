-- ============================================
-- وصلت – تحديث لوحة الأدمن (المعتمدين + الإضافة اليدوية)
-- الصق الملف ده في Supabase → SQL Editor → Run
-- ============================================

alter table public.driver_registrations
  add column if not exists source      text not null default 'form',  -- form / manual
  add column if not exists added_by    text,                          -- إيميل الموظف اللي أضاف السائق يدوياً
  add column if not exists branch      text,                          -- الفرع اللي أضاف السائق
  add column if not exists approved_at timestamptz,
  add column if not exists approved_by text;

-- الإدخال: الزائر يبدأ دائماً "جديد"، والموظف يقدر يضيف بأي حالة
create or replace function public.driver_reg_defaults()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if not public.is_admin() then
    new.status := 'جديد';
    new.admin_notes := null;
    new.source := 'form';
    new.added_by := null;
    new.branch := null;
    new.approved_at := null;
    new.approved_by := null;
  else
    new.source := 'manual';
    new.added_by := auth.jwt() ->> 'email';
    if new.status = 'مقبول' then
      new.approved_at := now();
      new.approved_by := auth.jwt() ->> 'email';
    end if;
  end if;
  new.created_at := now();
  return new;
end $$;

-- التعديل: تسجيل وقت ومن اعتمد السائق
create or replace function public.driver_reg_on_update()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'مقبول' and old.status is distinct from 'مقبول' then
    new.approved_at := now();
    new.approved_by := auth.jwt() ->> 'email';
  elsif new.status <> 'مقبول' then
    new.approved_at := null;
    new.approved_by := null;
  end if;
  return new;
end $$;

drop trigger if exists driver_reg_on_update on public.driver_registrations;
create trigger driver_reg_on_update before update on public.driver_registrations
  for each row execute function public.driver_reg_on_update();

-- الموظفين يرفعوا صور عند الإضافة اليدوية
drop policy if exists "admins upload driver docs" on storage.objects;
create policy "admins upload driver docs" on storage.objects
  for insert to authenticated with check (bucket_id = 'driver-docs' and public.is_admin());

-- ============================================
-- إضافة موظفين الفروع: كرر السطر لكل موظف (وأنشئ له حساب في Authentication → Users)
-- insert into public.admins (email) values ('employee@weslat.net') on conflict do nothing;
-- ============================================
