import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import '../models/post_model.dart';
import '../services/saved_posts_service.dart';
import '../core/utils/page_transitions.dart';
import 'post_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen>
    with AutomaticKeepAliveClientMixin {
  final SavedPostsService _savedPostsService = SavedPostsService();
  List<PostModel> _savedPosts = [];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Listen to changes in saved posts
    _savedPostsService.savedPostsNotifier.addListener(_onSavedPostsChanged);
    
    // Load initial data - check notifier first, then load if needed
    final currentPosts = _savedPostsService.savedPostsNotifier.value;
    if (currentPosts.isNotEmpty) {
      setState(() {
        _savedPosts = currentPosts;
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    } else {
      _loadSavedPosts();
      _hasLoadedOnce = true;
    }
  }

  @override
  void dispose() {
    _savedPostsService.savedPostsNotifier.removeListener(_onSavedPostsChanged);
    super.dispose();
  }

  void _onSavedPostsChanged() {
    if (!mounted) return;
    setState(() {
      _savedPosts = _savedPostsService.savedPostsNotifier.value;
      _isLoading = false;
    });
  }

  Future<void> _loadSavedPosts({bool forceRefresh = false}) async {
    // Chỉ load nếu chưa có dữ liệu hoặc force refresh
    if (!forceRefresh && _savedPosts.isNotEmpty && _hasLoadedOnce) {
      // Update từ notifier nếu có
      final currentPosts = _savedPostsService.savedPostsNotifier.value;
      if (currentPosts.length != _savedPosts.length) {
        setState(() {
          _savedPosts = currentPosts;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final posts = await _savedPostsService.getSavedPosts();
    if (!mounted) return;
    setState(() {
      _savedPosts = posts;
      _isLoading = false;
    });
  }

  Future<void> _removePost(int postId) async {
    await _savedPostsService.removePost(postId);
    _loadSavedPosts();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Đã lưu',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: -0.3,
            color: Color(0xFF000000),
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.black.withOpacity(0.08),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 12))
          : _savedPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.bookmark,
                        size: 64,
                        color: const Color(0xFF3C3C43).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bài viết nào được lưu',
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
                  onRefresh: () => _loadSavedPosts(forceRefresh: true),
                  color: const Color(0xFF007AFF),
                  strokeWidth: 2.5,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _savedPosts.length,
                    itemBuilder: (context, index) {
                      return _SavedPostCard(
                        post: _savedPosts[index],
                        onRemove: () => _removePost(_savedPosts[index].id),
                      );
                    },
                  ),
                ),
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onRemove;

  const _SavedPostCard({
    required this.post,
    required this.onRemove,
  });

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
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
                PostDetailScreen(
                  post: post,
                  heroTagPrefix: 'saved',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              Hero(
                tag: 'saved_post_image_${post.id}',
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
                    // Title with remove button
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
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.trash,
                          size: 20,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Body preview
                Text(
                  _truncateText(post.body, 160),
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
                              color: const Color(0xFF3C3C43).withOpacity(0.6),
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
