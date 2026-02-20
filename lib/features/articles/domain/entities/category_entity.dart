/// Entidad pura de Dart que representa una categoría.
/// No tiene dependencia de ningún paquete externo ni de Flutter.
class CategoryEntity {
  final String? id;
  final String name;

  const CategoryEntity({
    this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
