import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:confetti/src/enums/confetti_controller_state.dart';
import 'package:flutter_app/main.dart';

class AllConfettiWidget extends StatefulWidget {
  final Widget child;

  const AllConfettiWidget({
    @required this.child,
    Key key,
  }) : super(key: key);
  @override
  _AllConfettiWidgetState createState() => _AllConfettiWidgetState();
}

class _AllConfettiWidgetState extends State<AllConfettiWidget> {
  ConfettiController controller;

  @override
  void initState() {
    super.initState();

    controller = ConfettiController(duration: Duration(seconds: 5));
    controller.play();
  }

  static final double right = 0;
  static final double down = pi / 2;
  static final double left = pi;
  static final double top = -pi / 2;

  final double blastDirection = left;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          widget.child,
          RaisedButton(
            child: Text("Return Home"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthenticationWrapper(),
              ),
            ),
          ),
        ]),
        buildConfetti(),
      ],
    );
  }

  Widget buildConfetti() => Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: controller,
          colors: [
            Colors.pinkAccent[400],
            Colors.lightBlue[600],
            Colors.red,
            Colors.indigo,
            Colors.orangeAccent[700]
          ],
          //blastDirection: blastDirection,
          blastDirectionality: BlastDirectionality.explosive,
          // shouldLoop: true,
          emissionFrequency: 0.05,
          numberOfParticles: 10, // number of confetti being blast
          gravity: 0.2,
          maxBlastForce: 5,
          minBlastForce: 4,
          particleDrag: 0.1,
        ),
      );
}
