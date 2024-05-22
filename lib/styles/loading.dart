import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlinkingDots(),
          SizedBox(height: 10),
          Text(
            'Cargando',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class BlinkingDots extends StatefulWidget {
  @override
  _BlinkingDotsState createState() => _BlinkingDotsState();
}

class _BlinkingDotsState extends State<BlinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: DelayTween(begin: 0.0, end: 1.0, delay: index * 0.2)
              .animate(_animation),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              '.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DelayTween extends Tween<double> {
  final double delay;

  DelayTween({required double begin, required double end, required this.delay})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((t - delay).clamp(0.0, 1.0));
  }

  @override
  double evaluate(Animation<double> animation) {
    return lerp(animation.value);
  }
}
