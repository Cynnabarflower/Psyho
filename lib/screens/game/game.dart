import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/wave/config.dart';
import 'dart:math' as math;

import 'package:psycho_app/custom_widgets/wave/wave.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/reward/reward.dart';

class Game extends StatefulWidget {
  String folderName;

  @override
  _GameState createState() => _GameState();

  Game({this.folderName = 'assets/balloons/'});
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  List<AssetImage> images = [];
  int currentImageNumber = 0;
  int countDown = 3;
  AnimationController controller;
  Widget mainWidget;
  Widget countdownWidget;
  Future imagesLoaded;
  Animation countDownOpaque;
  List<int> delays = [];
  DateTime startTime;
  List<int> answers = [];
  List<Statistics> statistics = [];
  List<AssetImage> resetImages = [];
  Timer timer;

  @override
  void initState() {
    imagesLoaded = _loadAssets().then((value) => true);

    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    final curve = CurvedAnimation(curve: Curves.decelerate, parent: controller);
    countDownOpaque = Tween<double>(begin: 1, end: 0.6).animate(curve);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          countDown--;
          controller.repeat();
        });
      }
    });
  }

  Future _loadAssets() async {
    // >> To get paths you need these 2 lines
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    for (var key in manifestMap.keys) {
      if (key.startsWith(widget.folderName)) {
        if (key.toLowerCase().endsWith('.jpg') ||
            key.toLowerCase().endsWith('.png')) if (key
                .endsWith('BMTblue.JPG') ||
            key.endsWith("BMTgreen.JPG")) {
          resetImages.add(AssetImage(key));
        } else
          images.add(AssetImage(key));
      }
    }

    DefaultAssetBundle.of(context)
        .loadString('assets/balloons/answers.txt')
        .then((value) {
      List<String> answers = value.toString().split('\n');
      int offset = 0;
      for (var answer in answers) {
        switch (answer.trim()) {
          case "s":
            this.answers.add(1);
            break;
          case "d":
            this.answers.add(2);
            break;
          case "f":
            images.insert(
                this.answers.length, resetImages[math.Random().nextInt(2)]);
            this.answers.add(0);
            this.answers.add(2);
            break;
          default:
            break;
        }
      }
    });

    return true;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    startTime = new DateTime.now();
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder(
          future: imagesLoaded,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                countDown <= 0) {
              if (timer != null)
                timer.cancel();
              timer = Timer(Duration(seconds: 3), () {
                print('timer!');
                choiceMade(0);
              });
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xffffffff),
                      ),
                      child: GestureDetector(
                        onTap: () => {print('tapped')},
                        child: Image(
                          image: images[currentImageNumber],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0x88880000),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                choiceMade(2);
                              },
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
                                choiceMade(1);
                              },
                            ),
                          ))
                    ]),
                  )
                ],
              );
            } else {
              controller.forward();
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              color: Colors.redAccent),
                          text: countDown.toString()),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    child: Container(
                      color: Colors.amber
                    ),
                    builder: (BuildContext context, Widget child) {
                      return Opacity(
                        opacity: countDownOpaque.value,
                        child: child,
                      );
                    },
                  ),
                ],
              );
            }
          }),
    );
  }

  void choiceMade(int answer) {
    statistics.add(Statistics(
        DateTime.now().difference(startTime).inMicroseconds,
        answers[currentImageNumber] == answer ||
            answers[currentImageNumber] == 0));
    currentImageNumber++;
    if (currentImageNumber >= images.length || currentImageNumber > 12) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Reward(statistics)),
      );
    } else {
      setState(() {});
    }
  }
}
