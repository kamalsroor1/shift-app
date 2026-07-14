<p align="center">
  <img src="files/full-logo-with-text.png" alt="Shiftak Official Logo" width="360" />
</p>

# 🏥 Shiftak • شِفْتَك
**نظام إدارة المناوبات الطبية، تبديل الورديات الذكي، والتسويات المالية الفورية للكوادر الصحية**  
*(Arabic-First / RTL-Default Medical & Financial Roster System)*

---

## 🌟 نبذة عن المشروع (Project Overview)
**شِفْتَك (`Shiftak`)** هو نظام متكامل وموجه للكوادر الطبية والممرضين في الأقسام الحرجة والعناية المركزة (`ICU`). يهدف النظام إلى القضاء تماماً على فوضى جداول الورديات الورقية ومحادثات الواتساب غير المنظمة، من خلال توفير:
- 📅 **جدول ورديات ذكي ومتزامن:** تصفح شهر بشهر، أو عرض أسبوعي سريع مع تصنيف دقيق للورديات (صباحية طويلة ١٢ ساعة، سهر ليلي، يوم راحة).
- 🔄 **سوق تبادلات فوري (`Shift Marketplace & Swap Engine`):** إمكانية عرض الورديات للبيع أو طلب التبادل مع الزملاء مع موافقات آلية ومنظمة من رؤساء الأقسام.
- 💷 **محفظة مالية وتسوية بالجنيه المصري (`EGP Double-Entry Ledger`):** تسجيل ومتابعة المستحقات والديون بين الزملاء بناءً على التبادلات (`عليا فلوس I OWE` و `ليا فلوس OWED TO ME`) بقيمة قياسية للمناوبة (`٤٠٠ ج.م`).
- 🇸🇦🇪🇬 **تصميم عربي أصيل (`Arabic-First RTL Architecture`):** واجهة مستخدم فائقة الأناقة تعتمد خط **`Cairo`** الطبي الواضح، بطاقات بيضاء ناصعة عائمة، وأشرطة ألوان توضيحية على الحافة اليمنى للبطاقة (`Right-Side Accent Bars`).

---

## 🛠️ البنية التقنية (Technology Stack)

### ⚙️ الخادم والواجهات البرمجية (`Backend Engine`)
- **الإطار البرمجي:** Python 3.12+ • FastAPI (Async/Await)
- **قاعدة البيانات:** SQLAlchemy 2.0 ORM • Alembic Migrations • MySQL 8.0 (Production) / SQLite (Tests)
- **الأمان والمصادقة:** OAuth2 with Password Bearer • JWT Token Pair (`access_token` & `refresh_token`) • Role-Based Access Control (`admin` vs `nurse`)
- **الجودة والاختبارات:** `Pytest` Integration Suite (**23/23 Tests Passed** `100% SUCCESS`) + Comprehensive Postman Collection

### 📱 واجهة المستخدم متعددة المنصات (`Flutter Mobile, Web & Desktop`)
- **إطار التطوير:** Flutter 3.22+ • Dart 3.12+
- **إدارة الحالة:** `flutter_riverpod` (StateNotifier / FutureProvider / StreamProvider)
- **الاتصال والتخزين:** `dio` API Client • `flutter_secure_storage` • `hive` local offline caching
- **التوطين والخطوط:** `flutter_localizations` (`Locale('ar')` default) • `google_fonts` (`Cairo`) • `table_calendar` interactive bilingual views

---

## 🗺️ خريطة تطوير المشروع ومراحل الإنجاز (`Project Roadmap & Phases`)

تم توثيق كل مرحلة وتاسك بدقة متناهية في مواصفاتنا الرسمية [ai_roles_and_tasks.md](specs/ai_roles_and_tasks.md):

