/// Entidad pura de Dart que representa un artículo en el negocio.
/// No tiene dependencia de ningún paquete externo ni de Flutter.
class ArticleEntity {
  final String? id;
  final String title;
  final String content;
  final String? thumbnailURL;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ArticleEntity({
    this.id,
    required this.title,
    required this.content,
    this.thumbnailURL,
    this.category,
    this.createdAt,
    this.updatedAt,
  });
}
