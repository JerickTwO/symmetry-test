/// Parámetros para actualizar un artículo.
class UpdateArticleParams {
  final String id;
  final String title;
  final String content;
  final String? thumbnailURL;
  final String? category;

  const UpdateArticleParams({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnailURL,
    this.category,
  });
}
