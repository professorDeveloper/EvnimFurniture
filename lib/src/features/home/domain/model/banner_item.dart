class BannerItem {
  const BannerItem({
    required this.id,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String id;
  final String imageUrl;
  final String tag;
  final String title;
  final String subtitle;
  final String actionLabel;
}