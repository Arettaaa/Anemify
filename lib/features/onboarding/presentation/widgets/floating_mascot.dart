import 'package:flutter/material.dart';

class FloatingMascot extends StatefulWidget {
  final Widget child;
  final double distance;

  const FloatingMascot({super.key, required this.child, this.distance = 6});

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  late final Animation<double> _offset = Tween<double>(
    begin: -widget.distance,
    end: widget.distance,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _offset.value), child: child),
      child: widget.child,
    );
  }
}