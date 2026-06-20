/// Content sections for the public-facing website.
class WebsitePage {
  final String id;
  final String title;
  final String subtitle;
  final String heroImageUrl;
  final List<WebsiteSection> sections;

  WebsitePage({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.heroImageUrl = '',
    this.sections = const [],
  });
}

class WebsiteSection {
  final String heading;
  final String body;
  final String? imageUrl;
  final List<String> bulletPoints;

  WebsiteSection({
    required this.heading,
    required this.body,
    this.imageUrl,
    this.bulletPoints = const [],
  });
}

/// Gallery item for virtual tours and media.
class GalleryItem {
  final String id;
  final String imageUrl;
  final String caption;
  final String category; // 'facilities', 'events', 'classroom', 'safety'
  final DateTime uploadedAt;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.caption,
    this.category = 'classroom',
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();
}

/// Parent testimonial for the website.
class Testimonial {
  final String id;
  final String parentName;
  final String childName;
  final String quote;
  final double rating; // 1-5
  final DateTime date;

  Testimonial({
    required this.id,
    required this.parentName,
    required this.childName,
    required this.quote,
    this.rating = 5.0,
    DateTime? date,
  }) : date = date ?? DateTime.now();
}

/// Branch info for public display.
class BranchPublicInfo {
  final String branchId;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String description;
  final List<String> facilities;
  final String heroImageUrl;
  final List<String> classNames;

  BranchPublicInfo({
    required this.branchId,
    required this.name,
    this.address = '',
    this.phone = '',
    this.email = '',
    this.description = '',
    this.facilities = const [],
    this.heroImageUrl = '',
    this.classNames = const [],
  });
}
