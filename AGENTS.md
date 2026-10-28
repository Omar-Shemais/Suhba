# إرشادات التطوير ومعايير الواجهة (AGENTS.md)

هذا الملف يحدد القواعد الصارمة والمعايير التصميمية لتطبيق **صحبة (Suhbah)** لمنع تكرار الأخطاء الشائعة وضمان الاتساق الكامل لواجهة المستخدم (UI/UX).

---

## 1. مشكلة عكس الأسهم في الواجهات العربية (Arrow Direction in RTL)

### ⚠️ المشكلة المتكررة (The Problem)
في التطبيقات العربية (Right-to-Left - RTL)، يقع المساعد أو المطور في خطأ افتراض أن سهم الرجوع أو أسهم التنقل يجب عكسها برمجياً أو استخدام سهم يشير لليمين (`>` مثل `Icons.chevron_right_rounded` أو `Icons.arrow_forward_ios_rounded`) استناداً إلى طبيعة القراءة من اليمين لليسار.
هذا الافتراض خاطئ ويؤدي إلى:
1. ظهور سهم الرجوع في الاتجاه المعكوس (`>`) بدلاً من السهم المألوف للمستخدمين (`<`).
2. كسر الاتساق البصري بين شاشات التطبيق المختلفة.

---

### ✅ الحل الصارم والقواعد الثابتة (Mandatory Rules & Solutions)

#### أ. سهم الرجوع في شريط العنوان العلوي (Back Button Icon):
- **الأيقونة المعتمدة حصراً**: 
  ```dart
  Icon(
    Icons.arrow_back_ios_new_rounded,
    size: 20.sp,
    color: isDark ? Colors.white : const Color(0xFF38291D),
  )
  ```
- **الاتجاه**: يجب أن يشير السهم دائماً إلى **اليسار** (`<`).
- **الموضع**: يوضع في **أقصى اليمين** (الـ leading في الـ `AppBar` أو أول عنصر في شريط العنوان داخل صف RTL).
- **ممنوع قطعيّاً ("وماتعكسش")**:
  - ❌ **لا تستخدم** `Icons.chevron_right_rounded` أو `Icons.arrow_forward_ios_rounded` لزر الرجوع.
  - ❌ **لا تعكس** الأيقونة لتشير إلى اليمين (`>`).
  - هذا المعيار موحد في كافة شاشات التطبيق:
    - [khatmah_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/khatmah/presentation/pages/khatmah_screen.dart)
    - [fasting_sunan_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/fasting/presentation/pages/fasting_sunan_screen.dart)
    - [azkar_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/azkar/presentation/pages/azkar_screen.dart)
    - [calendar_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/calendar/presentation/pages/calendar_screen.dart)
    - [notification_settings_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/settings/presentation/pages/notification_settings_screen.dart)
    - [duaa_screen.dart](file:///home/seg/Downloads/suhbah-last-update/lib/features/duaa/presentation/pages/duaa_screen.dart)

#### ب. أسهم الدخول والتفاصيل في البطاقات والحقول (Chevrons in Cards/Inputs):
- عند وجود سهم يدل على الانتقال للتفاصيل في القوائم أو الحقول (مثل حقل "عنوان الختمة" أو بطاقات الإعدادات):
  - يكون مكانه في **يسار البطاقة**.
  - يشير دائماً إلى **اليسار** (`<`) مثل: `Icons.chevron_left_rounded` أو `Icons.arrow_back_ios_new_rounded`.

---

## 2. لوحة الألوان المعتمدة (Design Tokens & Color Palette)

- **الخلفية العامة (Light Mode)**: `const Color(0xFFFAF5ED)` (بيج رملي دافئ).
- **العناوين وأزرار الرجوع**: `const Color(0xFF38291D)` (بني داكن فخم).
- **اللون الأساسي الإسلامي (Primary Brand Color)**: `const Color(0xFF143427)` (أخضر غابي عميق بديل عن الذهبي/البني القديم).
- **الحدود والبطاقات الفاتحة**: `const Color(0xFFEADBCE)` (إطار رملي ناعم).
- **النصوص الثانوية والأيقونات الهادئة**: `const Color(0xFF736152)` / `const Color(0xFF8C7A6B)`.
