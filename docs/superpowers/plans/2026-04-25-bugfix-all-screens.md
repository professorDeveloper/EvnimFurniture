# Screen Bugfix & Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical bugs (crashes, hardcoded strings, missing error handling) found during pre-App Store review, using Home screen's `_ErrorView`/`AppErrorState` pattern for network errors across all screens.

**Architecture:** Each fix is isolated per feature. Hardcoded strings get localization keys. Network error screens reuse the existing `AppErrorState` widget from `core/widgets/empty_state.dart`. DetailScreen AI state casting is fixed. AuthBloc `.close()` calls removed (already `registerFactory` in DI). NativeArScreen callback moved to `initState`.

**Tech Stack:** Flutter, flutter_bloc, easy_localization, GetIt DI

---

### Task 1: Add missing localization keys to all 3 translation files

**Files:**
- Modify: `assets/translations/en.json`
- Modify: `assets/translations/uz.json`
- Modify: `assets/translations/ru.json`
- Modify: `lib/src/core/constants/app_texts.dart`

- [ ] **Step 1: Add new keys to `app_texts.dart`**

Add these constants at the end of the class (before the closing `}`):

```dart
  // Time formatting
  static const String timeNow = 'timeNow';
  static const String timeMinutesAgo = 'timeMinutesAgo';
  static const String timeHoursAgo = 'timeHoursAgo';
  static const String timeDaysAgo = 'timeDaysAgo';

  // Categories
  static const String categoryFurnitureCount = 'categoryFurnitureCount';
  static const String categoryMaterialCount = 'categoryMaterialCount';

  // Help screen
  static const String helpQ1Title = 'helpQ1Title';
  static const String helpQ1Desc = 'helpQ1Desc';
  static const String helpQ2Title = 'helpQ2Title';
  static const String helpQ2Desc = 'helpQ2Desc';
  static const String helpQ3Title = 'helpQ3Title';
  static const String helpQ3Desc = 'helpQ3Desc';
  static const String helpQ4Title = 'helpQ4Title';
  static const String helpQ4Desc = 'helpQ4Desc';
  static const String helpQ5Title = 'helpQ5Title';
  static const String helpQ5Desc = 'helpQ5Desc';
  static const String helpQ6Title = 'helpQ6Title';
  static const String helpQ6Desc = 'helpQ6Desc';

  // Story/Video errors
  static const String videoError = 'videoError';
  static const String videoLoadFailed = 'videoLoadFailed';

  // Route
  static const String routeNotFound = 'routeNotFound';
```

- [ ] **Step 2: Add keys to `en.json`**

Add before the closing `}`:

```json
  "timeNow": "Just now",
  "timeMinutesAgo": "{} min ago",
  "timeHoursAgo": "{} hours ago",
  "timeDaysAgo": "{} days ago",

  "categoryFurnitureCount": "{} furniture",
  "categoryMaterialCount": "{} materials",

  "helpQ1Title": "How to browse furniture in the app?",
  "helpQ1Desc": "The home page shows categories, popular furniture and combinations. Tap any item to see detailed information.",
  "helpQ2Title": "How to use the AR feature?",
  "helpQ2Desc": "On the furniture page, tap \"Try in your room\". Point your camera at the room, and the furniture will be placed virtually.",
  "helpQ3Title": "How to choose a material?",
  "helpQ3Desc": "Each furniture page shows available materials. You can select the color and material type that suits your style.",
  "helpQ4Title": "How does the favorites list work?",
  "helpQ4Desc": "Tap the heart icon on any furniture you like. All saved items appear in the \"Favorites\" section.",
  "helpQ5Title": "How to change the language?",
  "helpQ5Desc": "Go to the Profile section and tap \"Language\". You can choose Uzbek, Russian or English.",
  "helpQ6Title": "How to contact us?",
  "helpQ6Desc": "You can reach us through the social media links above or call our phone number.",

  "videoError": "Video error",
  "videoLoadFailed": "Video failed to load",
  "routeNotFound": "Page not found"
```

