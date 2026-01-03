import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/services/task_service.dart';
import '../../data/services/points_service.dart';

class FloatingRewardBadge extends StatefulWidget {
  const FloatingRewardBadge({super.key});

  @override
  State<FloatingRewardBadge> createState() => _FloatingRewardBadgeState();
}

class _FloatingRewardBadgeState extends State<FloatingRewardBadge>
    with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final PointsService _pointsService = PointsService();

  late AnimationController _appearController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _displaySeconds = 5;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Animation for appearing (350ms)
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeIn,
    );

    // Animation for progress (exactly 5s)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addListener(() {
      // Calculate remaining seconds: 5, 4, 3, 2, 1, 0
      final remaining = (5 - _progressController.value * 5).ceil();
      if (remaining != _displaySeconds) {
        setState(() {
          _displaySeconds = remaining;
        });
      }
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleCompletion();
      }
    });

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    _startTask();
  }

  Future<void> _startTask() async {
    // Reset task every time entering the page to ensure it "appears continuously"
    await _taskService.resetTask();

    if (mounted) {
      _appearController.forward();
      _progressController.forward();
    }
  }

  Future<void> _handleCompletion() async {
    if (_isCompleted) return;

    // Update task service
    await _taskService.updateReadTime(5);

    // Add points
    await _pointsService.addPoints(_taskService.rewardPoints);

    if (mounted) {
      setState(() {
        _isCompleted = true;
      });

      // Trigger sound, confetti and snackbar simultaneously
      _audioPlayer.play(AssetSource('sounds/success.mp3'));
      _confettiController.play();

      // Flash or animate out
      _appearController.reverse();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stars, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Chúc mừng! Bạn nhận được ${_taskService.rewardPoints} điểm',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _progressController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    return '$seconds s';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti Widget at the top center
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
            numberOfParticles: 100, // Increased particles
            gravity: 0.2, // Faster falling
            emissionFrequency: 0.05,
          ),
        ),

        // If completed and animation finished, hide
        if (!(_isCompleted && _appearController.isDismissed))
          Positioned(
            bottom: 30,
            right: 20,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 130,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress circle with time
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background circle
                                CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 6,
                                  color: Colors.white.withOpacity(0.15),
                                  strokeCap: StrokeCap.round,
                                ),
                                // Progress circle
                                CircularProgressIndicator(
                                  value: 1.0 - _progressController.value,
                                  strokeWidth: 6,
                                  color: Colors.white,
                                  strokeCap: StrokeCap.round,
                                ),
                                // Time text in center
                                Center(
                                  child: Text(
                                    _formatTime(_displaySeconds),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Banner with text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCC0000), Color(0xFF8B0000)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$_displaySeconds giây nữa',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
