import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';
import 'dart:math' as math;

import 'package:psycho_app/custom_widgets/wave/wave.dart';
import 'package:psycho_app/screens/reward/reward.dart';

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xffaaaaaa),
                  ),
                  child: GestureDetector(
                    onTap: () => {print('tapped')},
                    child: Image(
                      image: AssetImage("assets/balloons/201.JPG"),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Reward()),
                          );
                        },
                      ),
                    ))
              ]
            ),
            )
          ],
        ));
  }
}