| المرحلة (`Phase`) | الوصف والمخرج الرئيسي | الحالة |
| :--- | :--- | :---: |
| **Phase 1** | **الهيكل وقواعد البيانات (`Database Migrations & Models`)**<br>بناء 7 جداول أساسية (Users, Departments, Schedules, Swaps, Sales, Ledger, Audits) وإعداد Alembic. | 🟢 **مكتمل 100%** |
| **Phase 2** | **المصادقة والأقسام (`Authentication & Family Links`)**<br>بناء نظام JWT الآمن، ربط الأقسام، والإصلاح الذاتي للمسؤول (`Self-Healing Admin`). | 🟢 **مكتمل 100%** |
| **Phase 3** | **محرك التبادلات والمالية (`Swaps, Marketplace & Ledger APIs`)**<br>آلة حالة التبادلات (`State Machine`) ونظام القيد المزدوج للجنيه المصري (`Double-Entry Ledger`). | 🟢 **مكتمل 100%** |
| **Phase 4** | **واجهة المستخدم العربية (`Flutter Arabic-First RTL UI`)**<br>نظام التصميم (`AppTokens`)، شاشة الترحيب (`WelcomeScreen`)، تسجيل الدخول، التقويم التفاعلي (`ShiftCalendar`)، كروت الديون المصرية (`EGP Cards`)، والقائمة السفلية الرسمية بـ 5 تبويبات. | 🟢 **مكتمل 100%** |
| **Phase 5** | **الربط الحي بالواجهات (`API Integration & State Refresh`)**<br>ربط Dio بـ Riverpod، جلب الجداول الحقيقية للمناوبات والمحفظة وحفظها محلياً في Hive. | 🟡 **قيد التنفيذ** |
| **Phase 6** | **إشعارات WebSockets & FCM الحية (`Real-Time Notifications`)**<br>بث إشعارات طلبات التبادل والتسوية المالية لحظياً على شاشات الممرضين. | ⏳ **مجدول** |
| **Phase 7** | **لوحة التحكم الإدارية للويب (`Admin Web Dashboard - ICU Heads`)**<br>واجهة ويب لرؤساء الأقسام لمراقبة جداول الكادر والمصادقة والتدقيق المالي بـ `ج.م`. | ⏳ **مجدول** |
| **Phase 8** | **الحاويات والنشر المستمر (`Dockerization, CI/CD & Production`)**<br>إعداد `Dockerfile`، مسارات `GitHub Actions` الآلية، والنشر السحابي. | ⏳ **مجدول** |

---

## 🚀 دليل التشغيل السريع (`Quick Start Guide`)

### 1️⃣ تشغيل الخادم البرمجي (`Backend Server`)
تأكد من وجود بايثون وتفعيل البيئة الافتراضية، ثم نفذ:
```powershell
cd backend
# 1. تفعيل البيئة الافتراضية
.\venv\Scripts\activate

# 2. تطبيق الترحيلات وإنشاء البيانات الأساسية والمسؤول
python manage.py db:migrate
python manage.py db:seed

# 3. تشغيل جميع اختبارات الجودة للتحقق (23 اختبار)
python manage.py test

# 4. تشغيل الخادم على المنفذ 8000
python manage.py run
```
*وثائق الـ API التفاعلية متاحة على:* `http://localhost:8000/docs`

---

### 2️⃣ تشغيل تطبيق الفلاتر (`Flutter Application`)
يمكنك تشغيل التطبيق على متصفح **Microsoft Edge / Chrome** السريع مباشرة أو نافذة Windows:
```powershell
cd shiftsync_app

# 1. جلب الحزم المحدثة
flutter pub get

# 2. تشغيل واجهة الاستعراض العربية على متصفح Edge
flutter run -d edge

# أو تشغيله كبرنامج سطح مكتب على Windows (إذا كان وضع المطور مفعلاً)
flutter run -d windows
```

---

## 📑 الوثائق والمرجعيات الفنية (`Documentation & Specs`)
يحتوي المشروع على نظام توثيق متقدم وهيكلية حوكمة لوكلاء الذكاء الاصطناعي (`AI Roles & Governance`):
- 📘 **[مواصفات الأدوار والمهام (`specs/ai_roles_and_tasks.md`)](specs/ai_roles_and_tasks.md):** دليل العمليات الموحد (SOP) الذي ينظم مهام وكلاء الـ Backend و Flutter و QA و DevOps والقواعد الصارمة مثل `RULE-007 (Arabic-First RTL)`.
- 🎨 **[مواصفات تجربة المستخدم والتصميم (`specs/ui_ux_spec.md`)](specs/ui_ux_spec.md):** معايير البطاقات البيضاء العائمة، شارات الورديات، وقواعد الألوان الهادئة المعتمدة على مرجعنا التصميمي.
- 📦 **[دليل واجهات الـ Postman (`docs/postman/README.md`)](docs/postman/README.md):** إرشادات تشغيل واختبار جميع مسارات الخادم عبر مجموعات Postman المحدثة.

---
*تم تطوير وصيانة النظام بحب ودقة متناهية لخدمة أبطال العناية المركزة والقطاع الصحي 🇸🇦🇮🇶🇪🇬*
