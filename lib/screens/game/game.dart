import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/reward/reward.dart';
import 'package:psycho_app/screens/settings/settings.dart';

import 'AnswerButton.dart';
import 'dart:io' show Platform;


class Game extends StatefulWidget {
  String folderName;
  int level = 0;

  @override
  _GameState createState() => _GameState();

  Game({this.folderName = 'assets/balloons/', this.level = 0}) {
    if (!this.folderName.endsWith('/')) this.folderName += "/";
  }
}

enum ANSWERS { SAME, DIFFERENT, NONE }

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
  Offset handOffset = Offset(9999, 9999);
  Animation handTween;
  final GlobalKey _screen = GlobalKey();
  RenderBox _screenBox;
  final GlobalKey _buttonSame = GlobalKey();
  RenderBox _buttonSameBox;
  final GlobalKey _buttonDifferent = GlobalKey();
  RenderBox _buttonDifferentBox;
  bool runTutorial = true;
  bool nextImage = true;
  double dragDelta = 0;
  static const ROTATE_STEP = 3.0 / 255;
  bool plus = false;
  bool buttonsEnabled = true;
  bool showPrevious = false;
  Duration handDuration = Duration(milliseconds: 600);
  bool SHOW_HAND = true;
  bool SHOW_PREVIOUS = true;

  Future<bool> loadSettings() async {
    Settings.read('tutorial').then((value) {
      SHOW_HAND = value['showHand'];
      SHOW_PREVIOUS = value['showTumb'];
    });

    Settings.read('main').then((value){
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
  }

  @override
  void initState() {

    imagesLoaded = _loadAssets().then((value) => loadSettings());
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

  Future<bool> _loadAssets({int level = 0}) async {
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
        .loadString(widget.folderName + 'answers.txt')
        .then((value) {
      List<String> answers = value.toString().split('\n');
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

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(alignment: Alignment.center, children: [
        FutureBuilder(
            future: imagesLoaded,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  countDown <= 0) {
                if (runTutorial) {
                  showPrevious = !plus;
                }
                if (plus) {
                  print('plus');
                  buttonsEnabled = false;
                  dragDelta = 0;
                  updateTimer();
                } else if (nextImage) {
                  print('next');
                  buttonsEnabled = answers[currentImageNumber] != ANSWERS.NONE;
                  dragDelta = 0;
                  startTime = new DateTime.now();
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    updateBoxes();
                    updateHand();
                    updateTimer();
                  });
                } else {
                  print('handUpdate');
                }
                return Stack(
                  key: _screen,
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AbsorbPointer(
                            absorbing: !buttonsEnabled,
                            child: Stack(
                              children: <Widget>[
                                Transform.rotate(
                                  angle: answers[currentImageNumber] ==
                                          ANSWERS.NONE
                                      ? 0
                                      : dragDelta * ROTATE_STEP,
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffffffff),
                                    ),
                                    child: GestureDetector(
                                      onHorizontalDragStart: (d) {
                                        print('drag start');
                                      },
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
                                          image: plus
                                              ? plusImage
                                              : images[currentImageNumber]),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      showPrevious && currentImageNumber > 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                          width: 120,
                                          height: 120,
                                          image: currentImageNumber > 0
                                              ? images[currentImageNumber - 1]
                                              : plusImage),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Visibility(
                            visible: true,
                            //answers[currentImageNumber] != ANSWERS.NONE,
                            child: Row(children: [
                              Expanded(
                                  key: _buttonDifferent,
                                  flex: 1,
                                  child: AnswerButton(
                                      tapped: () =>
                                          {choiceMade(ANSWERS.DIFFERENT)},
                                      enabled: buttonsEnabled,
                                      image: AssetImage('assets/close.png'),
                                      backgroundColor: Color(0x88880000),
                                      shapeColor: Color(0x99990000),
                                      shape: BoxShape.circle)),
                              Expanded(
                                  key: _buttonSame,
                                  flex: 1,
                                  child: AnswerButton(
                                      tapped: () =>
                                          choiceMade(ANSWERS.SAME),
                                      enabled: buttonsEnabled,
                                      image:
                                          AssetImage('assets/correct.png'),
                                      backgroundColor: Color(0x88008800),
                                      shapeColor: Color(0x99009900),
                                      shape: BoxShape.circle))
                            ]),
                          ),
                        )
                      ],
                    ),
                    AnimatedPositioned(
                      child: Visibility(
                        visible: SHOW_HAND,
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
                      duration: handDuration,
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
                              color: Colors.redAccent,
                            ),
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
      if (answers[currentImageNumber] == ANSWERS.SAME) {
        off = _buttonSameBox.localToGlobal(Offset.zero);
        handOffset = Offset(
            off.dx - 0.455 * 200 + _buttonSameBox.size.width / 2,
            off.dy - 0.1 * 200 + _buttonSameBox.size.height / 2);
      } else if (answers[currentImageNumber] == ANSWERS.DIFFERENT) {
        off = _buttonDifferentBox.localToGlobal(Offset.zero);
        handOffset = Offset(
            off.dx - 0.455 * 200 + _buttonDifferentBox.size.width / 2,
            off.dy - 0.1 * 200 + _buttonDifferentBox.size.height / 2);
      } else {
        handOffset = Offset(
            _screenBox.size.width / 2 - 0.455 * 200, _screenBox.size.height);
      }
    } else {
      handOffset = Offset(
          _screenBox.size.width / 2 - 0.455 * 200, _screenBox.size.height);
    }
    setState(() {
      nextImage = false;
    });
  }

  void updateBoxes() {
    _screenBox = _screen.currentContext.findRenderObject();
    if (_buttonSame != null && _buttonSame.currentContext != null) {
      _buttonSameBox = _buttonSame.currentContext.findRenderObject();
      _buttonDifferentBox = _buttonDifferent.currentContext.findRenderObject();
    }
  }

  void updateTimer() {

    if (timer != null) timer.cancel();

    if (plus) {
      timer = Timer(
          Duration(seconds: 1),
          () => setState(() {
                plus = !plus;
              }));
      return;
    }

    timer = Timer(Duration(seconds: 3), () {
      plus = !plus;
      if (runTutorial)
        choiceMade(answers[currentImageNumber]);
      else
        choiceMade(ANSWERS.NONE);
    });
  }
}
