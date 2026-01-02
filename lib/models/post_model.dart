class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int reactions;

  // Computed properties
  String get imageUrl => 'https://picsum.photos/seed/post$id/800/600';
  String get author => _getFakeAuthor(userId);
  String get date => _getFakeDate();

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
  });

  String _getFakeAuthor(int userId) {
    const authors = [
      'KTLA Los Angeles',
      'The Independent',
      'CNN News',
      'BBC World',
      'TechCrunch',
      'The Verge',
      'Reuters',
      'Associated Press',
    ];
    return authors[userId % authors.length];
  }

  String _getFakeDate() {
    final now = DateTime.now();
    final daysAgo = id % 30; // Random days ago (0-29)
    final date = now.subtract(Duration(days: daysAgo));
    return '${date.day}/${date.month}/${date.year}';
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Handle reactions - can be int or Map
    int reactionsCount = 0;
    if (json['reactions'] != null) {
      if (json['reactions'] is int) {
        reactionsCount = json['reactions'] as int;
      } else if (json['reactions'] is Map) {
        // If reactions is a map, sum all values
        final reactionsMap = json['reactions'] as Map<String, dynamic>;
        reactionsCount = reactionsMap.values.whereType<int>().fold(
          0,
          (sum, value) => sum + value,
        );
      }
    }

    return PostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      tags: json['tags'] != null
          ? List<String>.from((json['tags'] as List).map((e) => e.toString()))
          : [],
      reactions: reactionsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags,
      'reactions': reactions,
    };
  }
}

class PostsResponse {
  final List<PostModel> posts;
  final int total;
  final int skip;
  final int limit;

  PostsResponse({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      posts: json['posts'] != null
          ? (json['posts'] as List)
                .map((post) => PostModel.fromJson(post as Map<String, dynamic>))
                .toList()
          : [],
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
