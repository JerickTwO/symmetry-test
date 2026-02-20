# 📋 Project Report — News App (Flutter + Clean Architecture)

**Author:** Jerick Dev  
**Date:** February 20, 2026  
**Project:** `conectar_flutter_firebase` — News article management app  
**Tech Stack:** Flutter 3.x · Dart · Firebase · BLoC · GetIt · Clean Architecture

---

## 1. Project Overview

This application is a **news article management platform** built with Flutter and Firebase, following **Symmetry's Clean Architecture** guidelines. It allows users to log in with existing accounts, create/edit/delete articles with Markdown content, manage categories, and upload thumbnail images — all backed by Firebase Auth, Cloud Firestore, and Firebase Storage.

### Key Features Implemented

| Feature | Description |
|---|---|
| **Authentication** | Email/password sign-in, sign-out, and automatic session persistence via `CheckAuthStatus`. Registration disabled - users can only sign in with existing accounts |
| **Public Article View** | Unauthenticated users can browse all articles in read-only mode without login |
| **Article CRUD** | Full create, read, update, and delete operations for news articles stored in Firestore (authenticated users only) |
| **Markdown Editor** | Custom editor widget with formatting toolbar (bold, italic, headings, lists, links, code) and live preview |
| **Image Uploads** | Thumbnail image picker (gallery + camera) with Firebase Storage upload |
| **Category System** | Dynamic category management — search, filter, and create new categories on the fly |
| **Splash Screen** | Loading screen with automatic auth state detection and navigation |
| **Localization** | i18n-ready setup with ARB files and generated localizations |
| **Theme Support** | Light and dark theme configurations with a `SettingsController` |

---

## 2. Architecture

The project strictly follows **Clean Architecture** with a feature-based folder structure. Each feature (`auth`, `articles`) is self-contained with three layers:

```
lib/
├── core/              # Shared abstractions (DataState, UseCase, Failure, constants)
├── config/            # Routes, themes
├── features/
│   ├── auth/
│   │   ├── data/          # Models, DataSources, Repository implementations
│   │   ├── domain/        # Entities, Repository contracts, Use Cases
│   │   └── presentation/  # BLoC, Screens
│   ├── articles/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   └── splash/
├── generated/         # Localization files
└── src/               # App widget, settings
```

### Layer Communication Rules

- **Presentation → Domain:** Only through Use Cases. BLoCs/Cubits call `UseCase.call(Params)`.
- **Domain → Data:** Domain defines abstract repository contracts; Data implements them.
- **Data → External:** Only Data Sources touch Firebase SDKs. Models handle serialization.
- **Domain Layer:** Pure Dart — zero external dependencies. Entities, repository contracts, and use cases live here.

### Core Abstractions

