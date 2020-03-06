import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';
import 'dart:math' as math;

import 'package:psycho_app/custom_widgets/wave/wave.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 10));

    final curve = new CurvedAnimation(
        parent: animationController,
        curve: Curves.bounceIn,
        reverseCurve: Curves.easeOut);

    animationController.addListener(() {
      setState(() {});
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });

    animation = Tween<double>(begin: 0, end: 2).animate(curve);

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: [
            Expanded(
              flex: 3,
        child:


                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        const Color(0x88ffe200),
                        const Color(0x88fda72d),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () => {print('tapped')},
                    child: Image(
                      image: AssetImage("assets/clown.png"),
                    ),
                  ),
                ),


            ),
            Expanded(
              flex: 1,
              child:
            Row(

              children: [
                Expanded(
                  flex: 1,
                    child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x88880000),
                  ),
                  child: GestureDetector(
                    onTap: () => {print('tapped')},
                  ),
                )),
                Expanded(
                    flex: 1,
                    child: Container(

                      decoration: BoxDecoration(
                        color: const Color(0x88008800),
                      ),
                      child: GestureDetector(
                        onTap: () => {print('tapped')},
                      ),
                    ))
              ]
            ),
            )
          ],
        ));
  }
}
