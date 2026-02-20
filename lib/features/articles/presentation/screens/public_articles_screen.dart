import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/article_entity.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import '../widgets/article_card.dart';

/// Pantalla pública para usuarios no autenticados que solo pueden ver artículos.
class PublicArticlesScreen extends StatelessWidget {
  const PublicArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/signin');
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Iniciar sesión',
              style: TextStyle(color: Colors.white),
            ),
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
            'No hay artículos disponibles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vuelve más tarde para ver contenido nuevo',
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
            onTap: () {
              Navigator.of(context).pushNamed(
                '/article-detail/${article.id}',
              );
            },
            // No pasamos onEdit ni onDelete para que no se muestren los botones
          );
        },
      ),
    );
  }
}
