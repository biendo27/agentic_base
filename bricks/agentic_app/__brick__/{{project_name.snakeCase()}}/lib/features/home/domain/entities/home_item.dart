class HomeItem {
  const HomeItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
}
