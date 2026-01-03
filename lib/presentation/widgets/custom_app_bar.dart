import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/services/points_service.dart';
import '../../data/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final pointsService = PointsService();
    final authService = AuthService();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Color(0xFF000000)),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar and Name
          ValueListenableBuilder(
            valueListenable: authService.userNotifier,
            builder: (context, user, child) {
              final userName = user?.firstName ?? 'User';
              final userImage = user?.image ?? '';
              final hasValidImage =
                  userImage.isNotEmpty &&
                  userImage != 'https://robohash.org/placeholder.png';

              return Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: hasValidImage
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: hasValidImage
                        ? ClipOval(
                            child: Image.network(
                              userImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF007AFF),
                                        Color(0xFF5856D6),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Iconsax.profile_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Iconsax.profile_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 10),
                  // Name
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
          // Points Card
          ValueListenableBuilder<int>(
            valueListenable: pointsService.pointsNotifier,
            builder: (context, points, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA500).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Iconsax.star1,
                        size: 14,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      centerTitle: false,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: Colors.black.withOpacity(0.08),
        ),
      ),
    );
  }
}
