import 'package:flutter/material.dart';
import 'dart:math' show pi;

class AnimationOne extends StatefulWidget {
  const AnimationOne({Key? key}) : super(key: key);

  @override
  State<AnimationOne> createState() => _AnimationOneState();
}

class _AnimationOneState extends State<AnimationOne>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    //_controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      _controller
        ..reset()
        ..forward();
    });

    return Center(
      child: Scaffold(
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 100,
            color: Colors.blue,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.centerLeft,
                  origin: const Offset(50, 0),
                  transform: Matrix4.identity()..rotateZ(_animation.value),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
