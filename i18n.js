const I18N = {
  ar: {
    dir: "rtl",
    clinic_name: "د. هايدي علي",
    clinic_sub: "أخصائية النساء والتوليد والمناظير الجراحية",
    login_title: "تسجيل الدخول",
    email: "البريد الإلكتروني",
    password: "كلمة المرور",
    login_btn: "دخول",
    login_error: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
    logout: "خروج",
    lang_toggle: "EN",
    branch_1: "فرع 1",
    branch_2: "فرع 2",
    search_placeholder: "ابحث بالاسم أو رقم الموبايل...",
    no_patients: "لا يوجد مريضات مسجلات بعد",
    new_patient: "مريضة جديدة",
    new_patient_title: "بيانات مريضة جديدة",
    full_name: "الاسم بالكامل",
    phone: "رقم الموبايل",
    birth_date: "تاريخ الميلاد",
    address: "العنوان (اختياري)",
    marital_status: "الحالة الاجتماعية",
    ms_single: "آنسة",
    ms_married: "متزوجة",
    ms_other: "أخرى",
    gyn_history: "التاريخ النسائي والتوليدي",
    lmp_date: "تاريخ آخر دورة شهرية",
    gravida: "عدد مرات الحمل",
    para: "عدد الولادات",
    miscarriages: "عدد مرات الإجهاض",
    contraception: "وسيلة منع الحمل",
    past_surgeries: "عمليات سابقة",
    medical_history: "التاريخ الطبي العام",
    chronic_diseases: "أمراض مزمنة",
    allergies: "حساسية من أدوية",
    current_medications: "أدوية حالية",
    save: "حفظ",
    cancel: "إلغاء",
    saving: "جارِ الحفظ...",
    patient_saved: "تم حفظ بيانات المريضة",
    back_to_list: "قائمة المريضات",
    visits_history: "سجل الزيارات",
    no_visits: "لا يوجد زيارات مسجلة بعد",
    add_visit: "إضافة زيارة",
    add_visit_title: "زيارة جديدة",
    take_photo: "اضغط لتصوير مستند",
    take_photo_hint: "تحليل، أشعة، سونار، روشتة...",
    note_optional: "ملاحظة / تشخيص (اختياري)",
    save_visit: "حفظ الزيارة",
    visit_saved: "تم حفظ الزيارة",
    original_entry: "الزيارة الأصلية",
    addendum: "إضافة / تصحيح لاحق",
    add_addendum: "إضافة تصحيح لهذه الزيارة",
    addendum_title: "إضافة تصحيح",
    addendum_hint: "السجل الأصلي لا يمكن تعديله، لكن يمكنك إضافة صورة أو ملاحظة جديدة تُضاف لتاريخ هذه الزيارة",
    required_field: "الاسم ورقم الموبايل مطلوبين",
    add_photo_or_note: "أضف صورة واحدة على الأقل أو ملاحظة",
    loading: "جارِ التحميل...",
    years: "سنة",
    not_specified: "غير محدد",
  },
  en: {
    dir: "ltr",
    clinic_name: "Dr. Hayadi Ali",
    clinic_sub: "Obstetrics & Gynecology, Laparoscopic Surgery",
    login_title: "Sign in",
    email: "Email",
    password: "Password",
    login_btn: "Sign in",
    login_error: "Incorrect email or password",
    logout: "Log out",
    lang_toggle: "AR",
    branch_1: "Branch 1",
    branch_2: "Branch 2",
    search_placeholder: "Search by name or phone...",
    no_patients: "No patients registered yet",
    new_patient: "New patient",
    new_patient_title: "New patient details",
    full_name: "Full name",
    phone: "Phone number",
    birth_date: "Date of birth",
    address: "Address (optional)",
    marital_status: "Marital status",
    ms_single: "Single",
    ms_married: "Married",
    ms_other: "Other",
    gyn_history: "Gynecological & Obstetric history",
    lmp_date: "Last menstrual period",
    gravida: "Gravida (pregnancies)",
    para: "Para (deliveries)",
    miscarriages: "Miscarriages",
    contraception: "Contraception method",
    past_surgeries: "Past surgeries",
    medical_history: "General medical history",
    chronic_diseases: "Chronic diseases",
    allergies: "Drug allergies",
    current_medications: "Current medications",
    save: "Save",
    cancel: "Cancel",
    saving: "Saving...",
    patient_saved: "Patient saved",
    back_to_list: "Patient list",
    visits_history: "Visit history",
    no_visits: "No visits recorded yet",
    add_visit: "Add visit",
    add_visit_title: "New visit",
    take_photo: "Tap to capture document",
    take_photo_hint: "Lab result, scan, ultrasound, prescription...",
    note_optional: "Note / diagnosis (optional)",
    save_visit: "Save visit",
    visit_saved: "Visit saved",
    original_entry: "Original entry",
    addendum: "Later addition / correction",
    add_addendum: "Add a correction to this visit",
    addendum_title: "Add correction",
    addendum_hint: "The original record cannot be edited, but you can add a new photo or note to this visit's history",
    required_field: "Name and phone are required",
    add_photo_or_note: "Add at least one photo or a note",
    loading: "Loading...",
    years: "yrs",
    not_specified: "Not specified",
  }
};

let currentLang = localStorage.getItem("gyn_lang") || "ar";

function t(key) {
  return I18N[currentLang][key] || key;
}

function applyLang() {
  document.documentElement.lang = currentLang;
  document.body.dir = I18N[currentLang].dir;
  document.querySelectorAll("[data-i18n]").forEach(el => {
    el.textContent = t(el.getAttribute("data-i18n"));
  });
  document.querySelectorAll("[data-i18n-placeholder]").forEach(el => {
    el.placeholder = t(el.getAttribute("data-i18n-placeholder"));
  });
}

function toggleLang() {
  currentLang = currentLang === "ar" ? "en" : "ar";
  localStorage.setItem("gyn_lang", currentLang);
  applyLang();
  if (typeof onLangChange === "function") onLangChange();
}
