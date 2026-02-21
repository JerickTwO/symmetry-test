# News App - Flutter with Clean Architecture

A news application developed in Flutter using Clean Architecture, Firebase Authentication and BLoC for state management.

## 🏗️ Architecture

The project follows **Clean Architecture** principles with the following layers:

```
lib/
│
├── core/                       # Shared across the entire app
│   ├── constants/              # Application constants
│   ├── errors/                 # Error handling (Failures)
│   └── usecase/                # Generic interface for use cases
│
├── data/                       # DATA Layer
│   ├── models/                 # Models that parse Firebase/JSON
│   ├── repositories/           # Repository implementations
│   └── sources/                # Firebase services
│
├── domain/                     # BUSINESS Layer (pure logic)
│   ├── entities/               # Domain entities
│   ├── repositories/           # Contracts/Interfaces
│   └── usecases/               # Use cases (specific actions)
│
├── presentation/               # UI Layer (UI + BLoC)
│   ├── auth/                   # Authentication
│   │   ├── pages/              # Login screen
│   │   └── bloc/               # BLoC for authentication
│   ├── home/                   # Main screen
│   └── splash/                 # Loading screen
│
├── service_locator.dart        # Dependency injection (GetIt)
└── main.dart                   # Entry point
```

## 🚀 Implemented Features

### ✅ Authentication System
- **Login** with email and password
- **Logout** 
- **Automatic verification** of authentication status
- **Firebase Auth error handling**
- **Form validation**

### ✅ Clean Architecture
- **Separation of responsibilities** in layers
- **Dependency inversion** with abstract repositories
- **Specific use cases** for each action
- **Error handling** with Either (Success/Failure)

### ✅ State Management
- **BLoC pattern** for state management
- **Reactive state** throughout the application
- **Well-defined events and states**

### ✅ Dependency Injection
- **GetIt** for service locator
- **Automatically configured dependencies**
- **Easy testing** and maintenance

## 📱 Screens

### 🔐 Authentication
- **SignIn**: Login with email/password
- **Splash**: Initial loading screen

### 🏠 Main
- **Home**: Main screen (ready to display news)

## 🛠️ Technologies Used

- **Flutter** - UI Framework
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **BLoC** - State management
- **GetIt** - Dependency injection
- **Dartz** - Functional programming (Either)
- **Equatable** - Object comparison

## 🚀 How to Run

1. **Install dependencies:**
```bash
flutter pub get
```

2. **Configure Firebase:**
   - The project is already configured with Firebase
   - Configuration files are included

3. **Run the application:**
```bash
flutter run
```

## 📂 Key File Structure

### Core Layer
- `failures.dart` - Application error types
- `app_constants.dart` - Constants and strings
- `usecase.dart` - Generic interface for use cases

### Domain Layer
- `user.dart` - User entity
- `auth_repository.dart` - Repository contract
- `login_user.dart` - Login use case

### Data Layer
- `user_model.dart` - User data model
- `auth_firebase_service.dart` - Firebase Auth service
- `auth_repository_impl.dart` - Repository implementation

### Presentation Layer
- `auth_bloc.dart` - Authentication BLoC
- `signin_page.dart` - Login screen

## 🔧 Upcoming Features

- [ ] News/articles system
- [ ] News categories
- [ ] Favorites
- [ ] Article search
- [ ] Offline mode
- [ ] Push notifications

## 📝 Development Notes

- The project is prepared to scale easily
- The architecture allows adding new features without affecting existing code
- Each layer has well-defined responsibilities
- Error handling is consistent throughout the application

---