- [ ] **Step 3: Add keys to `uz.json`**

Add before the closing `}`:

```json
  "timeNow": "Hozir",
  "timeMinutesAgo": "{} daqiqa oldin",
  "timeHoursAgo": "{} soat oldin",
  "timeDaysAgo": "{} kun oldin",

  "categoryFurnitureCount": "{} ta mebel",
  "categoryMaterialCount": "{} material",

  "helpQ1Title": "Ilovada mebellarni qanday ko'rish mumkin?",
  "helpQ1Desc": "Bosh sahifada kategoriyalar, mashhur mebellar va kombinatsiyalar ko'rsatiladi. Istalgan mebelni bosib batafsil ma'lumot olishingiz mumkin.",
  "helpQ2Title": "AR rejimda qanday ko'rish mumkin?",
  "helpQ2Desc": "Mebel sahifasida \"Xonangizda sinab ko'ring\" tugmasini bosing. Kamerangizni xonaga yo'naltiring va mebel virtual ravishda joylashtiriladi.",
  "helpQ3Title": "Materialni qanday tanlash mumkin?",
  "helpQ3Desc": "Har bir mebelning sahifasida mavjud materiallar ro'yxati ko'rsatiladi. Siz rangni va material turini tanlashingiz mumkin.",
  "helpQ4Title": "Sevimlilar ro'yxati qanday ishlaydi?",
  "helpQ4Desc": "Yoqqan mebelni yurak belgisi bilan belgilang. Barcha saqlangan mebellar \"Sevimlilar\" bo'limida ko'rinadi.",
  "helpQ5Title": "Tilni qanday o'zgartirish mumkin?",
  "helpQ5Desc": "Profil bo'limiga o'ting va \"Til\" tugmasini bosing. O'zbek, Rus yoki Ingliz tilini tanlashingiz mumkin.",
  "helpQ6Title": "Biz bilan qanday bog'lanish mumkin?",
  "helpQ6Desc": "Yuqoridagi ijtimoiy tarmoqlar orqali yoki telefon raqamimizga qo'ng'iroq qilib biz bilan bog'lanishingiz mumkin.",

  "videoError": "Video xatolik",
  "videoLoadFailed": "Video yuklanmadi",
  "routeNotFound": "Sahifa topilmadi"
```

- [ ] **Step 4: Add keys to `ru.json`**

Add before the closing `}`:

```json
  "timeNow": "Сейчас",
  "timeMinutesAgo": "{} мин назад",
  "timeHoursAgo": "{} ч назад",
  "timeDaysAgo": "{} дн назад",

  "categoryFurnitureCount": "{} мебели",
  "categoryMaterialCount": "{} материалов",

  "helpQ1Title": "Как просматривать мебель в приложении?",
  "helpQ1Desc": "На главной странице отображаются категории, популярная мебель и комбинации. Нажмите на любую мебель, чтобы узнать подробности.",
  "helpQ2Title": "Как посмотреть в режиме AR?",
  "helpQ2Desc": "На странице мебели нажмите \"Попробовать в комнате\". Наведите камеру на комнату, и мебель будет размещена виртуально.",
  "helpQ3Title": "Как выбрать материал?",
  "helpQ3Desc": "На странице каждой мебели отображается список доступных материалов. Вы можете выбрать цвет и тип материала.",
  "helpQ4Title": "Как работает список избранного?",
  "helpQ4Desc": "Отметьте понравившуюся мебель значком сердца. Все сохранённые товары отображаются в разделе \"Избранное\".",
  "helpQ5Title": "Как сменить язык?",
  "helpQ5Desc": "Перейдите в раздел профиля и нажмите \"Язык\". Вы можете выбрать узбекский, русский или английский язык.",
  "helpQ6Title": "Как с нами связаться?",
  "helpQ6Desc": "Вы можете связаться с нами через социальные сети выше или позвонить по нашему номеру телефона.",

  "videoError": "Ошибка видео",
  "videoLoadFailed": "Не удалось загрузить видео",
  "routeNotFound": "Страница не найдена"
```

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/constants/app_texts.dart assets/translations/en.json assets/translations/uz.json assets/translations/ru.json
git commit -m "feat: add missing localization keys for time, categories, help, video errors"
```

---

### Task 2: Fix DetailScreen AI state crash — `state as DetailLoaded` unsafe cast

**Files:**
- Modify: `lib/src/features/detail/presentation/screens/detail_screen.dart` (lines 251-258)

- [ ] **Step 1: Fix the BlocConsumer builder to handle all states**

In `detail_screen.dart`, replace the builder in the `BlocConsumer` (around lines 251-259):

```dart
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          if (state is DetailError) {
            return _ErrorView(onBack: () => Navigator.of(context).pop());
          }
          return _buildBody(context, (state as DetailLoaded).data, isDark);
        },
