import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/reward/reward.dart';

class Game extends StatefulWidget {
  String folderName;
  int level = 0;

  @override
  _GameState createState() => _GameState();

  Game({this.folderName = 'assets/balloons/', this.level = 0}) {
    if (!this.folderName.endsWith('/'))
      this.folderName += "/";
  }
}

enum ANSWERS {
  SAME,
  DIFFERENT,
  NONE
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
  List<ANSWERS> answers = [];
  List<Statistics> statistics = [];
  List<AssetImage> resetImages = [];
  AssetImage plusImage;
  Timer timer;
  Offset handOffset = Offset(0, 0);
  Animation handTween;
  final GlobalKey _buttonSame = GlobalKey();
  RenderBox _buttonSameBox;
  final GlobalKey _buttonDifferent = GlobalKey();
  RenderBox _buttonDifferentBox;
  Offset _handOffset;
  bool runTutorial = true;
  bool nextImage = true;
  double dragDelta = 0;
  double ROTATE_STEP = 3.0/255;

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

  Future _loadAssets({int level = 0}) async {

    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    plusImage = AssetImage('assets/plus.png');
    resetImages.add(AssetImage('assets/balloons/BMTblue.JPG'));
    resetImages.add(AssetImage('assets/balloons/BMTgreen.JPG'));

    for (var key in manifestMap.keys) {
      if (key.startsWith(widget.folderName)) {
        if (key.toLowerCase().endsWith('.jpg') ||
            key.toLowerCase().endsWith('.png')) if (key
                .endsWith('BMTblue.JPG') ||
            key.endsWith("BMTgreen.JPG")) {
          //
        } else
          images.add(AssetImage(key));
      }
    }

    DefaultAssetBundle.of(context)
        .loadString(widget.folderName+'answers.txt')
        .then((value) {
      List<String> answers = value.toString().split('\n');
      int offset = 0;
      for (var answer in answers) {
        switch (answer.trim()) {
          case ";":
            break;
          case "s":
            this.answers.add(ANSWERS.SAME);
            break;
          case "d":
            this.answers.add(ANSWERS.DIFFERENT);
            break;
          case "f":
            images.insert(
                this.answers.length, resetImages[math.Random().nextInt(2)]);
            this.answers.add(ANSWERS.NONE);
            this.answers.add(ANSWERS.DIFFERENT);
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
          alignment: Alignment.center,
          children: [
        FutureBuilder(
            future: imagesLoaded,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  countDown <= 0) {
                if (nextImage) {
                  dragDelta = 0;
                  startTime = new DateTime.now();
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    updateBoxes();
                    updateHand();
                    updateTimer();
                  });
                }
                return Stack(
                  children: [Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AbsorbPointer(
                          absorbing: answers[currentImageNumber] == ANSWERS.NONE,
                          child: Transform.rotate(
                            angle: answers[currentImageNumber] == ANSWERS.NONE ? 0 : dragDelta*ROTATE_STEP,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xffffffff),
                              ),
                              child: GestureDetector(
                                onHorizontalDragStart: (d) {print('drag start');},
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    dragDelta += details.primaryDelta;
                                    print(dragDelta);
                                  });
                                },
                                onHorizontalDragEnd: (details) {
                                  setState(() {

                                    if (dragDelta < -50) {
                                      choiceMade(ANSWERS.DIFFERENT);
                                    } else if (dragDelta > 50) {
                                      choiceMade(ANSWERS.SAME);
                                    }
                                    dragDelta = 0;
                                  });
                                },
                                onTap: () => {print('tapped')},
                                child: Image(
                                  image: images[currentImageNumber],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: AbsorbPointer(
                          absorbing: answers[currentImageNumber] == ANSWERS.NONE,
                          child: ColorFiltered(
                            colorFilter: answers[currentImageNumber] == ANSWERS.NONE ?
                            ColorFilter.mode(const Color(0x99FFFFFF), BlendMode.lighten)
                                : ColorFilter.mode(const Color(0x00000000), BlendMode.dst),
                            child: Visibility(
                              visible: true, //answers[currentImageNumber] != ANSWERS.NONE,
                              child: Row(children: [
                                Expanded(
                                  key: _buttonDifferent,
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0x88880000),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          choiceMade(ANSWERS.DIFFERENT);
                                        },
                                          child: Container(
                                            padding: EdgeInsets.all(32),
                                            margin:  EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0x99990000),
                                              shape: BoxShape.circle
                                            ),
                                            child: Container(
                                              child: Image(
                                                  color: const Color(0x88880000),
                                                  fit: BoxFit.contain,
                                                  image: AssetImage('assets/close.png')
                                              ),
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                      ),
                                    )),
                                Expanded(
                                  key: _buttonSame,
                                    flex: 1,
                                    child: Container(
                                    alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0x88008800),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          choiceMade(ANSWERS.SAME);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(32),
                                          margin:  EdgeInsets.all(8),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: const Color(0x99009900),
                                              shape: BoxShape.circle
                                          ),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: Image(
                                                color: const Color(0x88008800),
                                                fit: BoxFit.contain,
                                                image: AssetImage('assets/correct.png')
                                            ),
                                          ),
                                        )
                                      ),
                                    ))
                              ]),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                    AnimatedPositioned(
                      child: Visibility(
                        visible: runTutorial,
                        child: Container(
                          width: 200,
                          height: 200,
                          child: Image(
                            image: AssetImage('assets/finger.png'),
                          ),
                        ),
                      ),
                      left: handOffset.dx,
                      top: handOffset.dy,
                      duration: Duration(milliseconds: 600),
                    )],
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
                            style: TextStyle(color: Colors.redAccent),
                            text: countDown.toString()),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: controller,
                      child: Container(color: Colors.amber),
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
        ]),
    );
  }

  void choiceMade(ANSWERS answer) {
    statistics.add(Statistics(
        DateTime.now().difference(startTime).inMicroseconds,
        answers[currentImageNumber] == answer ||
            answers[currentImageNumber] == ANSWERS.NONE));

    if (currentImageNumber >= images.length || currentImageNumber > 12) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Reward(statistics)),
      );
    } else {
      setState(() {
        nextImage = true;
        currentImageNumber++;
        //if (runTutorial)
          //updateHand();
      });
    }
  }

  void updateHand() {
    if (_buttonSameBox != null) {
      var off;
      if (answers[currentImageNumber] == ANSWERS.SAME)
        off = _buttonSameBox.localToGlobal(Offset.zero);
      else if (answers[currentImageNumber] == ANSWERS.DIFFERENT)
        off = _buttonDifferentBox.localToGlobal(Offset.zero);
      else
        off = Offset(0, 0);
      handOffset =
          Offset(off.dx - 0.455 * 200 + _buttonDifferentBox.size.width / 2,
              off.dy - 0.1 * 200 + _buttonDifferentBox.size.height / 2
          );
    }
    setState(() {
      nextImage = false;
    });
  }

  void updateBoxes() {
    if (_buttonSame != null && _buttonSame.currentContext != null) {
      _buttonSameBox = _buttonSame.currentContext.findRenderObject();
      _buttonDifferentBox = _buttonDifferent.currentContext.findRenderObject();
    }
  }

  void updateTimer() {
    if (timer != null)
      timer.cancel();
      timer = Timer(Duration(seconds: 3), () {
      print('timer!');
      if (runTutorial)
        choiceMade(answers[currentImageNumber]);
      else
        choiceMade(ANSWERS.NONE);
    });
  }

}
