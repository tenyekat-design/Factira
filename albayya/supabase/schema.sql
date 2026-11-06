/* البياع: قاعدة البيانات على Supabase. */
/* شغّل هذا الملف كاملاً مرة واحدة: Supabase ← SQL Editor ← New query ← الصق ← Run. التعليقات بين علامتي النجمة حتى يعمل الملف ولو لُصق سطراً واحداً من الهاتف. */
/* يمكن تشغيله مرة ثانية دون ضرر. */

/* 1) جدول الإعلانات --------------------------------------------------------- */
create table if not exists public.ads (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  status      text not null default 'published' check (status in ('published', 'pending', 'hidden')),
  featured    boolean not null default false,
  cat         text not null check (char_length(cat) <= 30),
  sub         text check (char_length(sub) <= 60),
  title       text not null check (char_length(title) between 3 and 80),
  price       numeric check (price is null or price >= 0),
  per         text check (char_length(per) <= 20),
  nego        boolean not null default false,
  cond        text check (char_length(cond) <= 20),
  city        text not null check (char_length(city) <= 40),
  area        text check (char_length(area) <= 40),
  seller      text not null check (char_length(seller) <= 40),
  phone       text not null check (phone ~ '^[0-9]{8,15}$'),
  descr       text check (char_length(descr) <= 1000),
  f           jsonb not null default '{}'::jsonb,
  imgs        text[] not null default '{}' check (cardinality(imgs) <= 4),
  img_paths   text[] not null default '{}' check (cardinality(img_paths) <= 4)
);
create index if not exists ads_list_idx on public.ads (status, created_at desc);
create index if not exists ads_user_idx on public.ads (user_id);

/* 2) الصلاحيات ---------------------------------------------------------------- */
/* يرى الجميع الإعلانات المنشورة، ويرى صاحب الإعلان إعلاناته كلها. */
/* يضيف المستخدم المسجّل (ولو دون بريد) إعلاناته، ويعدّلها ويحذفها، ولا يستطيع جعلها «مميزة» ولا تغيير حالتها: */
/* ذلك للإدارة من لوحة Supabase (Table Editor ← ads). */
alter table public.ads enable row level security;

drop policy if exists "ads: read published or own" on public.ads;
create policy "ads: read published or own" on public.ads
  for select using (status = 'published' or user_id = auth.uid());

drop policy if exists "ads: insert own" on public.ads;
create policy "ads: insert own" on public.ads
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "ads: update own" on public.ads;
create policy "ads: update own" on public.ads
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "ads: delete own" on public.ads;
create policy "ads: delete own" on public.ads
  for delete to authenticated using (user_id = auth.uid());

revoke insert, update on public.ads from anon, authenticated;
grant select on public.ads to anon, authenticated;
grant delete on public.ads to authenticated;
grant insert (cat, sub, title, price, per, nego, cond, city, area, seller, phone, descr, f, imgs, img_paths) on public.ads to authenticated;
grant update (cat, sub, title, price, per, nego, cond, city, area, seller, phone, descr, f, imgs, img_paths) on public.ads to authenticated;

/* حدّ بسيط ضد الإغراق: 10 إعلانات في اليوم لكل مستخدم. */
create or replace function public.ads_daily_limit() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.ads where user_id = new.user_id and created_at > now() - interval '1 day') >= 10 then
    raise exception 'daily_limit' using hint = 'لا يمكن نشر أكثر من 10 إعلانات في اليوم';
  end if;
  return new;
end $$;
drop trigger if exists ads_daily_limit on public.ads;
create trigger ads_daily_limit before insert on public.ads for each row execute function public.ads_daily_limit();

/* 3) الصور ---------------------------------------------------------------------- */
/* مستودع عام للقراءة. كل مستخدم يرفع داخل مجلد باسم رقمه فقط، والصورة حتى 2 ميغابايت. */
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('ad-images', 'ad-images', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set public = true, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp'];

drop policy if exists "ad-images: upload own folder" on storage.objects;
create policy "ad-images: upload own folder" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'ad-images' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "ad-images: delete own" on storage.objects;
create policy "ad-images: delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'ad-images' and (storage.foldername(name))[1] = auth.uid()::text);

/* 4) اختياري: مراجعة الإعلانات قبل نشرها --------------------------------------------- */
/* لتراجع كل إعلان قبل ظهوره شغّل السطر التالي، ثم غيّر status إلى published من Table Editor: */
/*   alter table public.ads alter column status set default 'pending'; */
/* وللعودة إلى النشر الفوري: */
/*   alter table public.ads alter column status set default 'published'; */
