# News App - Flutter con Clean Architecture

Una aplicación de noticias desarrollada en Flutter usando Clean Architecture, Firebase Authentication y BLoC para el manejo de estado.

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture** con las siguientes capas:

```
lib/
│
├── core/                       # Compartido en toda la app
│   ├── constants/              # Constantes de la aplicación
│   ├── errors/                 # Manejo de errores (Failures)
│   └── usecase/                # Interfaz genérica para casos de uso
│
├── data/                       # Capa de DATOS
│   ├── models/                 # Modelos que parsean Firebase/JSON
│   ├── repositories/           # Implementación de repositorios
│   └── sources/                # Servicios de Firebase
│
├── domain/                     # Capa de NEGOCIO (lógica pura)
│   ├── entities/               # Entidades de dominio
│   ├── repositories/           # Contratos/Interfaces
│   └── usecases/               # Casos de uso (acciones específicas)
│
├── presentation/               # Capa VISUAL (UI + BLoC)
│   ├── auth/                   # Autenticación
│   │   ├── pages/              # Pantallas de login/registro
│   │   └── bloc/               # BLoC para autenticación
│   ├── home/                   # Pantalla principal
│   └── splash/                 # Pantalla de carga
│
├── service_locator.dart        # Inyección de dependencias (GetIt)
└── main.dart                   # Punto de entrada
```

## 🚀 Características Implementadas

### ✅ Sistema de Autenticación
- **Login** con email y contraseña
- **Registro** de nuevos usuarios 
- **Logout** 
- **Verificación automática** del estado de autenticación
- **Manejo de errores** de Firebase Auth
- **Validación de formularios**

### ✅ Arquitectura Clean
- **Separación de responsabilidades** en capas
- **Inversión de dependencias** con repositorios abstractos
- **Casos de uso** específicos para cada acción
- **Manejo de errores** con Either (Success/Failure)

### ✅ Manejo de Estado
- **BLoC pattern** para gestión de estado
- **Estado reactivo** en toda la aplicación
- **Eventos y estados** bien definidos

### ✅ Inyección de Dependencias
- **GetIt** para service locator
- **Dependencias configuradas** automáticamente
- **Fácil testing** y mantenimiento

## 📱 Pantallas

### 🔐 Autenticación
- **SignIn**: Inicio de sesión con email/contraseña
- **SignUp**: Registro de nuevos usuarios
- **Splash**: Pantalla de carga inicial

### 🏠 Principal
- **Home**: Pantalla principal (preparada para mostrar noticias)

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de UI
- **Firebase Auth** - Autenticación
- **Cloud Firestore** - Base de datos
- **BLoC** - Manejo de estado
- **GetIt** - Inyección de dependencias
- **Dartz** - Programación funcional (Either)
- **Equatable** - Comparación de objetos

## 🚀 Cómo ejecutar

1. **Instalar dependencias:**
```bash
flutter pub get
```

2. **Configurar Firebase:**
   - El proyecto ya está configurado con Firebase
   - Los archivos de configuración están incluidos

3. **Ejecutar la aplicación:**
```bash
flutter run
```

## 📂 Estructura de Archivos Clave

### Core Layer
- `failures.dart` - Tipos de errores de la aplicación
- `app_constants.dart` - Constantes y strings
- `usecase.dart` - Interface genérica para casos de uso

### Domain Layer
- `user.dart` - Entidad de usuario
- `auth_repository.dart` - Contrato del repositorio
- `login_user.dart` - Caso de uso de login
- `register_user.dart` - Caso de uso de registro

### Data Layer
- `user_model.dart` - Modelo de datos de usuario
- `auth_firebase_service.dart` - Servicio de Firebase Auth
- `auth_repository_impl.dart` - Implementación del repositorio

### Presentation Layer
- `auth_bloc.dart` - BLoC de autenticación
- `signin_page.dart` - Pantalla de login
- `signup_page.dart` - Pantalla de registro

## 🔧 Próximas Características

- [ ] Sistema de noticias/artículos
- [ ] Categorías de noticias
- [ ] Favoritos
- [ ] Búsqueda de artículos
- [ ] Modo offline
- [ ] Push notifications

## 📝 Notas de Desarrollo

- El proyecto está preparado para escalar fácilmente
- La arquitectura permite agregar nuevas características sin afectar el código existente
- Cada capa tiene responsabilidades bien definidas
- El manejo de errores es consistente en toda la aplicación

---

**Desarrollado con ❤️ usando Clean Architecture**