import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import '../../../data/models/post_model.dart';
import '../../../data/services/saved_posts_service.dart';
import '../../widgets/floating_reward_badge.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  final String? heroTagPrefix; // 'news' or 'saved'

  const PostDetailScreen({super.key, required this.post, this.heroTagPrefix});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final SavedPostsService _savedPostsService = SavedPostsService();
  late bool _isSaved;
  bool _isToggling = false;
  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _savedPostsService.savedPostsNotifier.addListener(_onSavedPostsChanged);
  }

  @override
  void dispose() {
    _savedPostsService.savedPostsNotifier.removeListener(_onSavedPostsChanged);
    super.dispose();
  }

  void _onSavedPostsChanged() {
    if (!mounted) return;
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final savedPosts = _savedPostsService.savedPostsNotifier.value;
    if (!mounted) return;
    setState(() {
      _isSaved = savedPosts.any((p) => p.id == widget.post.id);
    });
  }

  Future<void> _toggleSave() async {
    // Prevent multiple clicks
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    try {
      if (_isSaved) {
        final success = await _savedPostsService.removePost(widget.post.id);
        if (success && mounted) {
          // State will be updated by notifier listener
          setState(() {
            _isSaved = false;
            _isToggling = false;
          });
        } else if (mounted) {
          setState(() {
            _isToggling = false;
          });
        }
      } else {
        final success = await _savedPostsService.savePost(widget.post);
        if (success && mounted) {
          // State will be updated by notifier listener
          setState(() {
            _isSaved = true;
            _isToggling = false;
          });
        } else if (mounted) {
          setState(() {
            _isToggling = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF000000)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.bookmark,
              color: _isToggling
                  ? const Color(0xFF3C3C43).withOpacity(0.3)
                  : _isSaved
                  ? const Color(0xFF007AFF)
                  : const Color(0xFF3C3C43).withOpacity(0.6),
            ),
            onPressed: _isToggling ? null : _toggleSave,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      Hero(
                        tag: widget.heroTagPrefix != null
                            ? '${widget.heroTagPrefix}_post_image_${widget.post.id}'
                            : 'post_image_${widget.post.id}',
                        child: SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Image.network(
                            widget.post.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 250,
                                color: const Color(0xFFF2F2F7),
                                child: const Center(
                                  child: CupertinoActivityIndicator(radius: 12),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: const Color(0xFFF2F2F7),
                                child: const Icon(
                                  Iconsax.image,
                                  size: 64,
                                  color: Color(0xFF3C3C43),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // Title
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            letterSpacing: -0.3,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Author and Date
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFFF2F2F7),
                              child: Icon(
                                Iconsax.profile_circle,
                                size: 16,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C3C43),
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Iconsax.clock,
                              size: 14,
                              color: const Color(0xFF3C3C43).withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.date,
                              style: TextStyle(
                                color: const Color(0xFF3C3C43).withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Body content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Text(
                          widget.post.body,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF3C3C43).withOpacity(0.8),
                            height: 1.6,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tags section
                      if (widget.post.tags.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tags',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.post.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF007AFF,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFF5856D6,
                                          ).withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF007AFF),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Footer info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.white,
                        child: Row(
                          children: [
                            // Reactions
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Iconsax.heart,
                                    size: 18,
                                    color: Color(0xFFFF3B30),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.post.reactions}',
                                    style: const TextStyle(
                                      fontSize: 15,
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
                                  size: 18,
                                  color: const Color(
                                    0xFF3C3C43,
                                  ).withOpacity(0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'User ${widget.post.userId}',
                                  style: TextStyle(
                                    fontSize: 15,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Floating reward badge
          const FloatingRewardBadge(),
        ],
      ),
    );
  }
}