| Abstraction | Purpose |
|---|---|
| `DataState<T>` | Generic success/error wrapper for all repository returns. Provides `.isSuccess`, `.isError`, `.data`, `.error` |
| `UseCase<T, Params>` | Abstract base class enforcing `Future<T> call(Params)` contract for every use case |
| `NoParams` | Sentinel class for use cases that take no arguments |
| `Failure` hierarchy | `ServerFailure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `CacheFailure` (defined for future use) |

---

## 3. State Management

**flutter_bloc** is used throughout:

| Component | Type | Responsibility |
|---|---|---|
| `AuthBloc` | BLoC | Sign-in, sign-out, and auth status check (sign-up code exists but is unused) |
| `ArticleBloc` | BLoC | CRUD operations for articles + image upload orchestration |
| `CategoryCubit` | Cubit | Load and add categories with local cache |

BLoCs are registered as **factories** in GetIt (new instance per widget tree scope), while data sources, repositories, and use cases are **lazy singletons**.

---

## 4. Dependency Injection

`GetIt` is configured in `service_locator.dart` with a clean, organized structure split into focused registration functions:

- `_registerExternalServices()` — Firebase instances
- `_registerAuthDependencies()` — Auth data source → repository → 4 use cases
- `_registerArticleDependencies()` — Article data source → repository → 5 use cases
- `_registerStorageDependencies()` — Storage data source → repository → upload use case
- `_registerCategoryDependencies()` — Category data source → repository → 2 use cases
- `_registerBlocs()` — AuthBloc, ArticleBloc, CategoryCubit

---

## 5. Architecture Rules Applied

The codebase was audited and refactored to comply with the following architecture rules:

### Rule 1.3.2 — Models must have `toEntity()`
All models (`ArticleModel`, `CategoryModel`, `UserModel`) implement `toEntity()` to convert data-layer models into domain-layer entities, maintaining layer separation.

### Rule 1.3.3 — Models must have `fromRawData(Map<String, dynamic>)`
All models implement a `fromRawData` factory constructor. Source-specific factories (e.g., `fromFirestore`) delegate to `fromRawData` for consistency.

### Rule 1.4.3 — Repositories return `DataState<T>`
All repository contracts and implementations wrap responses in `DataState.success()` or `DataState.error()`. This eliminated raw `try/catch` in BLoCs, which now simply check `result.isSuccess` / `result.isError`.

---

## 6. Coding Guidelines Applied

A comprehensive audit was performed against CG1–CG6 guidelines. Below are all violations found and fixed:

### CG6.1 — All Use Cases Extend `UseCase<T, Params>`
**Problem:** The 4 auth use cases (`SignInUseCase`, `SignUpUseCase`, `SignOutUseCase`, `GetCurrentUserUseCase`) did not extend the `UseCase` abstract class, while all article use cases did. Note: `SignUpUseCase` remains in code but is no longer used in the application.

**Fix:** All auth use cases now extend `UseCase<T, Params>` with proper `@override` annotations. `SignOutUseCase` and `GetCurrentUserUseCase` now accept `NoParams` instead of zero arguments. The `AuthBloc` was updated to pass `const NoParams()` to those use cases.

### CG3.1 — Small Functions (≤20 lines)
**Problems found and fixed:**

| File | Before | After |
|---|---|---|
| `service_locator.dart` | Single 100+ line `initializeDependencies()` | Split into 6 focused registration functions |
| `article_card.dart` | Monolithic 130-line `build()` | Decomposed into `_buildThumbnailSection()`, `_buildContentSection()`, `_buildCategoryBadge()`, `_buildTitle()`, `_buildMarkdownPreview()`, `_buildFooter()` |
| `article_detail_screen.dart` | 80-line `build()` | Decomposed into `_buildThumbnail()`, `_buildCategoryBadge()`, `_buildTitle()`, `_buildAuthorDateRow()`, `_buildMarkdownContent()` |

### CG3.2 — Max Nesting Depth 2
**Problem:** `auth_firebase_data_source_impl.dart` had `try → on FirebaseAuthException → switch → case` nesting (depth 3) in both `signIn()` and `signUp()`.

**Fix:** Extracted `_mapSignInException()`, `_mapSignUpException()`, `_buildUserModel()`, and `_saveUserToFir estore()` helper methods to flatten the nesting. Note: `signUp()` and related methods remain in codebase but are no longer called.

### CG3.3 — Single Responsibility / No Duplication
**Problem:** `ArticleBloc._onCreateArticle()` and `_onUpdateArticle()` both contained identical image-upload logic (~15 lines duplicated).

**Fix:** Extracted `_uploadImageIfNeeded()` shared helper method that both handlers call.

### CG3.5 — Max 3 Function Arguments
**Problem:** `createArticle()` had 6 parameters and `updateArticle()` had 5 parameters passed individually through the repository contract → data source contract → implementation chain.

**Fix:** Propagated `CreateArticleParams` and `UpdateArticleParams` objects through the entire chain (domain repository → data repository impl → data source contract → data source impl), replacing 6 and 5 individual params with a single params object each.

### CG5.1 — One Class Per File
**Problem:** `article_form_screen.dart` was 736 lines containing 3 classes: `ArticleFormScreenWrapper`, `ArticleFormScreen`, and `_CategorySearchField` (250+ lines).

**Fix:** Extracted `CategorySearchField` to its own file at `widgets/category_search_field.dart` as a public, reusable widget. The form screen now imports and uses it.

### CG2.5 — Intention-Revealing Names (Verb-Based for Functions)
**Fixes applied:**

| Before | After | File |
|---|---|---|
| `_toolbarDivider()` | `_buildToolbarDivider()` | `markdown_editor.dart` |
| `_placeholderFor()` | `_getPlaceholderFor()` | `markdown_editor.dart` |
| `_authStateListener()` | `_handleAuthStateChange()` | `signin_screen.dart` |

---

## 7. File Inventory (55+ Dart Files)

### Domain Layer (Pure Dart)
- 3 entities: `ArticleEntity`, `CategoryEntity`, `UserEntity`
- 4 repository contracts: `ArticleRepository`, `CategoryRepository`, `StorageRepository`, `AuthRepository`
- 9 active use cases: `GetArticles`, `GetArticleById`, `CreateArticle`, `UpdateArticle`, `DeleteArticle`, `UploadArticleImage`, `GetCategories`, `AddCategory`, `SignIn`, `SignOut`, `GetCurrentUser` (SignUp use case exists but is unused)
- 3 param classes: `CreateArticleParams`, `UpdateArticleParams`, `SignInParams` (SignUpParams exists but is unused)

### Data Layer
- 3 models: `ArticleModel`, `CategoryModel`, `UserModel`
- 6 data source files (3 contracts + 3 implementations)
- 4 repository implementations

### Presentation Layer
- 3 BLoCs/Cubits: `AuthBloc`, `ArticleBloc`, `CategoryCubit`
- 6 screens: `SplashScreen`, `SignInScreen`, `ArticlesListScreen`, `PublicArticlesScreen`, `ArticleDetailScreen`, `ArticleFormScreen`
- 3 widgets: `ArticleCard`, `CategorySearchField`, `MarkdownEditor`

### Core / Config
- `DataState<T>`, `UseCase<T, Params>`, `NoParams`, `Failure` hierarchy
- `AppRoutes`, `AppTheme`, `AppConstants`
- `service_locator.dart` (GetIt DI)
- Firebase options, localization, settings

---

## 8. Recent Architectural Changes (February 20, 2026)

Several significant changes were made to improve the application's architecture and user experience:

### Author Information Removal
**Rationale:** Simplified article data model by removing author attribution.

**Changes:**
- Removed `authorId` and `authorName` fields from `ArticleEntity`
- Updated `ArticleModel` to exclude author fields from serialization/deserialization
- Removed `authorId` and `authorName` from `CreateArticleParams`
- Updated all UI components (`ArticleCard`, `ArticleDetailScreen`) to not display author information
- Modified `ArticleBloc` to no longer pass author data when creating articles
- Updated Firebase data source to exclude author fields from document creation

**Impact:** Articles now only store title, content, category, thumbnail, and timestamps. Database schema simplified.

### Public Article Viewing
**Rationale:** Allow non-authenticated users to browse content without requiring login.

**Implementation:**
- Created `PublicArticlesScreen` — read-only view of all articles for unauthenticated users
- Modified `app.dart` to show `PublicArticlesScreen` when user state is `AuthUnauthenticated`
- Public view includes:
  - Full article list with categories and thumbnails
  - Article detail navigation
  - Pull-to-refresh functionality
  - "Sign In" button in app bar for authentication
- Edit/Delete buttons are conditionally hidden in `ArticleCard` when callbacks are not provided

**Impact:** Improved user acquisition — visitors can explore content before signing in.

### Registration Flow Removal
**Rationale:** Restrict user creation to existing accounts only.

**Changes:**
- Removed "Register" link from `SignInScreen`
- Deleted `signUp` route from `AppRoutes`
- Removed `SignUpScreen` import from routing configuration
- `SignUpScreen.dart` file remains in codebase but is inaccessible

**Impact:** New users cannot self-register. Sign-in restricted to pre-existing accounts.

### Post-Login Navigation Fix
**Problem:** After successful authentication, app remained on sign-in screen despite server returning 200 status.

**Root Cause:** `AuthBloc` emitted `AuthAuthenticated` state, but `SignInScreen` only updated loading state without triggering navigation.

**Fix:** Added programmatic navigation in `_handleAuthStateChange()`:
```dart
Navigator.of(context).pushNamedAndRemoveUntil(
  AppRoutes.home,
  (route) => false,
);
```

**Impact:** Users now automatically navigate to home screen upon successful login. Navigation stack is cleared to prevent back-button return to login.

### UI Improvements
**Changes:**
- Set `debugShowCheckedModeBanner: false` in `MaterialApp` to hide debug banner
- Improved `ArticleCard` footer layout:
  - Added `Spacer()` to right-align edit/delete buttons
  - Conditional rendering of action buttons based on authentication state
  - Better visual separation between date and action buttons

---

## 9. Challenges & Decisions

### Firebase Version Compatibility
Early in the project, Firebase SDK version conflicts arose between `firebase_core`, `firebase_auth`, `cloud_firestore`, and the Android Gradle build system. These were resolved by updating `settings.gradle`, `gradle.properties`, and `app/build.gradle` to compatible versions.

### Web Platform Handling
Firebase Firestore operations behave differently on web (CORS, cold start issues). The auth data source implementation includes `kIsWeb` checks to gracefully handle these differences — falling back to Firebase Auth data instead of Firestore user documents when running on web.

### DataState vs Exception Pattern
A deliberate architectural decision was made to use `DataState<T>` (a sealed success/error wrapper) instead of raw exceptions. This pushed error handling to the repository boundary, keeping BLoCs clean — they simply check `result.isSuccess` / `result.isError` without try/catch. The `Failure` class hierarchy was defined but `DataState` proved sufficient for the current scope.

### Category Search Widget Complexity
The `CategorySearchField` widget (overlay-based dropdown with search, filter, and inline add) was one of the most complex UI components. It uses `LayerLink`/`CompositedTransformFollower` for proper overlay positioning. Extracting it to its own file was critical for CG5.1 compliance and reusability.

### Markdown Editor
A fully custom Markdown editor was built rather than using a third-party package, to provide a tailored toolbar with formatting shortcuts (bold, italic, strikethrough, headings, lists, checkboxes, quotes, code, links, dividers) and a live preview toggle powered by `flutter_markdown`.

---

## 10. Testing

The project includes:
- `test/unit_test.dart` — Basic placeholder unit test
- `test/widget_test.dart` — Basic widget rendering test

**Note:** A comprehensive test suite covering use cases, repositories, and BLoCs was not implemented within the project scope. The architecture, however, is fully testable — each layer is injectable and mockable through the abstract contracts.

---

## 11. Final Verification

```
$ flutter analyze
Analyzing prueba...
No issues found! (ran in 0.8s)
```

The entire codebase passes `flutter analyze` with **zero errors, zero warnings, and zero info issues**.

---

## 12. Summary

This project demonstrates a production-quality Flutter application built on Clean Architecture principles with strict adherence to both architectural rules and coding guidelines. The layered separation (data → domain → presentation), dependency injection via GetIt, state management via BLoC, and Firebase integration create a maintainable, testable, and scalable codebase. Every coding guideline (CG1–CG6) was systematically audited and enforced across all 55+ Dart files.

Recent updates (February 2026) simplified the data model by removing author attribution, improved user experience with a public article browsing feature, streamlined authentication by removing self-registration, and fixed critical navigation issues post-login. The application now provides a clean separation between public and authenticated experiences while maintaining architectural integrity.
