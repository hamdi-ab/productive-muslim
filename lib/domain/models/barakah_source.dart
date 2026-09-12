class BarakahSource {
  const BarakahSource({
    required this.id,
    required this.name,
    this.arabicName,
    required this.slug,
    required this.description,
    required this.order,
  });

  final String id;
  final String name;
  final String? arabicName;
  final String slug;
  final String description;
  final int order;
}