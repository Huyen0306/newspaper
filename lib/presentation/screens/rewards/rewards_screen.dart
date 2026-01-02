import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/services/points_service.dart';
import '../../widgets/custom_app_bar.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with AutomaticKeepAliveClientMixin {
  final PointsService _pointsService = PointsService();
  int _currentPoints = 0;
  bool _isLoading = true;

  // Sample rewards data
  final List<RewardModel> _rewards = [
    RewardModel(
      id: 1,
      title: 'Voucher 50K',
      description: 'Giảm 50.000đ cho đơn hàng tiếp theo',
      pointsRequired: 100,
      icon: 'voucher',
    ),
    RewardModel(
      id: 2,
      title: 'Voucher 100K',
      description: 'Giảm 100.000đ cho đơn hàng tiếp theo',
      pointsRequired: 200,
      icon: 'voucher',
    ),
    RewardModel(
      id: 3,
      title: 'Voucher 200K',
      description: 'Giảm 200.000đ cho đơn hàng tiếp theo',
      pointsRequired: 400,
      icon: 'voucher',
    ),
    RewardModel(
      id: 4,
      title: 'Miễn phí vận chuyển',
      description: 'Miễn phí ship cho đơn hàng tiếp theo',
      pointsRequired: 50,
      icon: 'shipping',
    ),
    RewardModel(
      id: 5,
      title: 'Tặng kèm quà',
      description: 'Nhận quà tặng kèm khi mua hàng',
      pointsRequired: 150,
      icon: 'gift',
    ),
    RewardModel(
      id: 6,
      title: 'Ưu đãi đặc biệt',
      description: 'Giảm 30% cho tất cả sản phẩm',
      pointsRequired: 300,
      icon: 'discount',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pointsService.pointsNotifier.addListener(_onPointsChanged);
  }

  @override
  void dispose() {
    _pointsService.pointsNotifier.removeListener(_onPointsChanged);
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
        title: const Text('Xác nhận đổi thưởng'),
        content: Text(
          'Bạn có chắc muốn đổi "${reward.title}" với ${reward.pointsRequired} điểm?',
        ),
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
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _pointsService.addPoints(-reward.pointsRequired);
      if (success && mounted) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
          onTap: canRedeem ? onRedeem : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: canRedeem
                          ? [const Color(0xFF007AFF), const Color(0xFF5856D6)]
                          : [
                              const Color(0xFF3C3C43).withOpacity(0.2),
                              const Color(0xFF3C3C43).withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(reward.icon),
                    color: canRedeem
                        ? Colors.white
                        : const Color(0xFF3C3C43).withOpacity(0.5),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
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
                    ],
                  ),
                ),
                // Redeem button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: canRedeem
                        ? const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                          )
                        : null,
                    color: canRedeem ? null : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Đổi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: canRedeem
                          ? Colors.white
                          : const Color(0xFF3C3C43).withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'voucher':
        return Iconsax.discount_shape;
      case 'shipping':
        return Iconsax.truck;
      case 'gift':
        return Iconsax.gift;
      case 'discount':
        return Iconsax.tag;
      default:
        return Iconsax.gift;
    }
  }
}
