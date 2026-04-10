# Evim Furniture — Auth Architecture Plan

## Loyiha holati

### Tayyor infratuzilma (allaqachon mavjud):
- Firebase Auth integratsiya qilingan (`firebase_auth: ^6.2.0`)
- Token saqlash metodlari tayyor (`shared_prefs.dart`: accessToken, refreshToken, userPhone)
- `flutter_secure_storage: ^10.0.0` — xavfsiz saqlash
- Splash screen Firebase auth tekshiruvini amalga oshiradi
- `Pages.login = '/login'` — route e'lon qilingan, lekin hali ulanmagan
- `features/auth/` papkasi mavjud — lekin ichida hech narsa yo'q
- DI tizimi (`get_it`) tayyor

### Nima kerak:
- Node.js backend API (Express + Firebase Admin)
- Flutter auth feature to'liq implementatsiya

---

## 1. Node.js Backend — Papka tuzilmasi


### API Endpoints

```
POST /auth/register            → Email ro'yxatdan o'tish + 6-digit OTP yuborish
POST /auth/login               → Login (403: tasdiqlanmagan, 404: ro'yxatdan o'tmagan)
POST /auth/verify-otp          → Email OTP tekshirish
POST /auth/resend-otp          → Email OTP qayta yuborish (45s cooldown)
POST /auth/complete-profile    → Profil to'ldirish (name, picture)
GET  /auth/me                  → Joriy foydalanuvchi ma'lumotlari
PUT  /auth/edit-profile        → Profil tahrirlash

POST /auth/phone/send-otp     → SMS OTP yuborish (998XXXXXXXXX format)
POST /auth/phone/verify-otp   → SMS OTP tekshirish → Firebase customToken qaytarish
POST /auth/phone/resend-otp   → SMS OTP qayta yuborish (45s cooldown)
```

