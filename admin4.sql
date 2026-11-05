-- ============================================
-- وصلت – إدارة موظفي الفروع من لوحة التحكم
-- الصق الملف ده في Supabase → SQL Editor → Run
-- ============================================

alter table public.admins
  add column if not exists name       text,
  add column if not exists branch     text,
  add column if not exists role       text not null default 'staff',   -- owner / manager / staff
  add column if not exists active     boolean not null default true,
  add column if not exists created_at timestamptz not null default now();

-- إبراهيم مالك النظام
update public.admins set role = 'owner', name = coalesce(name, 'إبراهيم')
where lower(email) = 'ibrahim@weslat.net';

-- الموظف الموقوف ما بيدخل
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins
    where lower(email) = lower(auth.jwt() ->> 'email') and active);
$$;

create or replace function public.is_owner()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins
    where lower(email) = lower(auth.jwt() ->> 'email') and active and role = 'owner');
$$;

-- بيانات الموظف الداخل حالياً
create or replace function public.my_staff()
returns table (email text, name text, branch text, role text)
language sql stable security definer set search_path = public as $$
  select email, name, branch, role from public.admins
  where lower(email) = lower(auth.jwt() ->> 'email') and active;
$$;

-- صلاحيات جدول الموظفين: المالك فقط يقرأ ويعدّل
drop policy if exists "owner manages admins" on public.admins;
create policy "owner manages admins" on public.admins
  for all to authenticated using (public.is_owner()) with check (public.is_owner());

-- إنشاء موظف (أو تحديث بياناته وكلمة سره لو موجود)
create or replace function public.create_staff(p_email text, p_password text, p_name text, p_branch text, p_role text default 'staff')
returns void language plpgsql security definer set search_path = public, extensions, auth as $$
declare
  v_email text := lower(trim(p_email));
  v_uid uuid;
begin
  if not public.is_owner() then raise exception 'غير مسموح'; end if;
  if v_email is null or v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'اسم المستخدم أو البريد غير صحيح'; end if;
  if length(coalesce(p_password, '')) < 6 then raise exception 'كلمة السر لازم تكون 6 أحرف أو أكثر'; end if;
  if p_role not in ('owner', 'manager', 'staff') then raise exception 'دور غير صحيح'; end if;

  select id into v_uid from auth.users where lower(email) = v_email;
  if v_uid is null then
    v_uid := gen_random_uuid();
    insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token)
    values ('00000000-0000-0000-0000-000000000000', v_uid, 'authenticated', 'authenticated', v_email,
      crypt(p_password, gen_salt('bf')), now(),
      '{"provider":"email","providers":["email"]}', jsonb_build_object('name', p_name), now(), now(),
      '', '', '', '');
    insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
    values (gen_random_uuid(), v_uid, v_uid::text,
      jsonb_build_object('sub', v_uid::text, 'email', v_email, 'email_verified', true),
      'email', now(), now(), now());
  else
    update auth.users set encrypted_password = crypt(p_password, gen_salt('bf')), updated_at = now() where id = v_uid;
  end if;

  insert into public.admins (email, name, branch, role, active)
  values (v_email, p_name, p_branch, p_role, true)
  on conflict (email) do update set name = excluded.name, branch = excluded.branch, role = excluded.role, active = true;
end $$;

-- تغيير كلمة سر موظف
create or replace function public.set_staff_password(p_email text, p_password text)
returns void language plpgsql security definer set search_path = public, extensions, auth as $$
begin
  if not public.is_owner() then raise exception 'غير مسموح'; end if;
  if length(coalesce(p_password, '')) < 6 then raise exception 'كلمة السر لازم تكون 6 أحرف أو أكثر'; end if;
  update auth.users set encrypted_password = crypt(p_password, gen_salt('bf')), updated_at = now()
  where lower(email) = lower(trim(p_email));
  if not found then raise exception 'المستخدم غير موجود'; end if;
end $$;

-- حذف موظف نهائياً
create or replace function public.delete_staff(p_email text)
returns void language plpgsql security definer set search_path = public, auth as $$
begin
  if not public.is_owner() then raise exception 'غير مسموح'; end if;
  if lower(trim(p_email)) = lower(auth.jwt() ->> 'email') then raise exception 'ما بتقدر تحذف حسابك'; end if;
  delete from public.admins where lower(email) = lower(trim(p_email));
  delete from auth.users where lower(email) = lower(trim(p_email));
end $$;

revoke all on function public.create_staff(text, text, text, text, text) from public, anon;
revoke all on function public.set_staff_password(text, text) from public, anon;
revoke all on function public.delete_staff(text) from public, anon;
grant execute on function public.create_staff(text, text, text, text, text) to authenticated;
grant execute on function public.set_staff_password(text, text) to authenticated;
grant execute on function public.delete_staff(text) to authenticated;
grant execute on function public.my_staff() to authenticated;
