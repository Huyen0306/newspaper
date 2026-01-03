import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/services/points_service.dart';
import '../../widgets/custom_app_bar.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final PointsService _pointsService = PointsService();
  int _currentPoints = 0;
  bool _isLoading = true;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Sample rewards data - Sản phẩm công nghệ
  final List<RewardModel> _rewards = [
    RewardModel(
      id: 1,
      title: 'AirPods Pro',
      description: 'Tai nghe không dây chống ồn chủ động',
      pointsRequired: 500,
      icon: 'airpods',
      imageUrl: 'assets/images/airpods.png',
    ),
    RewardModel(
      id: 2,
      title: 'iPhone 15',
      description: 'Điện thoại thông minh flagship mới nhất',
      pointsRequired: 2000,
      icon: 'iphone15',
      imageUrl: 'assets/images/iphone15.png',
    ),
    RewardModel(
      id: 3,
      title: 'MacBook Air M2',
      description: 'Laptop siêu mỏng nhẹ hiệu năng cao',
      pointsRequired: 3000,
      icon: 'macbook',
      imageUrl: 'assets/images/macbook.png',
    ),
    RewardModel(
      id: 4,
      title: 'iPad Pro',
      description: 'Máy tính bảng chuyên nghiệp',
      pointsRequired: 2500,
      icon: 'ipad_pro',
      imageUrl: 'assets/images/iPad_Pro.png',
    ),
    RewardModel(
      id: 5,
      title: 'Apple Watch Series 9',
      description: 'Đồng hồ thông minh cao cấp',
      pointsRequired: 1500,
      icon: 'apple_watch',
      imageUrl: 'assets/images/Apple_Watch.png',
    ),
    RewardModel(
      id: 6,
      title: 'Magic Keyboard',
      description: 'Bàn phím không dây đa năng',
      pointsRequired: 800,
      icon: 'keyboard',
      imageUrl: 'assets/images/keyboard.png',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _loadData();
    _pointsService.pointsNotifier.addListener(_onPointsChanged);
  }

  @override
  void dispose() {
    _pointsService.pointsNotifier.removeListener(_onPointsChanged);
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onPointsChanged() {
    if (!mounted) return;
    setState(() {
      _currentPoints = _pointsService.pointsNotifier.value;
    });
  }

  Future<void> _loadData() async {
    final points = await _pointsService.getPoints();
    if (!mounted) return;
    setState(() {
      _currentPoints = points;
      _isLoading = false;
    });
  }

  Future<void> _redeemReward(RewardModel reward) async {
    if (_currentPoints < reward.pointsRequired) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bạn cần ${reward.pointsRequired - _currentPoints} điểm nữa để đổi phần thưởng này',
          ),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận đổi thưởng'),
        content: Text(
          'Bạn có chắc muốn đổi "${reward.title}" với ${reward.pointsRequired} điểm?',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFFF3B30),
                      width: 0.5,
                    ),
                    foregroundColor: const Color(0xFFFF3B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e293b),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _pointsService.addPoints(-reward.pointsRequired);
      if (success && mounted) {
        // Reset and play confetti
        _confettiController.stop();
        _confettiController.play();

        // Play sound
        _audioPlayer.play(AssetSource('sounds/success.mp3'));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đổi thành công: ${reward.title}'),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: const CustomAppBar(title: 'Đổi thưởng'),
          body: _isLoading
              ? const Center(child: CupertinoActivityIndicator(radius: 12))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF007AFF),
                  strokeWidth: 2.5,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      // Rewards Section
                      ..._rewards.map(
                        (reward) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RewardCard(
                            reward: reward,
                            currentPoints: _currentPoints,
                            onRedeem: () => _redeemReward(reward),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        // Confetti Widget
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.cyan,
              Colors.red,
              Colors.indigo,
              Colors.amber,
              Colors.lightBlue,
              Colors.teal,
            ],
            minimumSize: const Size(10, 10),
            maximumSize: const Size(25, 25),
            numberOfParticles: 100,
            gravity: 0.2,
            emissionFrequency: 0.05,
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final int currentPoints;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.currentPoints,
    required this.onRedeem,
  });

  bool get canRedeem => currentPoints >= reward.pointsRequired;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canRedeem ? onRedeem : null,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image - Full width
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.white,
                  child: Image.asset(
                    reward.imageUrl ?? 'assets/images/macbook.png',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: canRedeem
                                ? [
                                    const Color(0xFF007AFF),
                                    const Color(0xFF5856D6),
                                  ]
                                : [
                                    const Color(0xFF3C3C43).withOpacity(0.2),
                                    const Color(0xFF3C3C43).withOpacity(0.1),
                                  ],
                          ),
                        ),
                        child: Icon(
                          _getIconData(reward.icon),
                          color: canRedeem
                              ? Colors.white
                              : const Color(0xFF3C3C43).withOpacity(0.5),
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: canRedeem
                            ? const Color(0xFF1C1C1E)
                            : const Color(0xFF3C3C43).withOpacity(0.6),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF3C3C43).withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Points
                    Row(
                      children: [
                        Icon(
                          Iconsax.star1,
                          size: 14,
                          color: canRedeem
                              ? const Color(0xFFFFA500)
                              : const Color(0xFF3C3C43).withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${reward.pointsRequired} điểm',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: canRedeem
                                ? const Color(0xFFFF8C00)
                                : const Color(0xFF3C3C43).withOpacity(0.5),
                          ),
                        ),
                        if (!canRedeem) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(Thiếu ${reward.pointsRequired - currentPoints} điểm)',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFFFF3B30).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Redeem button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: canRedeem
                            ? const Color(0xFF1e293b)
                            : const Color(0xFF1e293b).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Đổi thưởng',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: canRedeem
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
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

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'airpods':
        return Iconsax.headphone;
      case 'iphone15':
        return Iconsax.mobile;
      case 'macbook':
        return Iconsax.monitor;
      case 'ipad_pro':
        return Iconsax.mobile;
      case 'apple_watch':
        return Iconsax.watch;
      case 'keyboard':
        return Iconsax.keyboard;
      default:
        return Iconsax.gift;
    }
  }
}
