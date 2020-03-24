import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';
import 'dart:math' as math;

import 'package:psycho_app/custom_widgets/wave/wave.dart';
import 'package:psycho_app/screens/game/game.dart';
import 'package:psycho_app/screens/register/register.dart';
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
  String welcomeText = "";

  Future<bool> loadSettings() async {
    await Settings.read('main').then((value) {
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (value['welcomeText'] != null) {
        welcomeText = value['welcomeText'];
      }
    });
    await Settings.read('session').then((value) {
      if (value['name'] != null)
        welcomeText += value['name'];
      else
        welcomeText = null;
    });
    return true;
  }


  @override
  void initState() {
    loadSettings().then((value) => setState((){}));
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          color: Colors.amber,
          child: Stack(
            alignment: AlignmentDirectional.center,
            fit: StackFit.expand,
            children: <Widget>[
              getWaves(),
              welcomeText == null ? Container() : Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.topCenter,
                    child: Text(welcomeText, style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width/(max(welcomeText.length, 5)),
                      color: Colors.yellow,
                      shadows: [Shadow(color: Colors.deepOrangeAccent,
                      offset: Offset(2, 2))]
                      )
                    ),
                  ),
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
                        Colors.amber[300].withOpacity(0.66),
                        Colors.amber[900].withOpacity(0.66),
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
                        Colors.amber[300].withOpacity(0.66),
                        Colors.amber[900].withOpacity(0.66),
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
              Align(
                alignment: Alignment.bottomCenter,
                child:
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: RaisedButton(
                          child: Icon(Icons.directions_run),
                          color: Colors.redAccent,
                          shape: CircleBorder(),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Register()),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: RaisedButton(
                          child: Icon(Icons.settings),
                          color: Colors.yellow,
                          shape: CircleBorder(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Settings()),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget getWaves() {
    return
      WaveWidget(
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
          durations: [30000, 30000, 30000, 30000],
          heightPercentages: [0.0, 0.25, 0.50, 0.75],
        ),
        duration: 100,
        isLoop: true,
        size: Size(
          double.infinity,
          double.infinity,
        ),
        waveAmplitude: 10.0,
      );
  }

  Widget getParticles() {
    return
      Positioned.fill(
          child: Particles(
              quan: 20,
              colors : [
            Colors.redAccent[200],
                Colors.red[600],
                Colors.redAccent[400],
                Colors.red[700]
          ],
            duration: Duration(milliseconds: 8000),
            minSize: 0.4,
            maxSize: 0.8,
          ));
  }

}
