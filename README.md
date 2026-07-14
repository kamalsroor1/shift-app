# 🏥 ShiftSync — نظام إدارة مناوبات ومكافآت التمريض الذكي

![Python](https://img.shields.io/badge/Python-3.11%2B-blue?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.110%2B-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0%2B-red?style=for-the-badge)
![Alembic](https://img.shields.io/badge/Alembic-Migrations-orange?style=for-the-badge)
![MySQL](https://img.shields.io/badge/MySQL-8.0%2B-00758F?style=for-the-badge&logo=mysql&logoColor=white)
![SDD](https://img.shields.io/badge/Methodology-Spec--Driven--Development-purple?style=for-the-badge)

**ShiftSync** هو نظام خلفي (Backend API) متطور ومبني بأحدث تقنيات الـ **Python (FastAPI + SQLAlchemy 2.0 Async)**، مخصص لتنظيم مناوبات الكوادر التمريضية، إدارة التبادل المالي وساعات العمل، وتتبع حوافز التمريض وربط حسابات العائلة والمرافقين.

تم هندسة هذا المشروع بالكامل وفق معايير **Spec-Driven Development (SDD)** وتطبيق أنظف الأنماط الهندسية (Clean Architecture & Design Patterns):
- 🏗 **Dependency Injection (DI)**
- 📦 **Service Layer & Repository Pattern**
- 🛡 **DTO (Pydantic v2) Pattern**
- 🔄 **Observer / Event Listener Pattern** (للحماية من التلاعب بالسجلات المالية المنتهية)
- ⚙️ **State Machine Pattern** (لإدارة دورات حياة التبادلات وربط الحسابات)

---

## 📋 الفهرس
1. [المتطلبات السابقة (Prerequisites)](#-المتطلبات-السابقة-prerequisites)
2. [التثبيت والإعداد المحلي (Local Development Setup)](#-التثبيت-والإعداد-المحلي-local-development-setup)
3. [دليل أوامر ShiftSync Artisan CLI (manage.py)](#-دليل-أوامر-shiftsync-artisan-cli-managepy)
4. [تشغيل الاختبارات الآلية (Running Tests)](#-تشغيل-الاختبارات-الآلية-running-tests)
5. [دليل النشر على بيئة الإنتاج (Production Deployment)](#-دليل-النشر-على-بيئة-الإنتاج-production-deployment)
6. [هيكل المشروع الفني (Project Structure)](#-هيكل-المشروع-الفني-project-structure)

---

## 🛠 المتطلبات السابقة (Prerequisites)

لتشغيل الباك إند محلياً على جهازك، تأكد من تثبيت الأدوات التالية:
1. **Python 3.11 أو أعلى**: [تحميل Python](https://www.python.org/downloads/) (تأكد من اختيار `Add Python to PATH` أثناء التثبيت على Windows).
2. **قاعدة بيانات MySQL**: يُنصح باستخدام حزمة جاهزة مثل **[Laragon](https://laragon.org/)** أو **XAMPP** أو تشغيل خدمة MySQL 8.0 محلياً.
3. **أداة Git**: لإدارة النُسخ وتحديث الكود.

---

## 🚀 التثبيت والإعداد المحلي (Local Development Setup)

اتبع هذه الخطوات البسيطة لتشغيل المشروع في بيئة التطوير المحلية:

### 1. استنساخ المشروع والدخول إلى مجلد الباك إند
```powershell
git clone https://github.com/kamalsroor1/shift-app.git
cd shift-app/backend
```

### 2. إنشاء وتفعيل البيئة الافتراضية (Virtual Environment)
على نظام **Windows (PowerShell / CMD)**:
```powershell
python -m venv venv
.\venv\Scripts\activate
```
*(على نظام Linux / macOS:* `source venv/bin/activate`*)*

### 3. تثبيت الاعتمادات والمكتبات الحزمة
تأكد من ترقية `pip` أولاً، ثم قم بتثبيت الحزم المطلوبة (بما في ذلك أدوات سطر الأوامر والاختبارات):
```powershell
python -m pip install --upgrade pip
pip install -e .[dev]
```
> **ملاحظة:** الأداة السريعة **`uv`** مدعومة أيضاً في المشروع كبديل فائق السرعة لـ `pip` (`uv sync`).

### 4. إعداد الملفات البيئية (`.env`)
قم بنسخ ملف الإعدادات المبدئي:
```powershell
cp .env.example .env
```
افتح ملف `.env` وقم بتعديل رابط قاعدة البيانات حسب إعدادات جهازك (على سبيل المثال لمستخدمي Laragon افتراضياً):
```ini
# رابط الاتصال بقاعدة البيانات محلياً (باستخدام محرك aiomysql غير المتزامن)
DATABASE_URL="mysql+aiomysql://root:@127.0.0.1:3306/shiftsync_db"

# مفتاح التشفير السري (يمكنك تركه كما هو للتطوير المحلي)
SECRET_KEY="dev-secret-key-for-local-testing-only"
```
*(تأكد من إنشاء قاعدة بيانات باسم `shiftsync_db` في Laragon / MySQL أولاً)*.

### 5. بناء الجداول وإدخال البيانات الأساسية
استخدم أداتنا التفاعلية **`manage.py`** لتجهيز قاعدة البيانات فوراً:
```powershell
# 1. تطبيق جميع الـ Migrations وبناء الجداول
python manage.py migrate

# 2. إدخال البيانات الأولية (أقسام الطوارئ والعناية + حساب المدير العام)
python manage.py db:seed
```

### 6. تشغيل الخادم (API Server)
```powershell
python manage.py serve
```
🎉 **الخادم يعمل الآن!**
- **رابط الـ API الأساسي:** `http://127.0.0.1:8000`
- **التوثيق التفاعلي (Swagger UI):** `http://127.0.0.1:8000/docs`
- **بيانات دخول الـ Admin الافتراضي:**
  - **رقم الهاتف:** `07800000000`
  - **كلمة المرور:** `AdminSecret123!`

---

## ⚡ دليل أوامر ShiftSync Artisan CLI (`manage.py`)

لتوفير تجربة تطوير فائقة السهولة والسرعة تماثل `php artisan` في Laravel، قمنا بإنشاء أداة **`manage.py`** الموجهة بسطر الأوامر (المبنية بمكتبتي `Typer` و `Rich`). يمكنك استخدامها لتنفيذ أي عملية بلمسة واحدة:

| الأمر | الوظيفة | مثال على الاستخدام |
| :--- | :--- | :--- |
| `serve` | تشغيل خادم Uvicorn مع التحديث التلقائي (`--reload`) | `python manage.py serve --port 8000` |
| `test` | تشغيل كافة الاختبارات الآلية (Pytest) بطريقة مرتبة وملونة | `python manage.py test tests/integration/` |
| `migrate` | تطبيق أحدث الـ Migrations على قاعدة البيانات (`alembic upgrade head`) | `python manage.py migrate` |
| `rollback` | التراجع عن آخر Migration (`alembic downgrade -n`) | `python manage.py rollback --steps 1` |
| `make:migration` | فحص الموديلز وتوليد ملف Migration تلقائياً لأي تغيير جديد | `python manage.py make:migration "add status to orders"` |
| `db:seed` | إدخال الأقسام الافتراضية وحساب الـ Super Admin | `python manage.py db:seed` |
| `make:service` | توليد ملف Service احترافي جديد داخل مجلد `app/services/` | `python manage.py make:service Notification` |
| `make:schema` | توليد ملف Pydantic DTO (Create/Update/Response) داخل `app/schemas/` | `python manage.py make:schema NotificationDTO` |

---

## 🧪 تشغيل الاختبارات الآلية (Running Tests)

يحتوي المشروع على حزمة اختبارات شاملة تغطي جميع أجزاء النظام (Unit Tests للنماذج، Integration Tests للـ Endpoints وحماية الـ RBAC ودورات الحياة).
تعمل الاختبارات الآلية داخل **بيئة معزولة بالكامل في الذاكرة (`SQLite Async In-Memory`)** ولا تؤثر إطلاقاً على قاعدة بياناتك الحقيقية.

لتشغيل جميع الاختبارات:
```powershell
python manage.py test
```

لتشغيل اختبارات الـ Integration فقط أو ملف محدد:
```powershell
python manage.py test tests/integration/test_auth_api.py -v
```

لتشغيل الاختبارات مع فحص تغطية الكود (Coverage Report):
```powershell
python manage.py test --cov
```

---

## 🌐 دليل النشر على بيئة الإنتاج (Production Deployment)

عند نقل النظام من بيئة التطوير المحلية إلى السيرفر الحقيقي (Production / Cloud Server)، يجب اتباع أفضل الممارسات الأمنية والتشغيلية التالية:

### 1. إعدادات المتغيرات البيئية (`.env` في الإنتاج)
- **مفتاح سري قوي:** قم بتوليد مفتاح تشفير عشوائي طويل (مثلاً عبر `openssl rand -hex 32`) وضعه في `SECRET_KEY`.
- **قاعدة بيانات مُدارة (Managed Database):** استخدم قاعدة بيانات إنتاجية مثل **AWS RDS MySQL** أو **PostgreSQL** أو **DigitalOcean Managed DB**.
- **إعداد وضع الإنتاج:**
  ```ini
  ENVIRONMENT="production"
  DATABASE_URL="mysql+aiomysql://user:password@production-db-host.com:3306/shiftsync_prod"
  SECRET_KEY="e4a2...<مفتاح_طويل_جداً_ومعقد>...91b0"
  ```

### 2. تشغيل الخادم في الإنتاج (باستخدام Gunicorn + Uvicorn Workers)
في بيئة الإنتاج، لا يُنصح بتشغيل `uvicorn` منفرداً. بدلاً من ذلك، نستخدم **`Gunicorn`** كمدير للعمليات (Process Manager) يشغل عدة عمال **`UvicornWorker`** لضمان استغلال كامل أنوية المعالج (CPU Cores) وتحمل آلاف الطلبات المتزامنة:

```bash
# تثبيت Gunicorn على سيرفر الإنتاج (Linux)
pip install gunicorn

# تشغيل الخادم بـ 4 عمال (Workers) في الخلفية
gunicorn -w 4 -k uvicorn.workers.UvicornWorker app.main:app --bind 0.0.0.0:8000
```
*(أو إعداده كـ Systemd Service للعمل الدائم وإعادة التشغيل التلقائي عند طوارئ السيرفر)*.

### 3. إعداد خادم الـ Reverse Proxy (Nginx / Cloudflare)
يتم وضع **Nginx** أمام Gunicorn للتعامل مع شهادات الأمان (SSL / HTTPS)، وحماية الـ API من هجمات الـ DDOS، وتوجيه الترافيك:
```nginx
server {
    listen 80;
    server_name api.shiftsync.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.shiftsync.com;

    ssl_certificate /etc/letsencrypt/live/api.shiftsync.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.shiftsync.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4. أتمتة الـ Migrations عند النشر (CI/CD Pipeline)
في خط أنابيب النشر الآلي (GitHub Actions أو Docker Entrypoint)، احرص على تشغيل أمر الترقية قبل تشغيل السيرفر لضمان تحديث جداول قاعدة البيانات:
```bash
python manage.py migrate
```

---

## 📁 هيكل المشروع الفني (Project Structure)

```text
shift-app/
│
├── backend/                        # جذر تطبيق الباك إند
│   ├── manage.py                   # أداة ShiftSync Artisan CLI (بديل artisan)
│   ├── pyproject.toml              # تعريف الحزم والإعدادات (بديل composer.json)
│   ├── alembic/                    # مجلد هجرة الجداول (Migrations)
│   │   └── versions/               # جميع إصدارات الـ DDL التراكمية
│   ├── app/                        # النواة الرئيسية للتطبيق
│   │   ├── main.py                 # نقطة انطلاق نقطة FastAPI وموزع الـ Middlewares
│   │   ├── core/                   # إعدادات الأمان (security.py) وإعدادات التطبيق (config.py)
│   │   ├── db/                     # الاتصال بقاعدة البيانات وجلسات SQLAlchemy 2.0 Async
│   │   ├── models/                 # نماذج وقواعد جداول قاعدة البيانات (ORM Models)
│   │   ├── schemas/                # هياكل الـ DTO للتحقق من صحة المدخلات والمخرجات (Pydantic)
│   │   ├── services/               # طبقة منطق الأعمال (Business Logic & Service Layer)
│   │   └── api/                    # تعريف مسارات الـ API (Routers & Endpoints & Dependencies)
│   └── tests/                      # بيئات الاختبارات الآلية (Pytest)
│       ├── conftest.py             # إعدادات حقن قاعدة البيانات الذاكرية المعزولة
│       ├── unit/                   # اختبارات الوحدات والنماذج والقيود
│       ├── integration/            # اختبارات دورات حياة الـ API والـ Auth والـ RBAC
│       └── system/                 # اختبارات النظام الشاملة والـ End-to-End
│
├── specs/                          # ملفات مواصفات وتوثيق الـ Spec-Driven Development
└── .specify/                       # سجلات الـ History وتاريخ التعديلات الهندسية
```

---
**تم التطوير بعناية فائقة بواسطة فريق تطوير ShiftSync 🚀**