### Response formati
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "isNewUser": true,
    "cooldown": 45
  }
}
```

### Error kodlari
```
400 — Bad Request (validation xatolik)
401 — Unauthorized (token yo'q yoki noto'g'ri)
403 — Forbidden (email tasdiqlanmagan)
404 — Not Found (foydalanuvchi topilmadi → shouldRegister: true)
429 — Too Many Requests (rate limit / OTP cooldown)
```

### Asosiy paketlar
```json
{
  "express": "^4.x",
  "firebase-admin": "^12.x",
  "express-rate-limit": "^7.x",
  "express-validator": "^7.x",
  "dotenv": "^16.x",
  "cors": "^2.x",
  "helmet": "^7.x"
}
```

---

## 2. Flutter Frontend — Auth Feature papka tuzilmasi

Mavjud `lib/src/features/auth/` ichiga quriladi:

```
lib/src/features/auth/
│
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart      # Dio orqali API chaqiruvlar
│   ├── models/
│   │   ├── login_response_dto.dart           # Login javob modeli
│   │   ├── register_response_dto.dart        # Register javob modeli
│   │   ├── otp_response_dto.dart             # OTP javob modeli
│   │   ├── user_dto.dart                     # User DTO (API → Domain mapping)
│   │   └── phone_otp_response_dto.dart       # Phone OTP javob modeli
│   └── repositories/
│       └── auth_repository_impl.dart         # Repository implementatsiyasi
│
├── domain/
│   ├── models/
│   │   └── user_model.dart                   # Domain user modeli
│   ├── repositories/
│   │   └── auth_repository.dart              # Abstrakt repository interfeys
│   └── usecases/
│       ├── login_usecase.dart                # POST /auth/login
│       ├── register_usecase.dart             # POST /auth/register
│       ├── verify_otp_usecase.dart           # POST /auth/verify-otp
│       ├── resend_otp_usecase.dart           # POST /auth/resend-otp
│       ├── complete_profile_usecase.dart     # POST /auth/complete-profile
│       ├── get_me_usecase.dart               # GET /auth/me
│       ├── edit_profile_usecase.dart         # PUT /auth/edit-profile
│       ├── send_phone_otp_usecase.dart       # POST /auth/phone/send-otp
│       ├── verify_phone_otp_usecase.dart     # POST /auth/phone/verify-otp
│       └── resend_phone_otp_usecase.dart     # POST /auth/phone/resend-otp
│
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                    # Asosiy auth BLoC
    │   ├── auth_event.dart                   # Auth eventlar
    │   └── auth_state.dart                   # Auth holatlar
    ├── screens/
    │   ├── login_screen.dart                 # Telefon raqami + Ijtimoiy tarmoq tugmalari
    │   ├── otp_screen.dart                   # 6-digit PinCodeTextField + 45s timer
    │   ├── register_screen.dart              # Email orqali ro'yxatdan o'tish
    │   └── complete_profile_screen.dart      # Avatar yuklash + ism kiritish
    └── widgets/
        ├── social_login_button.dart          # Google/Apple tugma widgeti
        ├── phone_input_field.dart            # Telefon raqami inputi (998 prefix)
        ├── otp_timer_widget.dart             # 45s countdown timer
        └── auth_header_widget.dart           # Auth sahifalar uchun umumiy header
```

### Mavjud fayllarga o'zgartirishlar

```
lib/src/core/
├── di/injection.dart              → Auth DI registratsiyalari qo'shiladi
├── network/dio_client.dart        → Auth interceptor qo'shiladi (Bearer token)
├── router/app_router.dart         → Auth routelar qo'shiladi
├── router/pages.dart              → Yangi route nomlari qo'shiladi
└── storage/shared_prefs.dart      → Allaqachon tayyor (token, phone, role)

lib/src/features/
├── splash/splash_screen.dart      → Auth flow logikasi yangilanadi
└── shell/presentation/...         → Profile screen auth bilan bog'lanadi
```

---

## 3. Auth Flow diagrammasi

```
┌─────────────┐
│   Splash    │
│   Screen    │
└──────┬──────┘
       │
       ▼
  Firebase user   ──── YES ──→  Shell (Home)
  mavjudmi?
       │
      NO
       ▼
┌─────────────┐
│   Login     │    ← Telefon raqami kiritish
│   Screen    │    ← Google / Apple / Email tugmalar
└──────┬──────┘
       │
       ├── Phone ──→ POST /auth/phone/send-otp
       │              ▼
       │         ┌─────────┐     POST /auth/phone/verify-otp
       │         │   OTP   │ ──→ customToken qaytaradi
       │         │  Screen │     signInWithCustomToken()
       │         └────┬────┘     ▼
       │              │     isNewUser? ──YES──→ Complete Profile
       │              │         │
       │              │        NO
       │              ▼         ▼
       │           Shell (Home)
       │
       ├── Email ──→ Register Screen
       │              POST /auth/register
       │              ▼
       │         ┌─────────┐     POST /auth/verify-otp
       │         │   OTP   │ ──→ email tasdiqlash
       │         │  Screen │     ▼
       │         └────┬────┘  Complete Profile
       │              │         │
       │              ▼         ▼
       │           Shell (Home)
       │
       └── Google/Apple ──→ Firebase Social Auth
                             POST /auth/login
                             ▼
                          isNewUser? ──YES──→ Complete Profile
                             │
                            NO
                             ▼
                          Shell (Home)
```

---

## 4. DioClient — Auth Interceptor rejasi

```dart
// Qo'shiladigan interceptorlar:
// 1. AuthInterceptor — har bir requestga Bearer token qo'shadi
// 2. ErrorInterceptor — 401 da token refresh, 429 da retry logikasi
// 3. TokenRefreshInterceptor — expired tokenni yangilash
```

---

## 5. Implementatsiya bosqichlari

### Bosqich 1: Node.js Backend
1. Loyiha skeleti (Express + Firebase Admin)
2. Auth email routes (register, login, verify-otp, resend-otp)
3. Auth phone routes (send-otp, verify-otp, resend-otp)
4. Profile routes (complete-profile, me, edit-profile)
5. Middleware (auth, rate-limit, error handler)

### Bosqich 2: Flutter Data Layer
1. Auth DTOs (response modellar)
2. AuthRemoteDataSource (Dio API calls)
3. AuthRepositoryImpl

### Bosqich 3: Flutter Domain Layer
1. UserModel (domain)
2. AuthRepository (abstrakt)
3. UseCases (har bir endpoint uchun)

### Bosqich 4: Flutter Presentation Layer
1. AuthBloc (event, state)
2. LoginScreen (telefon + social buttons)
3. OTPScreen (pin code + timer)
4. RegisterScreen (email)
5. CompleteProfileScreen (avatar + name)

### Bosqich 5: Integratsiya
1. DI registratsiya (injection.dart)
2. Auth Interceptor (dio_client.dart)
3. Router yangilash (app_router.dart)
4. Splash screen flow yangilash

---

## 6. Qo'shimcha paketlar (Flutter - qo'shilishi kerak)

```yaml
# pubspec.yaml ga qo'shiladi:
pin_code_fields: ^8.0.1          # OTP input
google_sign_in: ^6.2.1           # Google auth
sign_in_with_apple: ^6.1.1       # Apple auth
image_picker: ^1.1.2             # Avatar tanlash
```

---

> STATUS: Tasdiqlash kutilmoqda. Bosqich 1 dan boshlash uchun ruxsat bering.
