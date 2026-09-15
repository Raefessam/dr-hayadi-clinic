// ============================================================
// إعدادات الاتصال بـ Supabase
// حط هنا الـ URL والـ anon key بتوع مشروع Supabase الخاص بالنظام ده
// (Settings → API في لوحة تحكم Supabase)
// ============================================================
const SUPABASE_URL = "https://drrwgdjdomryutmtvudw.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_dKbCBTqOy009lf5sfEeAFg_vJv7rjOZ";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
