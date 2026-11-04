# فورم تسجيل السائقين والعربات – وصلت

## الملفات
- `index.html`: صفحة الفورم
- `logo.png` و `cover.jpg`: الشعار والغلاف
- `supabase.sql`: إنشاء جدول البيانات ومكان حفظ الصور

## 1) Supabase (قاعدة البيانات)
1. ادخل supabase.com، وأنشئ مشروع جديد (مثلاً `weslat-drivers`).
2. افتح **SQL Editor**، والصق محتوى `supabase.sql`، واضغط **Run**.
3. من **Project Settings → API** انسخ:
   - `Project URL`
   - `anon public key`
4. في `index.html`، حطّهم مكان السطرين دول:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-KEY";
   ```
   مفتاح الـ anon آمن يكون في الصفحة، لأن الحماية بتسمح للزوار **بالإضافة فقط**، وما بيقدروا يقروا أي بيانات.

## 2) GitHub
1. أنشئ Repo جديد (مثلاً `weslat-drivers`).
2. ارفع الملفات كلها: **Add file → Upload files**.

## 3) Vercel
1. **Add New → Project**، واختار الـ Repo.
2. Framework: **Other**، وبعدها **Deploy** من غير أي إعدادات تانية.
3. عشان تربط دومين وصلت: **Settings → Domains**، وأضف مثلاً `drivers.weslat.net`. بعدها أضف سجل CNAME عند مزوّد الدومين يشير إلى `cname.vercel-dns.com`.

أي تعديل ترفعه على GitHub، Vercel بينشره براه.

## متابعة التسجيلات
- البيانات: Supabase → **Table Editor → driver_registrations**. ممكن تصدّرها CSV.
- عمود `status` (جديد / تم التواصل / مقبول / مرفوض) لمتابعة كل سائق، وعمود `admin_notes` لملاحظاتكم.
- الصور: **Storage → driver-docs**، والمسار محفوظ في الأعمدة `vehicle_photo_path` و `license_photo_path`.
