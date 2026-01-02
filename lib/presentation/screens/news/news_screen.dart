import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/post_service.dart';
import '../../../data/services/saved_posts_service.dart';
import '../../../core/utils/page_transitions.dart';
import '../../widgets/custom_app_bar.dart';
import 'post_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();

  // Static method để refresh saved post ids
  static void refreshSavedPostIds(BuildContext? context) {
    if (context != null) {
      final state = context.findAncestorStateOfType<_NewsScreenState>();
      state?.refreshSavedPostIds();
    }
  }
}

class _NewsScreenState extends State<NewsScreen>
    with AutomaticKeepAliveClientMixin {
  final PostService _postService = PostService();
  final SavedPostsService _savedPostsService = SavedPostsService();
  List<PostModel> _posts = [];
  Set<int> _savedPostIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoadedOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadSavedPostIds();
    _hasLoadedOnce = true;

    // Listen to changes in saved posts để tự động update saved post IDs
    _savedPostsService.savedPostsNotifier.addListener(_onSavedPostsChanged);
  }

  @override
  void dispose() {
    _savedPostsService.savedPostsNotifier.removeListener(_onSavedPostsChanged);
    super.dispose();
  }

  void _onSavedPostsChanged() {
    if (!mounted) return;
    final savedPosts = _savedPostsService.savedPostsNotifier.value;
    setState(() {
      _savedPostIds = savedPosts.map((p) => p.id).toSet();
    });
  }

  // Method để refresh saved post ids khi quay lại từ saved screen
  void refreshSavedPostIds() {
    if (_hasLoadedOnce) {
      _loadSavedPostIds();
    }
  }

  Future<void> _loadSavedPostIds() async {
    final savedPosts = await _savedPostsService.getSavedPosts();
    if (!mounted) return;
    setState(() {
      _savedPostIds = savedPosts.map((p) => p.id).toSet();
    });
  }

  Future<void> _loadPosts({bool forceRefresh = false}) async {
    // Chỉ load nếu chưa có dữ liệu hoặc force refresh
    if (!forceRefresh && _posts.isNotEmpty) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _postService.getPosts(limit: 30);
      if (!mounted) return;
      setState(() {
        _posts = response.posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS systemGray6
      appBar: const CustomAppBar(title: 'Báo mới'),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 12))
              : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.danger,
                            size: 40,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Đã xảy ra lỗi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color(0xFF3C3C43).withOpacity(0.6),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.document_text,
                        size: 64,
                        color: const Color(0xFF3C3C43).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có bài viết nào',
                        style: TextStyle(
                          fontSize: 17,
                          color: const Color(0xFF3C3C43).withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadPosts(forceRefresh: true),
                  color: const Color(0xFF007AFF),
                  strokeWidth: 2.5,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return _PostCard(
                        post: _posts[index],
                        isSaved: _savedPostIds.contains(_posts[index].id),
                        onSaveChanged: () => _loadSavedPostIds(),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  final bool isSaved;
  final VoidCallback onSaveChanged;

  const _PostCard({
    required this.post,
    required this.isSaved,
    required this.onSaveChanged,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool _isSaved;
  final SavedPostsService _savedPostsService = SavedPostsService();

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  void didUpdateWidget(_PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaved) {
      await _savedPostsService.removePost(widget.post.id);
    } else {
      await _savedPostsService.savePost(widget.post);
    }
    if (!mounted) return;
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSaveChanged();
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.smoothRoute(
                PostDetailScreen(post: post, heroTagPrefix: 'news'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Hero(
                tag: 'news_post_image_${post.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: const Color(0xFFF2F2F7),
                          child: const Center(
                            child: CupertinoActivityIndicator(radius: 12),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: const Color(0xFFF2F2F7),
                          child: const Icon(
                            Iconsax.image,
                            size: 48,
                            color: Color(0xFF3C3C43),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with save button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: -0.3,
                              color: Color(0xFF1C1C1E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _toggleSave,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isSaved
                                  ? const Color(0xFF007AFF).withOpacity(0.1)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Iconsax.bookmark,
                              size: 20,
                              color: _isSaved
                                  ? const Color(0xFF007AFF)
                                  : const Color(0xFF3C3C43).withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Body preview
                    Text(
                      _truncateText(widget.post.body, 160),
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF3C3C43).withOpacity(0.7),
                        height: 1.5,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    // Tags
                    if (post.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF007AFF).withOpacity(0.1),
                                  const Color(0xFF5856D6).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF007AFF).withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    if (post.tags.isNotEmpty) const SizedBox(height: 14),
                    // Footer with reactions and user
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFF3C3C43).withOpacity(0.08),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Reactions
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Iconsax.heart,
                                  size: 16,
                                  color: Color(0xFFFF3B30),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${post.reactions}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF3B30),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // User ID
                          Row(
                            children: [
                              Icon(
                                Iconsax.profile_circle,
                                size: 16,
                                color: const Color(0xFF3C3C43).withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'User ${post.userId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(
                                    0xFF3C3C43,
                                  ).withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Author and Date
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: -0.08,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Iconsax.clock,
                              size: 14,
                              color: const Color(0xFF3C3C43).withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.date,
                              style: TextStyle(
                                color: const Color(0xFF3C3C43).withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
