-- ============================================================
-- نظام سجلات مرضى - د. هايدي علي (نساء وتوليد)
-- Supabase Schema
-- ============================================================

create extension if not exists "pgcrypto";

-- ---------- الفروع ----------
create table if not exists branches (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order int,          -- ترتيب ثابت للفروع (بديل عن الترتيب الأبجدي اللي بيتغير مع تغيير الاسم)
  created_at timestamptz not null default now()
);

insert into branches (name, sort_order) values
  ('فرع حلوان - 15 مايو', 1),
  ('فرع حدائق الأهرام - ش الخزان', 2)
  on conflict do nothing;

-- ---------- ملفات المستخدمين (دكتورة/سكرتيرة) ----------
-- role: 'doctor' (بيشتغل على كل الفروع) أو 'secretary' (مربوط بفرع واحد)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('doctor', 'secretary')),
  branch_id uuid references branches(id), -- null للدكتورة، مطلوب للسكرتيرة
  created_at timestamptz not null default now(),
  constraint secretary_needs_branch check (
    (role = 'secretary' and branch_id is not null) or role = 'doctor'
  )
);

-- ---------- المريضات (ملف واحد مشترك بين الفروع) ----------
create table if not exists patients (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  phone text not null,
  birth_date date,
  address text,
  marital_status text,

  -- تاريخ نسائي/توليدي
  lmp_date date,                    -- تاريخ آخر دورة شهرية
  gravida int,                      -- عدد مرات الحمل
  para int,                         -- عدد الولادات
  miscarriages int,                 -- عدد مرات الإجهاض
  contraception_method text,        -- وسيلة منع الحمل
  past_surgeries text,              -- عمليات سابقة

  -- تاريخ طبي عام
  chronic_diseases text,
  allergies text,
  current_medications text,

  archived_at timestamptz,          -- إخفاء المريضة (قابل للاسترجاع) بدل المسح النهائي
  archived_by uuid,                 -- (مرجع لاحق إلى profiles(id))

  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_patients_phone on patients(phone);
create index if not exists idx_patients_name on patients using gin (full_name gin_trgm_ops);

create extension if not exists pg_trgm;

-- ---------- الزيارات (كل زيارة موسومة بفرع) ----------
create table if not exists visits (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references patients(id) on delete cascade,
  branch_id uuid not null references branches(id),
  visit_date date not null default current_date,
  visit_type text check (visit_type in ('checkup','consultation')), -- كشف / استشارة
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists idx_visits_patient on visits(patient_id);

-- ---------- مرفقات الزيارة (append-only: صور و/أو ملاحظات) ----------
-- كل صف هنا إما صورة (image_path) أو إضافة نصية بس (note بدون صورة) أو الاتنين
-- التصحيحات بتتضاف كصف جديد، مفيش UPDATE ولا DELETE مسموح بيهم على الإطلاق
create table if not exists visit_attachments (
  id uuid primary key default gen_random_uuid(),
  visit_id uuid not null references visits(id) on delete cascade,
  image_path text,          -- المسار في Supabase Storage، nullable لو إضافة نصية بس
  note text,                -- ملاحظة/تشخيص اختياري
  is_addendum boolean not null default false, -- true لو ده تصحيح/إضافة لاحقة مش الدخول الأصلي
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  constraint has_content check (image_path is not null or note is not null)
);

create index if not exists idx_attachments_visit on visit_attachments(visit_id);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table branches enable row level security;
alter table profiles enable row level security;
alter table patients enable row level security;
alter table visits enable row level security;
alter table visit_attachments enable row level security;

-- دالة مساعدة: هل المستخدم الحالي دكتورة؟
create or replace function is_doctor()
returns boolean language sql stable security definer as $$
  select exists (
    select 1 from profiles where id = auth.uid() and role = 'doctor'
  );
$$;

-- دالة مساعدة: فرع السكرتيرة الحالية (null لو دكتورة)
create or replace function my_branch()
returns uuid language sql stable security definer as $$
  select branch_id from profiles where id = auth.uid();
$$;

-- ---------- Branches: الكل يقرأ فقط ----------
create policy "branches_select" on branches for select
  using (auth.uid() is not null);

-- ---------- Profiles: كل حد يشوف بروفايله بس ----------
create policy "profiles_select_own" on profiles for select
  using (id = auth.uid());

-- ---------- Patients: مشتركة بين الكل (قراءة وإضافة، بدون تعديل/مسح) ----------
create policy "patients_select" on patients for select
  using (auth.uid() is not null);

create policy "patients_insert" on patients for insert
  with check (auth.uid() is not null);

-- تعديل بيانات المريضة الأساسية (اسم/رقم/تاريخ نسائي) وإخفاؤها/استرجاعها مسموح للدكتورة والسكرتيرة
-- ملحوظة مهمة: ده منفصل تمامًا عن visit_attachments اللي فاضلة append-only بالكامل (مفيش سياسة UPDATE ليها)
create policy "patients_update" on patients for update
  using (auth.uid() is not null)
  with check (auth.uid() is not null);

alter table patients add constraint patients_archived_by_fkey
  foreign key (archived_by) references profiles(id);

-- ---------- Visits: قراءة للكل، إضافة حسب الفرع ----------
create policy "visits_select" on visits for select
  using (auth.uid() is not null);

create policy "visits_insert" on visits for insert
  with check (
    is_doctor() or branch_id = my_branch()
  );

-- ---------- Visit Attachments: قراءة للكل، إضافة حسب فرع الزيارة ----------
create policy "attachments_select" on visit_attachments for select
  using (auth.uid() is not null);

create policy "attachments_insert" on visit_attachments for insert
  with check (
    exists (
      select 1 from visits v
      where v.id = visit_id
      and (is_doctor() or v.branch_id = my_branch())
    )
  );

-- ============================================================
-- Storage bucket للصور
-- ============================================================
insert into storage.buckets (id, name, public)
  values ('visit-photos', 'visit-photos', false)
  on conflict (id) do nothing;

create policy "visit_photos_read" on storage.objects for select
  using (bucket_id = 'visit-photos' and auth.uid() is not null);

create policy "visit_photos_upload" on storage.objects for insert
  with check (bucket_id = 'visit-photos' and auth.uid() is not null);

-- ملحوظة: مفيش سياسات UPDATE/DELETE على storage.objects لبكت الصور دي
-- => الصور المرفوعة ثابتة برضو، متماشية مع مبدأ append-only
