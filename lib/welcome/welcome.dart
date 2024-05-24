import 'dart:math';
import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart'; // Importa Cupertino
import 'package:flutter/material.dart';
import '../login/login.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showContent = true;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor =
        screenWidth / 375.0; // 375.0 es el ancho base del diseño

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final isUnder = (ValueKey(_showContent) != child?.key);
              final rotationValue = isUnder
                  ? min(_animation.value, 0.5)
                  : max(_animation.value - 0.5, 0.0);

              return Transform(
                transform: Matrix4.rotationY(rotationValue * pi),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: _showContent
                ? _buildContent(key: ValueKey(true), scaleFactor: scaleFactor)
                : _buildLoading(key: ValueKey(false), scaleFactor: scaleFactor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required Key key, required double scaleFactor}) {
    return Column(
      key: key,
      children: [
        Spacer(flex: 3),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido',
                style: TextStyle(
                  color: skyBluePrimary,
                  fontSize: 40 * scaleFactor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SFPro',
                ),
              ),
              SizedBox(width: 8 * scaleFactor),
              Image.asset(
                'lib/assets/images/listifyIconRecortada.png',
                height: 40.0 *
                    scaleFactor, // Ajusta el tamaño según tus necesidades
              ),
            ],
          ),
        ),
        SizedBox(height: 10 * scaleFactor),
        Text(
          'Listify, la mejor aplicación para gestionar tus listas y eventos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16 * scaleFactor,
            fontFamily: 'SFPro',
          ),
        ),
        SizedBox(height: 20 * scaleFactor),
        Image.asset(
          'lib/assets/images/welcome.png',
          height: 300 * scaleFactor,
        ),
        Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: skyBluePrimary,
            onPressed: () async {
              await _controller.reverse();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              'Comencemos',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16 * scaleFactor,
                fontFamily: 'SFPro',
              ),
            ),
          ),
        ),
        Spacer(flex: 1),
      ],
    );
  }

  Widget _buildLoading({required Key key, required double scaleFactor}) {
    return Container(
      key: key,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(skyBluePrimary),
          strokeWidth: 3 * scaleFactor,
        ),
      ),
    );
  }
}
