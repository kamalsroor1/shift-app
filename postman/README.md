# 📬 دليل استخدام كولكشن Postman الشامل والمؤتمت لمشروع ShiftSync

مرحباً بك في حزمة **ShiftSync API Postman Collection v2.1**! تم تصميم هذه الحزمة واختباراتها المؤتمتة (Scripts & Tests) لتختصر عليك الوقت والجهد أثناء فحص وتجربة جميع مسارات المشروع.

---

## 📂 محتويات المجلد
1. **`shiftsync_postman_collection.json`**: ملف الكولكشن الذي يحتوي على كافة الـ Endpoints مرتبة بمجلدات منطقية (`Authentication`، `Departments`، `Family Links`) ومصحوبة بـ **Automated Scripts** عند استلام كل استجابة.
2. **`shiftsync_postman_environment.json`**: ملف البيئة (Environment Variables) الذي يحمل المتغيرات الأساسية مثل الرابط السريع (`base_url = http://127.0.0.1:8000`) وأرقام هواتف الحسابات والتوكنات المكتسبة تلقائياً.

---

## 🚀 خطوات الاستيراد والتشغيل (How to Import & Run)

### 1. استيراد الملفات في Postman
- افتح تطبيق **Postman**.
- اضغط على زر **`Import`** أعلى اليسار.
- قم بسحب وإفلات كلا الملفين (`shiftsync_postman_collection.json` و `shiftsync_postman_environment.json`) معاً واضغط `Import`.

### 2. تفعيل البيئة (Select Environment)
- من أعلى يمين الشاشة في Postman، اختر البيئة المستوردة باسم:
  👉 **`ShiftSync Local Environment`**

---

## 🪄 كيف تعمل السكربتات والاختبارات التلقائية (Automated Scripts)?

لا داعي للنسخ واللصق اليدوي لـ `access_token` أو الـ `UUIDs` بعد الآن! قمنا بكتابة أكواد JavaScript تلقائية داخل خانة `Tests` لكل طلب:

1. **تسجيل الدخول (`Login as Nurse` / `Login as Admin` / `Login as Partner`):**
   - بمجرد إرسال طلب الدخول بنجاح (200 OK)، يقوم السكربت تلقائياً باستخراج التوكن وحفظه في متغير بيئة `{{access_token}}` و `{{refresh_token}}`.
   - أي طلب يطلب مصادقة بعدها (مثل `/me` أو `/departments` أو `/family-links`) سيقوم تلقائياً بسحب `{{access_token}}` من البيئة وإرساله في الهيدر `Authorization: Bearer {{access_token}}`.

2. **إنشاء أو جلب الأقسام (`List All Departments`):**
   - يلتقط السكربت تلقائياً أول قسم متاح ويحفظ معرفه في `{{department_uuid}}` ليتم استخدامه في طلب جلب التفاصيل أو تعديل الساعات المستهدفة (`PATCH`).

3. **دورة حياة ربط العائلة (`Initiate Family Link`):**
   - عندما تقوم الممرضة بإرسال طلب ربط، يستخرج السكربت مباشرة معرف الربط ويحفظه في `{{link_uuid}}`.
   - عندما تقوم لاحقاً بتسجيل الدخول كـ Partner وإرسال طلب قبول الربط (`Accept Family Link`)، سيتم استخدام `{{link_uuid}}` المحفوظ تلقائياً لتحويل الحالة إلى `ACTIVE`!

---

## 🎯 تشغيل فحص شامل تلقائي (Collection Runner)
يمكنك تشغيل الكولكشن بالكامل بضغطة زر واحدة والتأكد من سلامة جميع الـ APIs:
1. انقر بالزر الأيمن على اسم الكولكشن **`ShiftSync API Full Collection`** واختر **`Run collection`**.
2. تأكد من اختيار بيئة **`ShiftSync Local Environment`**.
3. اضغط على زر **`Run ShiftSync API Full Collection`** وشاهد جميع الاختبارات تجتاز باللون الأخضر ✔️ في ثوانٍ!
