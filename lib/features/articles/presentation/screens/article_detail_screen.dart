import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;
import '../../domain/entities/article_entity.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_state.dart';

/// Wrapper que carga el artículo por ID desde el BLoC.
class ArticleDetailScreenWrapper extends StatelessWidget {
  final String articleId;

  const ArticleDetailScreenWrapper({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ArticleDetailLoaded) {
          return ArticleDetailScreen(article: state.article);
        } else if (state is ArticleError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

/// Pantalla de detalle de un artículo.
class ArticleDetailScreen extends StatelessWidget {
  final ArticleEntity article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Artículo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            const SizedBox(height: 24),
            _buildCategoryBadge(),
            const SizedBox(height: 16),
            _buildTitle(context),
            const SizedBox(height: 12),
            _buildAuthorDateRow(),
            const Divider(height: 32),
            _buildMarkdownContent(),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is auth.AuthAuthenticated) {
      final result = await Navigator.of(context).pushNamed(
        '/edit-article/${article.id}',
      );
      if (result == true && context.mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to edit articles'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildThumbnail() {
    final hasValidThumbnail =
        article.thumbnailURL != null && article.thumbnailURL!.isNotEmpty;

    if (!hasValidThumbnail) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.article, size: 80, color: Colors.blue),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        article.thumbnailURL!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 60),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    if (article.category == null || article.category!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        article.category!,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      article.title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildAuthorDateRow() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatDate(article.createdAt),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent() {
    return MarkdownBody(
      data: article.content,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return '${date.day}/${date.month}/${date.year}';
  }
}
