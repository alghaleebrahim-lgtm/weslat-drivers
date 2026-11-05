-- ============================================
-- وصلت – تفعيل الإشعارات اللحظية لطلبات التسجيل
-- الصق الملف ده في Supabase → SQL Editor → Run
-- ============================================
do $$
begin
  alter publication supabase_realtime add table public.driver_registrations;
exception when duplicate_object then null;
end $$;
