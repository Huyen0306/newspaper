import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_api_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  final AuthApiService _authApiService = AuthApiService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _authService.userNotifier.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    _authService.userNotifier.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onUserChanged() {
    if (!mounted) return;
    setState(() {
      _user = _authService.userNotifier.value;
    });
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _refreshToken() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final refreshToken = await _authService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Không có refresh token');
      }

      final result = await _authApiService.refreshToken(
        refreshToken: refreshToken,
      );

      final success = await _authService.updateToken(
        result['token'] as String,
        refreshToken: result['refreshToken'] as String?,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã làm mới token thành công!'),
            backgroundColor: Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Làm mới thất bại: Phiên đăng nhập có thể đã hết hạn',
            ),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _logout();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Profile'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.profile_circle,
                    size: 64,
                    color: Color(0xFF3C3C43),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa đăng nhập',
                    style: TextStyle(fontSize: 17, color: Color(0xFF3C3C43)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUser,
              color: const Color(0xFF007AFF),
              strokeWidth: 2.5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar and name
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF007AFF,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child:
                                _user!.image.isNotEmpty &&
                                    _user!.image !=
                                        'https://robohash.org/placeholder.png'
                                ? ClipOval(
                                    child: Image.network(
                                      _user!.image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Iconsax.profile_circle,
                                              color: Colors.white,
                                              size: 50,
                                            );
                                          },
                                    ),
                                  )
                                : const Icon(
                                    Iconsax.profile_circle,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user!.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _user!.email,
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF3C3C43).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFFF3B30,
                              ).withOpacity(0.1),
                              foregroundColor: const Color(0xFFFF3B30),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Đăng xuất',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isRefreshing ? null : _refreshToken,
                            icon: _isRefreshing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Iconsax.refresh, size: 18),
                            label: const Text(
                              'Refresh Token',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1C1C1E),
                              side: BorderSide(
                                color: const Color(0xFF3C3C43).withOpacity(0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // User info cards
                    _buildInfoCard('HỌ VÀ TÊN', _user!.fullName, Iconsax.user),
                    const SizedBox(height: 12),
                    _buildInfoCard('EMAIL', _user!.email, Iconsax.sms),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'GIỚI TÍNH',
                      _user!.gender,
                      Iconsax.profile_2user,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'TÊN ĐĂNG NHẬP',
                      _user!.username,
                      Iconsax.tag,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF007AFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
