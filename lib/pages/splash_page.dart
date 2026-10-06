import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _contentAnimation;

  Timer? _navigationTimer;

  int _currentStep = 0;

  final List<String> _steps = [
    'INITIALIZING CAMERA TRAP',
    'DETECTING WILDLIFE ACTIVITY',
    'CAPTURING EVENT',
    'ANALYZING WITH AI',
    'LOADING DASHBOARD',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _contentAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addListener(_updateStep);

    _controller.forward();

    _navigationTimer = Timer(
      const Duration(milliseconds: 5600),
      _openDashboard,
    );
  }

  void _updateStep() {
    final value = _controller.value;

    int newStep;

    if (value < 0.20) {
      newStep = 0;
    } else if (value < 0.40) {
      newStep = 1;
    } else if (value < 0.60) {
      newStep = 2;
    } else if (value < 0.80) {
      newStep = 3;
    } else {
      newStep = 4;
    }

    if (newStep != _currentStep && mounted) {
      setState(() {
        _currentStep = newStep;
      });
    }
  }

  void _openDashboard() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AppShell(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.removeListener(_updateStep);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // BACKGROUND CAMERA TRAP SCENE
              // ============================================================
              Image.asset(
                'assets/splash_camera_trap.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(
                        Icons.forest_rounded,
                        color: AppColors.primary,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),

              // ============================================================
              // DARK OVERLAY
              // ============================================================
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.38),
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.70),
                      Colors.black.withValues(alpha: 0.90),
                    ],
                    stops: const [
                      0.0,
                      0.38,
                      0.70,
                      1.0,
                    ],
                  ),
                ),
              ),

              // ============================================================
              // CAMERA TRAP HUD CORNERS
              // ============================================================
              Positioned(
                left: 28,
                top: 28,
                child: _HudCorner(
                  top: true,
                  left: true,
                ),
              ),

              Positioned(
                right: 28,
                top: 28,
                child: _HudCorner(
                  top: true,
                  left: false,
                ),
              ),

              Positioned(
                left: 28,
                bottom: 28,
                child: _HudCorner(
                  top: false,
                  left: true,
                ),
              ),

              Positioned(
                right: 28,
                bottom: 28,
                child: _HudCorner(
                  top: false,
                  left: false,
                ),
              ),

              // ============================================================
              // REC INDICATOR
              // ============================================================
              Positioned(
                left: 42,
                top: 42,
                child: Row(
                  children: [
                    _PulsingDot(
                      progress: progress,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // CAMERA TIMESTAMP
              // ============================================================
              Positioned(
                right: 42,
                top: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'CAMERA TRAP #03',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'WILDLIFE MONITORING',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // MAIN TITLE
              // ============================================================
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height * 0.14,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _contentAnimation,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.forest_rounded,
                          color: AppColors.primary,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'LEOPARD CAT MONITORING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'CAMERA TRAP OBSERVATION SYSTEM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: 130,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 13),
                        const Text(
                          'WILDLIFE  •  AI DETECTION  •  CONSERVATION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ============================================================
              // CENTER DETECTION SCAN
              // ============================================================
              Positioned(
                left: 24,
                right: 24,
                top: MediaQuery.of(context).size.height * 0.42,
                child: IgnorePointer(
                  child: _DetectionScanner(
                    progress: progress,
                  ),
                ),
              ),

              // ============================================================
              // BOTTOM LOADING AREA
              // ============================================================
              Positioned(
                left: 32,
                right: 32,
                bottom: 62,
                child: Column(
                  children: [
                    Text(
                      _steps[_currentStep],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Progress bar
                    Container(
                      height: 5,
                      constraints: const BoxConstraints(
                        maxWidth: 610,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.45,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Pipeline
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 850,
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < _steps.length; i++) ...[
                            Expanded(
                              child: _LoadingStep(
                                index: i,
                                currentStep: _currentStep,
                                icon: _stepIcon(i),
                                title: _stepTitle(i),
                                subtitle: _stepSubtitle(i),
                              ),
                            ),
                            if (i != _steps.length - 1)
                              Container(
                                width: 22,
                                height: 1,
                                color: i < _currentStep
                                    ? AppColors.primary
                                    : Colors.white24,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _stepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.camera_alt_outlined;
      case 1:
        return Icons.pets_outlined;
      case 2:
        return Icons.center_focus_strong;
      case 3:
        return Icons.psychology_outlined;
      default:
        return Icons.bar_chart_rounded;
    }
  }

  String _stepTitle(int index) {
    switch (index) {
      case 0:
        return 'INITIALIZING';
      case 1:
        return 'DETECTING';
      case 2:
        return 'CAPTURING';
      case 3:
        return 'ANALYZING';
      default:
        return 'LOADING';
    }
  }

  String _stepSubtitle(int index) {
    switch (index) {
      case 0:
        return 'CAMERA TRAP';
      case 1:
        return 'WILDLIFE';
      case 2:
        return 'EVENT';
      case 3:
        return 'WITH AI';
      default:
        return 'DASHBOARD';
    }
  }
}

class _HudCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _HudCorner({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: CustomPaint(
        painter: _HudCornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _HudCornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _HudCornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;

    if (left) {
      path.moveTo(x, y + (top ? 30 : -30));
      path.lineTo(x, y);
      path.lineTo(x + 30, y);
    } else {
      path.moveTo(x, y + (top ? 30 : -30));
      path.lineTo(x, y);
      path.lineTo(x - 30, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HudCornerPainter oldDelegate) {
    return oldDelegate.top != top || oldDelegate.left != left;
  }
}

class _PulsingDot extends StatelessWidget {
  final double progress;

  const _PulsingDot({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 0.5 + (0.5 * (1 - (progress * 8 % 1)));

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.redAccent.withValues(
          alpha: 0.65 + (pulse * 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.55),
            blurRadius: 9,
          ),
        ],
      ),
    );
  }
}

class _DetectionScanner extends StatelessWidget {
  final double progress;

  const _DetectionScanner({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scannerWidth = width > 900 ? 720.0 : width * 0.82;

    return Center(
      child: SizedBox(
        width: scannerWidth,
        height: 190,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ScannerPainter(
                  progress: progress,
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 25,
              child: _DetectionCorner(
                top: true,
                left: true,
              ),
            ),
            Positioned(
              right: 25,
              top: 25,
              child: _DetectionCorner(
                top: true,
                left: false,
              ),
            ),
            Positioned(
              left: 25,
              bottom: 25,
              child: _DetectionCorner(
                top: false,
                left: true,
              ),
            ),
            Positioned(
              right: 25,
              bottom: 25,
              child: _DetectionCorner(
                top: false,
                left: false,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      progress > 0.6
                          ? 'AI ANALYZING EVENT'
                          : 'WILDLIFE DETECTION',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;

  _ScannerPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final scanY = size.height * progress;

    canvas.drawLine(
      Offset(20, scanY),
      Offset(size.width - 20, scanY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DetectionCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _DetectionCorner({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _DetectionCornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _DetectionCornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  _DetectionCornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (top && left) {
      path.moveTo(0, 12);
      path.lineTo(0, 0);
      path.lineTo(12, 0);
    } else if (top && !left) {
      path.moveTo(size.width - 12, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, 12);
    } else if (!top && left) {
      path.moveTo(0, size.height - 12);
      path.lineTo(0, size.height);
      path.lineTo(12, size.height);
    } else {
      path.moveTo(size.width - 12, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - 12);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant _DetectionCornerPainter oldDelegate,
  ) {
    return oldDelegate.top != top || oldDelegate.left != left;
  }
}

class _LoadingStep extends StatelessWidget {
  final int index;
  final int currentStep;
  final IconData icon;
  final String title;
  final String subtitle;

  const _LoadingStep({
    required this.index,
    required this.currentStep,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isCurrent = index == currentStep;

    final color = isDone || isCurrent ? AppColors.primary : Colors.white54;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(
                alpha: isCurrent ? 0.95 : 0.55,
              ),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            color: color,
            size: 23,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
