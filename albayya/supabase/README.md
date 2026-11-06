# ربط البياع بـ Supabase

بعد هذه الخطوات تُحفظ الإعلانات في قاعدة بيانات واحدة، ويظهر كل إعلان جديد لكل الزوار فور نشره، مع صوره.
الخطة المجانية في Supabase تكفي للبداية (قاعدة 500 ميغابايت، صور 1 غيغابايت).

## 1. أنشئ المشروع

1. ادخل https://supabase.com واضغط **Start your project** (الدخول بحساب GitHub أسهل).
2. **New project**: الاسم `albayya`، كلمة سر قوية لقاعدة البيانات (احفظها عندك)، والمنطقة **West EU (Paris)** أو **Central EU (Frankfurt)**، وهما الأقرب إلى موريتانيا.
3. انتظر دقيقتين حتى يجهز المشروع.

## 2. أنشئ الجدول والصلاحيات

1. من القائمة الجانبية: **SQL Editor** ← **New query**.
2. انسخ محتوى الملف [`schema.sql`](schema.sql) كاملاً، والصقه، ثم **Run**.
3. يجب أن تظهر **Success. No rows returned**.

## 3. إعدادات الدخول

من **Authentication**:

- **Sign In / Providers**: فعّل **Allow anonymous sign-ins**، فينشر الزائر دون حساب ويبقى إعلانه مرتبطاً بجهازه.
  إن لم تفعّله، فاجعل `allowAnonymous: false` في `config.js`، فيلزم الدخول بالبريد قبل النشر.
- **Emails** ← **Templates**: في القوالب الثلاثة **Confirm signup** و**Magic Link** و**Change Email Address**،
  ضع الرمز في الرسالة ليكتبه المستخدم في الموقع. مثلاً:
  ```html
  <h2>رمز الدخول إلى البياع</h2>
  <p style="font-size:28px;letter-spacing:6px"><b>{{ .Token }}</b></p>
  <p>اكتب هذا الرمز في الموقع. ينتهي بعد ساعة.</p>
  ```
- **URL Configuration** ← **Site URL**: `https://tenyekat-design.github.io/Factira/albayya/`

**مهم:** بريد Supabase المدمج يرسل رسائل قليلة جداً في الساعة، ويكفي للتجربة فقط.
قبل الإطلاق اربط بريداً خاصاً: **Emails** ← **SMTP Settings**، بحساب مجاني من خدمة مثل Resend أو Brevo.

## 4. ضع المفتاحين في الموقع

1. **Project Settings** ← **API Keys** (أو **API**): انسخ **Project URL** و**Publishable key**.
   في المشاريع القديمة اسمه **anon public**. المفتاح العام آمن في الموقع، فالحماية في قواعد `schema.sql`.
   لا تستعمل أبداً **secret** أو **service_role**.
2. في `albayya/config.js`:
   ```js
   supabase: { url: "https://xxxx.supabase.co", key: "sb_publishable_..." },
   ```
3. لتظهر الإعلانات الحقيقية وحدها: احذف الأمثلة من `ads.js` (اترك `window.BAYYA_ADS = [];`)، واجعل `demo: false`.

## الإدارة من لوحة Supabase

من **Table Editor** ← `ads`:

- **إعلان مميز:** اجعل `featured` = true.
- **إخفاء إعلان مخالف:** اجعل `status` = `hidden`، أو احذف الصف.
- **مراجعة الإعلانات قبل نشرها:** شغّل في SQL Editor:
  `alter table public.ads alter column status set default 'pending';`
  فيصل كل إعلان جديد بحالة `pending`، ويراه صاحبه فقط حتى تجعله `published`.
- **الصور:** في **Storage** ← `ad-images`.

## الحماية في `schema.sql`

- يرى الجميع الإعلانات المنشورة فقط. صاحب الإعلان يرى إعلاناته كلها، ويعدّلها ويحذفها.
- لا يستطيع أحد من الموقع جعل إعلانه مميزاً أو تغيير حالته.
- لا يُنشر أكثر من 10 إعلانات في اليوم لكل مستخدم، والصورة حتى 2 ميغابايت، و4 صور على الأكثر للإعلان.
- يرفع كل مستخدم الصور داخل مجلده فقط.
