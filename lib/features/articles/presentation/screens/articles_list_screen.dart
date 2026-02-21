import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../domain/entities/article_entity.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../widgets/article_card.dart';

/// Pantalla principal que muestra la lista de artículos.
class ArticlesListScreen extends StatelessWidget {
  const ArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<ArticleBloc, ArticleState>(
        listener: (context, state) {
          if (state is ArticleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is ArticleDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Artículo eliminado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<ArticleBloc>().add(const LoadArticles());
          }
          if (state is ArticleUpdated) {
            context.read<ArticleBloc>().add(const LoadArticles());
          }
          if (state is ArticleCreated) {
            context.read<ArticleBloc>().add(const LoadArticles());
          }
        },
        builder: (context, state) {
          if (state is ArticleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ArticlesLoaded) {
            if (state.articles.isEmpty) {
              return _buildEmptyState();
            }
            return _buildArticlesList(context, state.articles);
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, auth.AuthState>(
        builder: (context, authState) {
          return FloatingActionButton(
            onPressed: () => _handleCreateArticle(context, authState),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '¡No hay artículos aún!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Presiona el botón + para crear tu primer artículo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ArticleBloc>().add(const LoadArticles());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            article: article,
            onTap: () async {
              final result = await Navigator.of(context).pushNamed(
                '/article-detail/${article.id}',
              );
              if (result == true && context.mounted) {
                context.read<ArticleBloc>().add(const LoadArticles());
              }
            },
            onDelete: () => _confirmDelete(context, article),
            onEdit: () => _handleEditArticle(context, article),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, ArticleEntity article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar artículo'),
        content: Text('¿Estás seguro de eliminar "${article.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ArticleBloc>().add(
                    DeleteArticleRequested(articleId: article.id!),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateArticle(BuildContext context, auth.AuthState authState) async {
    if (authState is auth.AuthAuthenticated) {
      final result = await Navigator.of(context).pushNamed('/create-article');
      if (result == true && context.mounted) {
        context.read<ArticleBloc>().add(const LoadArticles());
      }
    } else {
      _showAuthRequiredMessage(context);
    }
  }

  Future<void> _handleEditArticle(BuildContext context, ArticleEntity article) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is auth.AuthAuthenticated) {
      final result = await Navigator.of(context).pushNamed(
        '/edit-article/${article.id}',
      );
      if (result == true && context.mounted) {
        context.read<ArticleBloc>().add(const LoadArticles());
      }
    } else {
      _showAuthRequiredMessage(context);
    }
  }

  void _showAuthRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You must be logged in to edit or create articles'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
