import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';
import 'dart:math' as math;

import 'package:psycho_app/custom_widgets/wave/wave.dart';
import 'package:psycho_app/screens/game/game.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  List<Color> buttonsAlpha = List.filled(2, Color(0xffffffff));

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
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              color: Color(0x55ffff00),
              child: WaveWidget(
                backgroundColor: Color(0xFFFF8833),
                config: CustomConfig(
                  gradients: [
                    [Colors.redAccent, Color(0x88F68484)],
                    [Colors.red, Color(0x77E57373)],
                    [Colors.orange, Color(0x66FF9800)],
                    [Colors.yellow, Color(0x55FFEB3B)]
                  ],
                  blur: MaskFilter.blur(
                    BlurStyle.outer,
                    0.0,
                  ),
                  durations: [30000, 20000, 12000, 10000],
                  heightPercentages: [0.0, 0.30, 0.50, 0.80],
                ),
                duration: 2000,
                isLoop: true,
                size: Size(
                  double.infinity,
                  double.infinity,
                ),
                waveAmplitude: 10.0,
              ),
            ),
            Align(
              alignment: orientation == Orientation.landscape ? Alignment(-0.5, -0.2) : Alignment(0, -0.4),
              widthFactor: 0.15,
              heightFactor: 0.15,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: buttonsAlpha[0],
                  gradient: LinearGradient(
                    colors: <Color>[
                      const Color(0xaaffe200),
                      const Color(0xaafda72d),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Game(folderName: "assets/tBalloons/",)),
                    );
                  },
                  onTapDown: (tapDownDetails) {
                      buttonsAlpha[0] = Color(0x33ffffff);
                    },
                  onTapCancel: () {
                    buttonsAlpha[0] = Color(0xffffffff);
                  },
                  onTapUp: (tepUpDetails) {
                    buttonsAlpha[0] = Color(0xffffffff);
                  } ,

                  child: Image(
                    image: AssetImage("assets/balloons.png"),
                    colorBlendMode: BlendMode.dstIn,
                    color: buttonsAlpha[0],
                  ),
                ),
              ),
            ),
            Align(
              alignment: orientation == Orientation.landscape ? Alignment(0.5, 0.3) : Alignment(0, 0.4),
              widthFactor: 0.15,
              heightFactor: 0.15,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: buttonsAlpha[1],
                  gradient: LinearGradient(
                    colors: <Color>[
                      const Color(0xaaffe200),
                      const Color(0xaafda72d),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                  },
                  onTapDown: (tapDownDetails) {
                    buttonsAlpha[1] = Color(0x33ffffff);
                  },
                  onTapCancel: () {
                    buttonsAlpha[1] = Color(0xffffffff);
                  },
                  onTapUp: (tepUpDetails) {
                    buttonsAlpha[1] = Color(0xffffffff);
                  } ,
                  child: Image(
                    image: AssetImage("assets/clown.png"),
                    colorBlendMode: BlendMode.dstIn,
                    color: buttonsAlpha[1],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        backgroundColor: const Color(0x99E57373),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Settings()),
          );
        },
      ),
    );
  }
}
