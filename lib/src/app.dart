import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/routes/app_routes.dart';
import '../config/theme/app_theme.dart';
import '../features/articles/presentation/bloc/article_bloc.dart';
import '../features/articles/presentation/bloc/article_event.dart';
import '../features/articles/presentation/screens/articles_list_screen.dart';
import '../features/articles/presentation/screens/public_articles_screen.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/signin_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../service_locator.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<AuthBloc>()..add(const CheckAuthStatus()),
      child: ListenableBuilder(
        listenable: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            restorationScopeId: 'app',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.themeMode,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const SplashScreen();
                } else if (state is AuthAuthenticated) {
                  return BlocProvider(
                    create: (_) => serviceLocator<ArticleBloc>()
                      ..add(const LoadArticles()),
                    child: const ArticlesListScreen(),
                  );
                } else {
                  // Mostrar vista pública de artículos para usuarios no autenticados
                  return BlocProvider(
                    create: (_) => serviceLocator<ArticleBloc>()
                      ..add(const LoadArticles()),
                    child: const PublicArticlesScreen(),
                  );
                }
              },
            ),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