```

Replace with:

```dart
        builder: (context, state) {
          if (state is DetailLoading || state is DetailInitial) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          if (state is DetailError) {
            return _ErrorView(onBack: () => Navigator.of(context).pop());
          }
          final data = switch (state) {
            DetailLoaded s => s.data,
            DetailAiProcessing s => s.data,
            DetailAiSuccess s => s.data,
            DetailAiError s => s.data,
            _ => null,
          };
          if (data == null) {
            return _LoadingView(onBack: () => Navigator.of(context).pop());
          }
          return _buildBody(context, data, isDark);
        },
```

- [ ] **Step 2: Verify no compile errors**

Run: `cd /Users/saikou/EvnimFurniture && flutter analyze lib/src/features/detail/presentation/screens/detail_screen.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/detail/presentation/screens/detail_screen.dart
git commit -m "fix: handle AI states in DetailScreen builder to prevent TypeError crash"
```

---

### Task 3: Fix DetailScreen `_ErrorView` — add retry button using Home's error pattern

**Files:**
- Modify: `lib/src/features/detail/presentation/screens/widgets/detail_common_widgets.dart` (lines 204-232)
- Modify: `lib/src/features/detail/presentation/screens/detail_screen.dart` (ErrorView usage)

- [ ] **Step 1: Update `_ErrorView` to include retry**

In `detail_common_widgets.dart`, replace the `_ErrorView` class (lines 204-232):

```dart
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 44, color: AppColors.grey300),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: Text(
              AppTexts.back.tr(),
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Replace with:

```dart
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onBack, this.onRetry});

  final VoidCallback onBack;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 52,
                  color: isDark ? AppColors.grey600 : AppColors.grey300,
                ),
                const SizedBox(height: 16),
                Text(
                  AppTexts.errorNoConnection.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTexts.errorNoConnectionDesc.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 24),
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      AppTexts.errorRetry.tr(),
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: top + 8,
          left: 12,
          child: _HBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
            collapsed: false,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Update `_ErrorView` usage in `detail_screen.dart`**

In `detail_screen.dart`, find the error handling in the builder (around line 255-256):

```dart
          if (state is DetailError) {
            return _ErrorView(onBack: () => Navigator.of(context).pop());
          }
```

Replace with:

```dart
          if (state is DetailError) {
            return _ErrorView(
              onBack: () => Navigator.of(context).pop(),
              onRetry: () => context.read<DetailBloc>().add(
                DetailFetchRequested(furnitureMaterialId: _currentMaterialId),
              ),
            );
          }
```

Note: This must be inside the `_DetailViewState` build method's `BlocConsumer.builder`, where `_currentMaterialId` is accessible. The `_ErrorView` usage here is inside `_DetailViewState.build()` so `_currentMaterialId` is in scope.

- [ ] **Step 3: Verify no compile errors**

Run: `cd /Users/saikou/EvnimFurniture && flutter analyze lib/src/features/detail/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/src/features/detail/presentation/screens/widgets/detail_common_widgets.dart lib/src/features/detail/presentation/screens/detail_screen.dart
git commit -m "fix: add retry button and network error view to DetailScreen error state"
```

---

### Task 4: Fix AuthBloc manual `.close()` calls — remove them (DI uses `registerFactory`)

**Files:**
- Modify: `lib/src/features/auth/presentation/screens/login_screen.dart`
- Modify: `lib/src/features/auth/presentation/screens/otp_screen.dart`
- Modify: `lib/src/features/auth/presentation/screens/complete_profile_screen.dart`
- Modify: `lib/src/features/auth/presentation/screens/edit_profile_screen.dart`
- Modify: `lib/src/features/profile/presentation/screens/profile_screen.dart`

The DI registers `AuthBloc` as `registerFactory` (injection.dart:166), meaning each `sl<AuthBloc>()` call returns a **new instance**. Each screen creates its own bloc and is responsible for closing it. However, screens manually call `_authBloc.close()` in `dispose()` while also wrapping it in `BlocProvider.value`. The correct fix is to use `BlocProvider(create:)` instead of `BlocProvider.value` so the provider manages the lifecycle automatically.

- [ ] **Step 1: Fix LoginScreen**

Read `login_screen.dart` and find the pattern:
1. Remove the `late final AuthBloc _authBloc;` field and `_authBloc = sl<AuthBloc>();` in `initState`
2. Remove `_authBloc.close();` in `dispose()`
3. Change `BlocProvider.value(value: _authBloc, ...)` to `BlocProvider(create: (_) => sl<AuthBloc>(), ...)`
4. Replace all `_authBloc.add(...)` with `context.read<AuthBloc>().add(...)`

- [ ] **Step 2: Fix OtpScreen**

Same pattern as Step 1.

- [ ] **Step 3: Fix CompleteProfileScreen**

Same pattern as Step 1.

- [ ] **Step 4: Fix EditProfileScreen**

Same pattern as Step 1.

- [ ] **Step 5: Fix ProfileScreen**

Same pattern as Step 1.

- [ ] **Step 6: Verify no compile errors**

Run: `cd /Users/saikou/EvnimFurniture && flutter analyze lib/src/features/auth/ lib/src/features/profile/`
Expected: No errors

- [ ] **Step 7: Commit**

```bash
git add lib/src/features/auth/presentation/screens/login_screen.dart lib/src/features/auth/presentation/screens/otp_screen.dart lib/src/features/auth/presentation/screens/complete_profile_screen.dart lib/src/features/auth/presentation/screens/edit_profile_screen.dart lib/src/features/profile/presentation/screens/profile_screen.dart
git commit -m "fix: remove manual AuthBloc.close() calls, use BlocProvider(create:) for proper lifecycle"
```

---

### Task 5: Fix StoryViewerScreen — hardcoded strings + timer/video race condition

**Files:**
- Modify: `lib/src/features/home/presentation/screens/story_viewer_screen.dart`

- [ ] **Step 1: Add localization import and fix hardcoded strings**

Add import at top:
```dart
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_texts.dart';
```

Replace `_formatDate` method (lines 167-177):

```dart
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';
    return '${date.day}/${date.month}/${date.year}';
  }
