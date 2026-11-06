/* إعدادات البياع: عدّل هذا الملف لتغيير بيانات التواصل والمدن والإعلانات المعروضة. */
window.BAYYA = {
  name: "البياع",
  tagline: "سوقك في جيبك: بِع واشترِ في كل موريتانيا",
  // رقم واتساب الإدارة بالصيغة الدولية دون + أو مسافات، مثال: "22200000000".
  // عند تعبئته تُرسل الإعلانات الجديدة إليه للمراجعة والنشر. اتركه فارغاً لإخفاء ذلك.
  whatsapp: "",
  currency: "أوقية",
  // true يعرض شريطاً ينبّه إلى أن الإعلانات الحالية أمثلة. اجعله false عند وضع إعلانات حقيقية في ads.js.
  demo: true,
  // بريد التواصل (اختياري) يظهر في التذييل.
  email: "",
  // قاعدة البيانات (Supabase). اتركها فارغة ليعمل الموقع دونها: تُحفظ الإعلانات الجديدة على جهاز صاحبها فقط.
  // url و key من Supabase ← Project Settings ← API (Project URL و anon/publishable key). المفتاح العام آمن في الموقع.
  supabase: { url: "https://saebctnxtcnofoorgzss.supabase.co", key: "sb_publishable_rMYEwlL7tiCtfbQMkRDiCA_0P6Vpk6x" },
  // true: من لم يسجّل الدخول ينشر مباشرة، ويبقى إعلانه مرتبطاً بجهازه (يحتاج تفعيل Anonymous sign-ins في Supabase).
  // false: يلزم الدخول بالبريد الإلكتروني قبل النشر.
  allowAnonymous: true,
  cities: ["نواكشوط", "نواذيبو", "روصو", "كيفه", "أطار", "ازويرات", "كيهيدي", "النعمة", "ألاك", "العيون", "سيلبابي", "أكجوجت"],
  categories: [
    { id: "cars", name: "سيارات" }, { id: "realestate", name: "عقارات" }, { id: "phones", name: "هواتف" },
    { id: "electronics", name: "أجهزة وإلكترونيات" }, { id: "home", name: "أثاث ومنزل" }, { id: "livestock", name: "مواشي" },
    { id: "fashion", name: "ملابس وملحفات" }, { id: "jobs", name: "وظائف" }, { id: "services", name: "خدمات" }
  ]
};
