import 'package:flutter/material.dart';

/// Widget animasi reusable — fade in + slide dari bawah (seperti StatisticCard di homepage)
class AnimatedFadeSlide extends StatefulWidget {
  final Widget child;
  final double beginY;
  final double delay;
  final Duration duration;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.beginY = 0.2, // jarak awal geser vertikal
    this.delay = 0.0, // waktu tunda animasi
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.beginY),
      end: Offset.zero,
    ).animate(curved);

    // Jalankan animasi setelah delay tertentu
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}
