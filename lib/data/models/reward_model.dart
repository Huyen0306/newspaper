class RewardModel {
  final int id;
  final String title;
  final String description;
  final int pointsRequired;
  final String icon;
  final String? imageUrl;

  RewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.icon,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'icon': icon,
      'imageUrl': imageUrl,
    };
  }

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsRequired: json['pointsRequired'] as int,
      icon: json['icon'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

