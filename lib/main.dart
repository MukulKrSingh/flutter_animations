import 'package:flutter/material.dart';

import 'dart:math' show pi;

import 'package:flutter_animations/animations/animation_1/animations_one.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const AnimationOne() // const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//Circle side
enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();
    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;

        break;

      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;

        break;
    }

    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockwise,
    );

    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  CircleSide side;

  HalfCircleClipper({
    required this.side,
  });

  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) => Future.delayed(duration, this);
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationController;
  late Animation<double> _counterClockwiseRotationAnimation;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _counterClockwiseRotationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );

    _counterClockwiseRotationAnimation =
        Tween<double>(begin: 0.0, end: -(pi / 2)).animate(
      CurvedAnimation(
        parent: _counterClockwiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    //_counterClockwiseRotationController.repeat();

    //Flip Animation
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: pi,
    ).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.bounceOut,
      ),
    );

    //Status Listener
    _counterClockwiseRotationController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          _flipAnimation = Tween<double>(
            begin: _flipAnimation.value,
            end: _flipAnimation.value + pi,
          ).animate(
            CurvedAnimation(
              parent: _flipController,
              curve: Curves.bounceOut,
            ),
          );

          //reset the flip controller and start the animation
          _flipController
            ..reset()
            ..forward();
        }
      },
    );

    _flipAnimation.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          _counterClockwiseRotationAnimation = Tween<double>(
                  begin: _counterClockwiseRotationAnimation.value,
                  end: _counterClockwiseRotationAnimation.value + -(pi / 2))
              .animate(
            CurvedAnimation(
              parent: _counterClockwiseRotationController,
              curve: Curves.bounceOut,
            ),
          );

          _counterClockwiseRotationController
            ..reset()
            ..forward();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _counterClockwiseRotationController.dispose();
    _flipController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockwiseRotationController
      ..reset()
      ..forward.delayed(
        const Duration(seconds: 1),
      );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
              animation: _counterClockwiseRotationController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  //origin: const Offset(100, 50),
                  transform: Matrix4.identity()
                    ..rotateZ(_counterClockwiseRotationAnimation.value),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerRight,
                            transform: Matrix4.identity()
                              ..rotateY(_flipAnimation.value),
                            child: ClipPath(
                              clipper: HalfCircleClipper(side: CircleSide.left),
                              child: Container(
                                height: 100,
                                width: 100,
                                color: Colors.blue,
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerLeft,
                            transform: Matrix4.identity()
                              ..rotateY(_flipAnimation.value),
                            child: ClipPath(
                              clipper: HalfCircleClipper(side: CircleSide.right),
                              child: Container(
                                height: 100,
                                width: 100,
                                color: Colors.yellow,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
