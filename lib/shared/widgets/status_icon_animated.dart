import 'package:flutter/material.dart';

class StatusIconAnimated extends StatefulWidget {
  const StatusIconAnimated({
    super.key,
    required this.color,
    required this.icon,
    this.size = 140,
    this.iconSize = 52,
  });

  final Color color;
  final IconData icon;
  final double size;
  final double iconSize;

  @override
  State<StatusIconAnimated> createState() => _StatusIconAnimatedState();
}

class _StatusIconAnimatedState extends State<StatusIconAnimated>
    with TickerProviderStateMixin {
  late final AnimationController _popController;
  late final Animation<double> _scale;

  late final AnimationController _rippleController;
  late final Animation<double> _ripple;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.70, end: 1.08), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.00), weight: 40),
    ]).animate(CurvedAnimation(parent: _popController, curve: Curves.easeOut));

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _ripple = CurvedAnimation(parent: _rippleController, curve: Curves.easeOut);

    _popController.forward();
    _rippleController.repeat();
  }

  @override
  void dispose() {
    _popController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.size;
    final mid = base * 0.86;
    final core = base * 0.62;

    return SizedBox(
      width: base,
      height: base,
      child: AnimatedBuilder(
        animation: Listenable.merge([_popController, _rippleController]),
        builder: (context, _) {
          final rippleScale = 0.75 + (_ripple.value * 0.75);
          final rippleOpacity = (1.0 - _ripple.value).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: rippleScale,
                child: Container(
                  width: base,
                  height: base,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(0.25 * rippleOpacity),
                      width: 10,
                    ),
                  ),
                ),
              ),
              Container(
                width: mid,
                height: mid,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.16),
                ),
              ),
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: core,
                  height: core,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 22,
                        offset: const Offset(0, 12),
                        color: widget.color.withOpacity(0.25),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.iconSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