```

With:

```dart
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return AppTexts.timeNow.tr();
    if (diff.inMinutes < 60) return AppTexts.timeMinutesAgo.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return AppTexts.timeHoursAgo.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return AppTexts.timeDaysAgo.tr(args: ['${diff.inDays}']);
    return '${date.day}/${date.month}/${date.year}';
  }
```

Replace hardcoded `'Video xatolik'` (line 93) with `AppTexts.videoError.tr()`.

Replace hardcoded `'Video yuklanmadi'` (line 236) with `AppTexts.videoLoadFailed.tr()`.

- [ ] **Step 2: Fix timer/video race condition in `_goToNext` and `_goToPrev`**

Replace `_goToNext` (lines 137-146):

```dart
  void _goToNext() {
    if (_index < widget.items.length - 1) {
      _index++;
      _loadCurrentMedia();
      _startTimer();
      if (mounted) setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }
```

With:

```dart
  void _goToNext() {
    if (_index < widget.items.length - 1) {
      _index++;
      _loadCurrentMedia().then((_) {
        if (mounted) _startTimer();
      });
      if (mounted) setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }
```

Replace `_goToPrev` (lines 148-158):

```dart
  void _goToPrev() {
    if (_index > 0) {
      _index--;
      _loadCurrentMedia();
      _startTimer();
      if (mounted) setState(() {});
    } else {
      _progressController.reset();
      _progressController.forward();
    }
  }
```

With:

```dart
  void _goToPrev() {
    if (_index > 0) {
      _index--;
      _loadCurrentMedia().then((_) {
        if (mounted) _startTimer();
      });
      if (mounted) setState(() {});
    } else {
      _progressController.reset();
      _progressController.forward();
    }
  }
```

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/home/presentation/screens/story_viewer_screen.dart
git commit -m "fix: localize hardcoded strings and fix timer/video race in StoryViewerScreen"
```

---

### Task 6: Fix NativeArScreen — move `addPostFrameCallback` from `build()` to `initState()`

**Files:**
- Modify: `lib/src/features/detail/presentation/screens/native_ar_screen.dart`

- [ ] **Step 1: Convert to StatefulWidget for iOS path**

Replace the entire `NativeArScreen` class:

```dart
class NativeArScreen extends StatefulWidget {
  const NativeArScreen({
    super.key,
    required this.modelUrl,
    required this.title,
  });

  final String modelUrl;
  final String title;

  @override
  State<NativeArScreen> createState() => _NativeArScreenState();
}

class _NativeArScreenState extends State<NativeArScreen> {
  static const _arChannel = MethodChannel('com.evim/ar');
  static bool _arOpening = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openIOSAR());
    }
  }

  Future<void> _openIOSAR() async {
    if (_arOpening) return;
    _arOpening = true;
    try {
      await _arChannel.invokeMethod('openAR', {
        'glbUrl': widget.modelUrl,
        'title': widget.title,
        'locale': context.locale.languageCode,
      });
    } catch (e) {
      debugPrint('iOS AR error: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _arOpening = false;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F0),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F0);
    final textColor = isDark ? Colors.white : Colors.black87;
    final safeTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                src: widget.modelUrl,
                ar: true,
                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                arScale: ArScale.auto,
                autoRotate: true,
                cameraControls: true,
                shadowIntensity: 1,
                backgroundColor: bgColor,
                interactionPrompt: InteractionPrompt.none,
              ),
            ),
            Positioned(
              top: safeTop + 8,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/features/detail/presentation/screens/native_ar_screen.dart
git commit -m "fix: move addPostFrameCallback to initState in NativeArScreen to prevent repeated calls"
```

---

### Task 7: Fix Favourites `furnitureId: ''` — pass correct ID

**Files:**
- Modify: `lib/src/features/favourites/domain/model/favourite_item.dart`
- Modify: `lib/src/features/favourites/presentation/screens/favourites_screen.dart` (line 156)

- [ ] **Step 1: Add `furnitureId` to `FavouriteItem` model**

In `favourite_item.dart`, add the field:

```dart
class FavouriteItem {
  const FavouriteItem({
    required this.id,
    required this.furnitureId,
    required this.furnitureMaterialId,
    required this.furnitureName,
    this.thumbnailImage,
    required this.materialName,
    required this.createdAt,
  });

  final String id;
  final String furnitureId;
  final String furnitureMaterialId;
  final String furnitureName;
  final String? thumbnailImage;
  final String materialName;
  final DateTime createdAt;

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    final fm = json['furnitureMaterialId'] as Map<String, dynamic>? ?? {};
    final furniture = fm['furnitureModelId'] as Map<String, dynamic>? ?? {};
    final material = fm['materialId'] as Map<String, dynamic>? ?? {};

    return FavouriteItem(
      id: json['_id'] as String? ?? '',
      furnitureId: furniture['_id'] as String? ?? '',
      furnitureMaterialId: fm['_id'] as String? ?? '',
      furnitureName: furniture['name'] as String? ?? '',
      thumbnailImage: furniture['thumbnailImage'] as String?,
      materialName: material['name'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
```

- [ ] **Step 2: Fix navigation in `favourites_screen.dart`**

In `favourites_screen.dart`, replace the navigation (lines 153-159):

```dart
        Navigator.of(context).pushNamed(
          Pages.furnitureDetail,
          arguments: {
            'furnitureId': '',
            'furnitureMaterialId': item.furnitureMaterialId,
          },
        );
```

With:

```dart
        Navigator.of(context).pushNamed(
          Pages.furnitureDetail,
          arguments: {
            'furnitureId': item.furnitureId,
            'furnitureMaterialId': item.furnitureMaterialId,
          },
        );
```

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/favourites/domain/model/favourite_item.dart lib/src/features/favourites/presentation/screens/favourites_screen.dart
git commit -m "fix: pass correct furnitureId from Favourites to Detail screen"
```

---

### Task 8: Fix NotificationsScreen — localize hardcoded time strings

**Files:**
- Modify: `lib/src/features/notifications/presentation/screens/notifications_screen.dart`

- [ ] **Step 1: Add import and replace `_formatDate`**

Add at top (if not already present):
```dart
import '../../../../core/constants/app_texts.dart';
```

Replace the `_formatDate` method in `_NotificationCard` (lines 224-236):

```dart
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Hozir';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    if (diff.inDays < 7) return '${diff.inDays} kun oldin';

    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
```

With:

```dart
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return AppTexts.timeNow.tr();
    if (diff.inMinutes < 60) return AppTexts.timeMinutesAgo.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return AppTexts.timeHoursAgo.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return AppTexts.timeDaysAgo.tr(args: ['${diff.inDays}']);

    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/features/notifications/presentation/screens/notifications_screen.dart
git commit -m "fix: localize hardcoded time strings in NotificationsScreen"
```

---

### Task 9: Fix HelpScreen — use localization keys instead of manual switch

**Files:**
- Modify: `lib/src/features/help/presentation/screens/help_screen.dart`

- [ ] **Step 1: Replace `_HelpItem` model and list with localization keys**

Replace the `_items` list (lines 17-84) with:

```dart
  final List<_HelpItem> _items = [
    _HelpItem(titleKey: AppTexts.helpQ1Title, descKey: AppTexts.helpQ1Desc),
    _HelpItem(titleKey: AppTexts.helpQ2Title, descKey: AppTexts.helpQ2Desc),
    _HelpItem(titleKey: AppTexts.helpQ3Title, descKey: AppTexts.helpQ3Desc),
    _HelpItem(titleKey: AppTexts.helpQ4Title, descKey: AppTexts.helpQ4Desc),
    _HelpItem(titleKey: AppTexts.helpQ5Title, descKey: AppTexts.helpQ5Desc),
    _HelpItem(titleKey: AppTexts.helpQ6Title, descKey: AppTexts.helpQ6Desc),
  ];
```

Add import if not present:
```dart
import '../../../../core/constants/app_texts.dart';
```

Replace the `_HelpItem` class (lines 209-249) with:

```dart
class _HelpItem {
  final String titleKey;
  final String descKey;
  bool isExpanded;

  _HelpItem({
    required this.titleKey,
    required this.descKey,
    this.isExpanded = true,
  });
}
```

In the ListView.itemBuilder, replace `item.localizedTitle(context)` with `item.titleKey.tr()` and `item.localizedDesc(context)` with `item.descKey.tr()`.

- [ ] **Step 2: Commit**

```bash
git add lib/src/features/help/presentation/screens/help_screen.dart
git commit -m "fix: use localization system for HelpScreen FAQ items"
```

---

### Task 10: Fix CategoriesViewAllScreen — localize hardcoded strings

**Files:**
- Modify: `lib/src/features/category/presentation/screens/categories_view_all_screen.dart`

- [ ] **Step 1: Replace hardcoded `'ta mebel'`**

In `categories_view_all_screen.dart`, replace line 209:

```dart
'${item.furnitureCount} ta mebel',
```

With:

```dart
AppTexts.categoryFurnitureCount.tr(args: ['${item.furnitureCount}']),
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/features/category/presentation/screens/categories_view_all_screen.dart
git commit -m "fix: localize furniture count string in CategoriesViewAllScreen"
```

---

### Task 11: Fix CategoryFurnitureScreen — localize hardcoded strings

**Files:**
- Modify: `lib/src/features/category/presentation/screens/category_furniture_screen.dart`

- [ ] **Step 1: Replace hardcoded strings**

Line 222 — replace `'${widget.category.furnitureCount} ta'` with `AppTexts.categoryFurnitureCount.tr(args: ['${widget.category.furnitureCount}'])`.

Line 357 — replace `'${items.length} ta mebel'` with `AppTexts.categoryFurnitureCount.tr(args: ['${items.length}'])`.

Line 489 — replace `'${item.stats.materialCount} material'` with `AppTexts.categoryMaterialCount.tr(args: ['${item.stats.materialCount}'])`.

- [ ] **Step 2: Commit**

```bash
git add lib/src/features/category/presentation/screens/category_furniture_screen.dart
git commit -m "fix: localize hardcoded count strings in CategoryFurnitureScreen"
```

---

### Task 12: Fix AiResultScreen — wrap base64Decode in try/catch

**Files:**
- Modify: `lib/src/features/detail/presentation/screens/ai_result_screen.dart`

- [ ] **Step 1: Add error handling in initState**

Replace the `initState` and add an error field:

```dart
class _AiResultScreenState extends State<AiResultScreen> {
  bool _saving = false;
  bool _sharing = false;
  Uint8List? _bytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    try {
      final str = widget.base64Image.contains(',')
          ? widget.base64Image.split(',').last
          : widget.base64Image;
      _bytes = base64Decode(str);
    } catch (_) {
      _hasError = true;
    }
  }
```

- [ ] **Step 2: Handle error state in build**

At the top of the `build` method, after getting `isDark`, add:

```dart
    if (_hasError || _bytes == null) {
      return Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: pageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 18),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_rounded, size: 52, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(
                AppTexts.detailAiError.tr(),
                style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey500),
              ),
            ],
          ),
        ),
      );
    }
