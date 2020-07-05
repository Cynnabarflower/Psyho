import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';

import 'package:psycho_app/custom_widgets/wave/wave.dart';
import 'package:psycho_app/screens/game/LevelChooser.dart';
import 'package:psycho_app/screens/register/register.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class MainMenu extends StatefulWidget {

  TabController tabController;
  String name;

  @override
  _MainMenuState createState() => _MainMenuState();

  MainMenu({this.tabController, this.name}) {
  }

}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {

  AnimationController animationController;
  Animation<double> animation;
  List<Color> buttonsAlpha = List.filled(2, Color(0xffffffff));
  String welcomeText = "";
  GlobalKey tabsKey = GlobalKey();
  PageController pageController = PageController(initialPage: 1);
  ScrollPhysics pageScrollPhysics = NeverScrollableScrollPhysics();
  String gameName = '';


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
    Settings.setParam('main', 'first_launch', false);
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

    pageController.addListener(() {
      print(pageController.page);
      pageScrollPhysics = pageController.page == 1 ? NeverScrollableScrollPhysics() :  AlwaysScrollableScrollPhysics();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    var vtabs = PageView(
      children: [
        LevelChooser(gameName),
        OrientationBuilder(builder: (context, orientation) {
          return Container(
            color: Colors.white,
            child: Stack(
              alignment: AlignmentDirectional.center,
              fit: StackFit.expand,
              children: <Widget>[
                getWaves(),
                Align(
                  alignment: orientation == Orientation.landscape ? Alignment(-0.5, -0.2) : Alignment(0, -0.4),
                  widthFactor: 0.15,
                  heightFactor: 0.15,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: buttonsAlpha[0].withOpacity(0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          gameName = 'assets/tBalloons/';
                          pageController.animateToPage(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
                        });
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
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(


                      color: Colors.white.withOpacity(0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () {
                        gameName = 'assets/Robot/';
                        pageController.animateToPage(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
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
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: RaisedButton(
                                child: Icon(Icons.person),
                                color: Colors.green.withOpacity(0.8),
                                shape: CircleBorder(),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => Register()),
                                  );
                                },
                              ),
                            ),
                            welcomeText == null ? Container() : Container(
                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(welcomeText, style: TextStyle(
                                fontSize: 180/(max(welcomeText.length, 5)),
                                color: Colors.lightBlueAccent[100],
                              )
                              ),
                            ),
                          ],

                        ),

                        SizedBox(
                          width: 60,
                          height: 60,
                          child: RaisedButton(
                            child: Icon(Icons.settings),
                            color: Colors.lightBlueAccent[100],
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
      ],
      controller: pageController,
      scrollDirection: Axis.vertical,
      physics: pageScrollPhysics,
    );

    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: vtabs
      ),
      onWillPop: (){
        if (pageController.page == 0) {
          pageController.animateToPage(1, duration: Duration(milliseconds: 1000),
              curve: Curves.easeInOut);
          return new Future(() => false);
        }
        return new Future(() => true);
      },
    );
  }

 Widget getWaves() {
    return
      WaveWidget(
        backgroundColor: Colors.lightBlueAccent.withOpacity(0.6),
        config: CustomConfig(
          gradients: [
            [Colors.white, Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.4), Colors.white.withOpacity(0.2), Colors.white.withOpacity(0)],
            [Colors.green, Colors.green],
            [Colors.green[700].withOpacity(0.15), Colors.green[700].withOpacity(0.1)],
            [Colors.green[900].withOpacity(0.1), Colors.green[900].withOpacity(0.1)],

          ],
          blur: MaskFilter.blur(
            BlurStyle.outer,
            0.0,
          ),
          durations: [30000, 30000, 30000, 30000],
          heightPercentages: [0.0, 0.75, 0.85, 0.95],
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
