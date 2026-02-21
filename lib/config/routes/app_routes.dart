import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/articles/presentation/bloc/article_bloc.dart';
import '../../features/articles/presentation/bloc/article_event.dart';
import '../../features/articles/presentation/bloc/category_cubit.dart';
import '../../features/articles/presentation/screens/article_detail_screen.dart';
import '../../features/articles/presentation/screens/article_form_screen.dart';
import '../../features/articles/presentation/screens/articles_list_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart' as auth;
import '../../features/auth/presentation/screens/signin_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../service_locator.dart';

class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/signin';
  static const String home = '/home';
  static const String createArticle = '/create-article';
  static const String editArticle = '/edit-article';
  static const String articleDetail = '/article-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final uri = Uri.parse(routeSettings.name ?? '/');

    return MaterialPageRoute<void>(
      settings: routeSettings,
      builder: (_) => _buildScreen(uri, routeSettings),
    );
  }

  static Widget _buildScreen(Uri uri, RouteSettings routeSettings) {
    // Rutas con parámetros dinámicos
    if (uri.pathSegments.length == 2) {
      final dynamicScreen = _buildDynamicRoute(uri);
      if (dynamicScreen != null) return dynamicScreen;
    }

    // Rutas estáticas
    return _buildStaticRoute(routeSettings.name);
  }

  static Widget? _buildDynamicRoute(Uri uri) {
    final segment = uri.pathSegments[0];
    final id = uri.pathSegments[1];

    switch (segment) {
      case 'article-detail':
        return _buildArticleDetailRoute(id);
      case 'edit-article':
        return _buildEditArticleRoute(id);
      default:
        return null;
    }
  }

  static Widget _buildStaticRoute(String? routeName) {
    switch (routeName) {
      case signIn:
        return const SignInScreen();
      case home:
        return _buildHomeRoute();
      case createArticle:
        return _buildCreateArticleRoute();
      case splash:
      default:
        return const SplashScreen();
    }
  }

  static Widget _buildArticleDetailRoute(String articleId) {
    return BlocProvider(
      create: (_) => serviceLocator<ArticleBloc>()
        ..add(LoadArticleDetail(articleId: articleId)),
      child: ArticleDetailScreenWrapper(articleId: articleId),
    );
  }

  static Widget _buildEditArticleRoute(String articleId) {
    return BlocBuilder<AuthBloc, auth.AuthState>(
      builder: (context, authState) {
        if (authState is auth.AuthAuthenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => serviceLocator<ArticleBloc>()
                  ..add(LoadArticleDetail(articleId: articleId)),
              ),
              BlocProvider(
                create: (_) => serviceLocator<CategoryCubit>()..loadCategories(),
              ),
            ],
            child: ArticleFormScreenWrapper(articleId: articleId),
          );
        } else {
          return _buildAuthRequiredScreen(context, 'edit articles');
        }
      },
    );
  }

  static Widget _buildHomeRoute() {
    return BlocProvider(
      create: (_) => serviceLocator<ArticleBloc>()..add(const LoadArticles()),
      child: const ArticlesListScreen(),
    );
  }

  static Widget _buildCreateArticleRoute() {
    return BlocBuilder<AuthBloc, auth.AuthState>(
      builder: (context, authState) {
        if (authState is auth.AuthAuthenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => serviceLocator<ArticleBloc>(),
              ),
              BlocProvider(
                create: (_) => serviceLocator<CategoryCubit>()..loadCategories(),
              ),
            ],
            child: const ArticleFormScreen(),
          );
        } else {
          return _buildAuthRequiredScreen(context, 'create articles');
        }
      },
    );
  }

  static Widget _buildAuthRequiredScreen(BuildContext context, String action) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Required'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You must be logged in to $action',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  signIn,
                  (route) => false,
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