```

Update `_bytes` usages — since `_bytes` is now nullable, use `_bytes!` in `_save()`, `_share()`, and `Image.memory()` (they are only reachable when `_bytes != null` due to the early return above).

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/detail/presentation/screens/ai_result_screen.dart
git commit -m "fix: wrap base64Decode in try/catch to prevent crash on malformed AI response"
```

---

### Task 13: Fix AppRouter default route — localize "Route not found"

**Files:**
- Modify: `lib/src/core/router/app_router.dart`

- [ ] **Step 1: Replace hardcoded string**

Add import:
```dart
import 'package:easy_localization/easy_localization.dart';
import '../constants/app_texts.dart';
```

Replace line 99:
```dart
const Scaffold(body: Center(child: Text('Route not found'))),
```

With:
```dart
Scaffold(body: Center(child: Text(AppTexts.routeNotFound.tr()))),
```

(Remove `const` since `.tr()` is not const.)

- [ ] **Step 2: Commit**

```bash
git add lib/src/core/router/app_router.dart
git commit -m "fix: localize route not found text in AppRouter"
```

---

### Task 14: Final verification

- [ ] **Step 1: Run full analysis**

```bash
cd /Users/saikou/EvnimFurniture && flutter analyze
```

Expected: 0 errors (warnings OK)

- [ ] **Step 2: Build iOS**

```bash
cd /Users/saikou/EvnimFurniture && flutter build ios --no-codesign
```

Expected: Build succeeds
