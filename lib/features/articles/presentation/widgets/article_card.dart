import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/entities/article_entity.dart';

/// Widget reutilizable que muestra una tarjeta de artículo.
class ArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnailSection(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    final hasValidThumbnail =
        article.thumbnailURL != null && article.thumbnailURL!.isNotEmpty;

    if (!hasValidThumbnail) return _buildPlaceholderImage();

    return Image.network(
      article.thumbnailURL!,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.infinity,
          height: 180,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryBadge(),
          _buildTitle(),
          const SizedBox(height: 8),
          _buildMarkdownPreview(),
          const SizedBox(height: 12),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge() {
    if (article.category == null || article.category!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        article.category!,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      article.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMarkdownPreview() {
    return SizedBox(
      height: 42,
      child: ClipRect(
        child: OverflowBox(
          maxHeight: double.infinity,
          alignment: Alignment.topLeft,
          child: MarkdownBody(
            data: article.content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(fontSize: 14, color: Colors.grey[600]),
              h1: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              h2: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              h3: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            shrinkWrap: true,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        if (article.createdAt != null) ...[
          const Icon(Icons.access_time, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            _formatDate(article.createdAt!),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
        if (onEdit != null || onDelete != null) const Spacer(),
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.blue,
          ),
        if (onDelete != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 120,
      color: Colors.blue.withOpacity(0.05),
      child: const Icon(
        Icons.article_outlined,
        size: 50,
        color: Colors.blue,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
