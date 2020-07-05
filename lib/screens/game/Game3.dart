import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/screens/reward/reward.dart';
import 'package:psycho_app/screens/settings/settings.dart';
import 'dart:math';

import 'AnswerButton.dart';
import 'Statistics.dart';

class Game3 extends StatefulWidget {
  int level = 0;
  var stages;
  var levelName = '';
  var folderName = '';
  var isTutorial = false;

  Game3(
      {this.folderName,
      this.levelName,
      this.stages,
      this.level = 0,
      this.isTutorial});

  @override
  State<StatefulWidget> createState() => _Game3State();
}

enum ANSWERS { SAME, DIFFERENT, NONE }
enum GAMES { MAIN, COLOR, FEEDBACK }

class _Game3State extends State<Game3> with TickerProviderStateMixin {
  bool buttonsEnabled = true;
  int currentImageIndex = 0;
  int currentAnswerIndex = 0;
  double dragDelta = 0;
  final ROTATE_STEP = 3.0 / 255;
  Timer timer;
  List<AssetImage> resetImages = [];
  bool loaded = false;
  int countDown = 3;
  AnimationController controller;
  Animation countDownOpaque;
  _GameLevel _gameLevel;
  final GlobalKey _screen = GlobalKey();
  RenderBox _screenBox;
  final GlobalKey _buttonSame = GlobalKey();
  RenderBox _buttonSameBox;
  final GlobalKey _buttonDifferent = GlobalKey();
  RenderBox _buttonDifferentBox;
  Widget mainWidget;
  DateTime startTime;
  AnimationController differencesController;

  //tutorial
  bool isTutorial = false;
  bool showPrevious = true;
  bool showHand = false;
  bool handAnswers = false;
  bool coloredGame = false;
  Duration handDuration = Duration(milliseconds: 600);
  bool repeatTillRight = false;
  int colorGameLength = 0;
  var colorGameColors = [];
  Statistics statistics = Statistics();
  bool nowPlus = false;
  Offset handOffset = Offset(9999, 9999);
  Animation handTween;
  Size lastSize = null;
  var template = AssetImage('assets/balloon.png');

  Future<bool> loadSettings() async {
    Settings.read('tutorial').then((value) {
      showHand = value['showHand'] && !coloredGame && isTutorial;
      showPrevious = value['showTumb'] && isTutorial;
      repeatTillRight = isTutorial;
      colorGameLength = 0;
      try {
        colorGameLength = int.parse(value['colorsGameLength']);
      } catch (e) {}

      colorGameColors = value['colorsGameColors']
          .toString()
          .split(',')
          .map((e) => Color(int.parse(e)))
          .toList();
    });

    Settings.read('main').then((value) {
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
  }

  Future<bool> _loadAssets({int level = 0}) async {
    _gameLevel =
        _GameLevel(widget.stages, this, plus: AssetImage('assets/plus.png'));
    return true;
  }

  @override
  void initState() {
    isTutorial = widget.isTutorial;
    loadSettings().then((value) => _loadAssets());
    initCountdown();
    super.initState();
  }

  void initCountdown() {
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

  @override
  Widget build(BuildContext context) {
    if (_gameLevel == null || countDown > 0) {
      var w = min(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width) /
          5;
      controller.forward();
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.lightBlue[300].withOpacity(0.5),
                  Colors.lightBlue[500].withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: countDown > 3 ? 0 : 1,
                        child: Container(
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.redAccent, BlendMode.modulate),
                                child: Image(
                                    image: template, width: w, height: w * 2))),
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: countDown > 2 ? 0 : 1,
                        child: Container(
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.blueAccent, BlendMode.modulate),
                                child: Image(
                                    image: template, width: w, height: w * 2))),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: countDown > 1 ? 0 : 1,
                        child: Container(
                            child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.green, BlendMode.modulate),
                                child: Image(
                                    image: template, width: w, height: w * 2))),
                      ),
                    ],
                  )
                ]),
          ));
    }
    if (countDown == 0) {
      updateTimer(nowPlus: false);
      countDown = -1;
    }

    startTime = new DateTime.now();

    if (!coloredGame) updateBoxes();

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          color: Colors.white,
          child: Stack(
            key: _screen,
            children: [
              Column(
                children: [
                  Expanded(flex: 80, child: getGameWidget()),
                  Expanded(
                    flex: 20,
                    child: getAnswerWidget(),
                  )
                ],
              ),
              AnimatedPositioned(
                child: Visibility(
                  visible: showHand,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      width: 200,
                      height: 200,
                      child: Image(
                        image: AssetImage('assets/finger.png'),
                      ),
                    ),
                  ),
                ),
                left: handOffset.dx,
                top: handOffset.dy,
                duration: handDuration,
              )
            ],
          ),
        ));
  }

  getGameWidget() {
    if (MediaQuery.of(context).size != lastSize) {
      lastSize = MediaQuery.of(context).size;
//      _gameLevel.updateBalloons();
    }

    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Transform.rotate(
                angle: _gameLevel.hasAnswer() ? dragDelta * ROTATE_STEP : 0,
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          dragDelta += details.primaryDelta;
                          dragDelta = !_gameLevel.hasAnswer()
                              ? 0
                              : dragDelta > 0
                                  ? min(dragDelta, 100)
                                  : max(dragDelta, -100);
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
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            color: Colors.white,
                            alignment: Alignment.bottomCenter,
                            child: FittedBox(
                              alignment: Alignment.bottomCenter,
                              fit: BoxFit.fill,
                              child: nowPlus
                                  ? Image(
                                      image: _gameLevel.plus,
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.7)
                                  : _gameLevel.getMainWidget(
                                      MediaQuery.of(context).size.width * 0.8,
                                      MediaQuery.of(context).size.height * 0.7),
                            )),
                      )),
                ),
              ),
              Visibility(
                visible: showPrevious && !nowPlus,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _gameLevel.getThumb(
                        MediaQuery.of(context).size.width * 0.15,
                        MediaQuery.of(context).size.height * 0.3),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: showPrevious && _gameLevel.current > 0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _gameLevel.getThumb(
                        MediaQuery.of(context).size.width * 0.4,
                        MediaQuery.of(context).size.height * 0.7),
                  ),
                ),
              ),
              Visibility(
                  visible: showPrevious && _gameLevel.current > 0,
                  child: Image(
                      image: _gameLevel.plus,
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.2)),
              Transform.rotate(
                angle: _gameLevel.hasAnswer() ? dragDelta * ROTATE_STEP : 0,
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: FittedBox(
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          child: nowPlus && !showPrevious
                              ? Image(
                                  image: _gameLevel.plus,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  height:
                                      MediaQuery.of(context).size.height * 0.7)
                              : _gameLevel.getMainWidget(
                                  MediaQuery.of(context).size.width * 0.4,
                                  MediaQuery.of(context).size.height * 0.7),
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  getAnswerWidget() {
    if (coloredGame) {
      var colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
      return Row(
        children: [
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {
                        choiceMade(_gameLevel.color == colors[0]
                            ? ANSWERS.SAME
                            : ANSWERS.DIFFERENT)
                      },
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[0].withOpacity(0.8),
                  shapeColor: colors[0],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {
                        choiceMade(_gameLevel.color == colors[1]
                            ? ANSWERS.SAME
                            : ANSWERS.DIFFERENT)
                      },
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[1].withOpacity(0.8),
                  shapeColor: colors[1],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {
                        choiceMade(_gameLevel.color == colors[2]
                            ? ANSWERS.SAME
                            : ANSWERS.DIFFERENT)
                      },
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[2].withOpacity(0.8),
                  shapeColor: colors[2],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {
                        choiceMade(_gameLevel.color == colors[3]
                            ? ANSWERS.SAME
                            : ANSWERS.DIFFERENT)
                      },
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[3].withOpacity(0.8),
                  shapeColor: colors[3],
                  shape: BoxShape.rectangle)),
        ],
      );
    }
    return getAnswerButtons();
  }

  Widget getAnswerButtons() {
    return Row(children: [
      Expanded(
          key: _buttonDifferent,
          flex: 1,
          child: AnswerButton(
              tapped: () => {choiceMade(ANSWERS.DIFFERENT)},
              enabled: _gameLevel.hasAnswer() && !nowPlus,
              image: AssetImage('assets/close.png'),
              backgroundColor: Color(0x88880000),
              shapeColor: Color(0x99990000),
              shape: BoxShape.circle)),
      Expanded(
          key: _buttonSame,
          flex: 1,
          child: AnswerButton(
              tapped: () => choiceMade(ANSWERS.SAME),
              enabled: _gameLevel.hasAnswer() && !nowPlus,
              image: AssetImage('assets/correct.png'),
              backgroundColor: Color(0x88008800),
              shapeColor: Color(0x99009900),
              shape: BoxShape.circle))
    ]);
  }

  choiceMade(choice) {
    if (choice != ANSWERS.NONE) {
      if (_gameLevel.isCorrectAnswer(choice)) {
        statistics.add(
            DateTime.now().difference(startTime).inMicroseconds, true);
        _gameLevel.resetDifferencesAnimation();
        //      print('correct');
      } else {
        if (repeatTillRight) {
          setState(() {
            updateTimer(nowPlus: false);
            _gameLevel.showDifferences();
          });
          return;
        }
        statistics.add(
            DateTime.now().difference(startTime).inMicroseconds, false);
        _gameLevel.resetDifferencesAnimation();
      }
    } else if (repeatTillRight && _gameLevel.getAnswer() != ANSWERS.NONE) {
      setState(() {
        updateTimer(nowPlus: false);
        _gameLevel.showDifferences();
      });
      return;
    }

    if (_gameLevel.next()) {
//      _gameLevel.showDifferences(show: false);
      setState(() {
        dragDelta = 0;
        if (showPrevious &&
            MediaQuery.of(context).orientation == Orientation.landscape)
          updateTimer(nowPlus: false);
        else
          updateTimer(nowPlus: true);
      });
    } else {
      Settings.saveStats(statistics, DateTime.now().toIso8601String());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Reward(widget.folderName, widget.levelName, statistics)),
      );
    }
  }

  void updateTimer({nowPlus}) {
    this.nowPlus = nowPlus;
    if (timer != null) timer.cancel();

    if (coloredGame) {
      timer = new Timer(Duration(seconds: 3), () {});
      return;
    }

    if (!nowPlus) {
      print('set timer 3 sec');
      timer = new Timer(Duration(seconds: 3), () {
        var ans = dragDelta < -50
            ? ANSWERS.DIFFERENT
            : (dragDelta > 50)
                ? ANSWERS.SAME
                : showHand && handAnswers
                    ? _gameLevel.getAnswer()
                    : ANSWERS.NONE;
        choiceMade(ans);
      });
    } else {
      print('set timer 1 sec');
      timer = new Timer(Duration(seconds: 1), () {
        setState(() {
          updateTimer(nowPlus: false);
        });
//        choiceMade(null);
      });
    }
  }

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    controller.dispose();
    super.dispose();
  }

  void updateHand() {
    if (_buttonSameBox != null) {
      var off;
      if (nowPlus) {
        handOffset = Offset(
            _screenBox.size.width / 2 - 0.455 * 200, _screenBox.size.height);
      } else if (_gameLevel.getAnswer() == ANSWERS.SAME) {
        off = _buttonSameBox.localToGlobal(Offset.zero);
        handOffset = Offset(
            off.dx - 0.455 * 200 + _buttonSameBox.size.width / 2,
            off.dy - 0.1 * 200 + _buttonSameBox.size.height / 2);
      } else if (_gameLevel.getAnswer() == ANSWERS.DIFFERENT) {
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
    setState(() {});
  }

  void updateBoxes() {
    if (_screen.currentContext != null) {
      _screenBox = _screen.currentContext.findRenderObject();
      if (_buttonSame != null && _buttonSame.currentContext != null) {
        _buttonSameBox = _buttonSame.currentContext.findRenderObject();
        _buttonDifferentBox =
            _buttonDifferent.currentContext.findRenderObject();
      }
      updateHand();
    }
  }
}

class _GameLevel {
  List<Image> images = [];
  List<Widget> balloonWidgets = [];
  List<dynamic> stages;
  List<ANSWERS> answers;
  AssetImage plus;
  List<AssetImage> resetImages;
  int current = 0;
  bool levelReturned = true;
  bool coloredGame = false;
  Widget mainWidget;
  Widget colorsWidget;
  Color color;
  _Game3State controller;
  List<Balloon> balloons = [];
  List<Balloon> balloonsThumb = [];
  Robot robot;
  Robot robotThumb;
  var isRobot = false;

  List<Color> defaultColors = [
    Colors.blue,
    Colors.green,
    Colors.redAccent,
    Colors.yellowAccent,
    Colors.deepPurple,
    Colors.orange,
    Colors.grey,
    Colors.brown,
    Colors.purpleAccent[200]
  ];

  _GameLevel(this.stages, this.controller, {this.plus}) {
    isRobot = controller.widget.folderName.toLowerCase().contains('robot');
    if (isRobot) {
      updateBalloons();
      robot = createRobot(stages[current]);
      robotThumb = createRobot(stages[current]);
    } else {
      updateBalloons();
      balloons = createBalloons(stages[current]);
      balloonsThumb = createBalloons(stages[current]);
    }
  }

  updateBalloons() {
    if (isRobot) {
      if (current > 0) robotThumb = robot;
      robot = createRobot(stages[current]);
      return;
    }

    if (current > 0) balloonsThumb = balloons;
    balloons = createBalloons(stages[current]);
  }

  createBalloons(stage, {w = 0, h = 0}) {
    List<Balloon> balloons = [];
    for (var i = 0; i < stage['colors'].length; i++) {
      balloons.add(Balloon(0, 0,
          defaultColors[stage['colors'][i] % defaultColors.length], controller,
          key: GlobalKey()));
    }
    return balloons;
  }

  createRobot(stage) {
    var colors = stage['colors']
        .map((e) => defaultColors[e % defaultColors.length])
        .toList();
    if (current % 2 == 0 || true) {
      print('Will animate');
      Future.delayed(Duration(milliseconds: 1200), (){
        if (robot.key.currentState != null) {
          print('Animation started');
          (robot.key.currentState as _RobotState).simpleAnimation3();
          (robot.key.currentState as _RobotState).startAnimation();
        }
      });
    }
    return Robot(0, 0, colors, controller, key: GlobalKey());
  }

  createMainWidget(num w, num h, balloons, stage, {isRobot = false}) {
    List<Widget> elements = [];
    var stackWidth = 0.0;
    var stackHeight = 0.0;
    isRobot = this.isRobot;
    print(current + 1);

    if (isRobot) {
      stackWidth = w;
      stackHeight = h;
//      elements.add(createRobot(stage) as Widget);
      balloons.w = w;
      balloons.h = h;
      elements.add(balloons);
    } else {
      double xOverlap = 0.05;
      double yOverlap = -0.15;
      double scaleFactor = 0.15;
      double k = min(w / 16, h / 30);

      double imageW = (k * 16) / (2 * (1 + xOverlap) + scaleFactor / 2 + 1);
      double imageH = (k * 30) / (2 * (1 + yOverlap) + scaleFactor / 2 + 1);

      for (int i = 0; i < 9; i++) {
        if (true) {
          balloons[i].w = imageW;
          balloons[i].h = imageH;
          elements.add(Positioned(
              left: (i % 3) * imageW * (1 + xOverlap) +
                  imageW * (scaleFactor / 2 + balloons[i].dx) +
                  imageW * 0.18,
              top: (i ~/ 3) * imageH * (1 + yOverlap) +
                  imageH * (scaleFactor / 2 + balloons[i].dy),
              child: balloons[i]));
        }
      }
      stackWidth =
          (2 * ((1 + xOverlap) + scaleFactor / 2) * imageW + imageW) * 1.1;
      stackHeight = (2 * ((1 + yOverlap) + scaleFactor / 2) * imageH + imageH);
    }

    return Container(
      width: stackWidth,
      height: stackHeight,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: elements,
      ),
    );
  }

  getMainWidget(w, h) {
    if (isRobot) {

      return createMainWidget(w, h, robot, stages[current]);
    }
    return createMainWidget(w, h, balloons, stages[current]);
  }

  bool next() {
    if (current < stages.length - 1) {
      current++;
      updateBalloons();
      levelReturned = true;

      return true;
    }
    return false;
  }

  resetDifferencesAnimation() {
    if (isRobot) {
    } else
      for (var i = 0; i < balloons.length; i++) {
        (balloons[i].key.currentState as _BalloonState).resetAnimation();
        (balloonsThumb[i].key.currentState as _BalloonState).resetAnimation();
      }
  }

  showDifferences({bool show = true}) {
    var difs = getDifferent();
    if (isRobot) {
      if (robot.key.currentState != null)
        (robot.key.currentState as _RobotState).startAnimation();
    } else {
      if (!show) {
        for (var dif in difs[1])
          (balloons[dif].key.currentState as _BalloonState).stopAnimation();
        return;
      }
      for (var dif in difs[0]) {
        if (balloonsThumb[dif].key.currentState != null)
          (balloonsThumb[dif].key.currentState as _BalloonState)
              .startAnimation();
      }
      for (var dif in difs[1]) {
        if (balloons[dif].key.currentState != null)
          (balloons[dif].key.currentState as _BalloonState).startAnimation();
      }
    }
  }

  getAnswer({i = -1}) {
    if (coloredGame) return ANSWERS.SAME;
    if (!levelReturned) return ANSWERS.NONE;
    if (i >= stages.length || current >= stages.length) return ANSWERS.NONE;
    return stages[i > -1 ? i : current]['answer'];
  }

  getNextAnswer() => getAnswer(i: current + 1);

  hasAnswer() {
    return getAnswer() != ANSWERS.NONE;
  }

  isCorrectAnswer(answer) {
    return answer == getAnswer() || getAnswer() == ANSWERS.NONE;
  }

  getThumb(w, h) {
    if (current > 0) {
      if (isRobot)
        return createMainWidget(w, h, robotThumb, stages[current - 1]);
      return createMainWidget(w, h, balloonsThumb, stages[current - 1]);
    }
    return Container();
  }

  getDifferent() {
    if (current == 0) return [[], []];

    var prevBalloons = [];
    var currBalloons = [];

    if (current > 0 && stages[current]['answer'] == ANSWERS.DIFFERENT) {
      var prevColors = {0, 1};
      var currColors = {0, 1};
      for (int i = 0; i < 9; i++) {
        prevColors.add(stages[current - 1]['colors'][i]);
        currColors.add(stages[current]['colors'][i]);
      }
      for (int i = 0; i < 9; i++) {
        if (!currColors.contains(stages[current - 1]['colors'][i]))
          prevBalloons.add(i);
        if (!prevColors.contains(stages[current]['colors'][i]))
          currBalloons.add(i);
      }
    } else {
      for (int i = 0; i < 9; i++) {
        if (stages[current - 1]['colors'][i] > 1) {
          prevBalloons.add(i);
        }
        if (stages[current]['colors'][i] > 1) {
          currBalloons.add(i);
        }
      }
    }
    return [prevBalloons, currBalloons];
  }

  final balloonCoords = [
    [125, 45],
    [200, 66],
    [270, 55],
    [96, 111],
    [186, 170],
    [262, 130],
    [81, 193],
    [170, 254],
    [260, 224]
  ];

  getCoordinates(List indexes) {
    var coords = [];
    for (var index in indexes) {
      coords.add(balloonCoords[index]);
    }
    return coords;
  }
}

class Balloon extends StatefulWidget {
  Color color;
  var template = AssetImage('assets/balloon.png');
  double w, h;
  var scaleFactor = 0.25;
  _Game3State controller;
  GlobalKey key;
  num transformScaleX = 1 + Random().nextDouble() / 5 - 0.15;
  num transformScaleY = 1 + Random().nextDouble() / 5 - 0.15;
  num dx = Random().nextDouble() / 20 - 0.025;
  num dy = Random().nextDouble() / 10 - 0.025;
  num alpha = Random().nextDouble() / 10 - 0.05;
  num beta = Random().nextDouble() / 10 - 0.05;
  num angle = (Random().nextDouble() - 0.5) * pi * 0.095;

  Balloon(this.w, this.h, this.color, this.controller, {this.key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> with TickerProviderStateMixin {
  var showDifferences = false;
  var scaleFactor = 0;
  AnimationController rotationController;
  bool forw = false;
  int counter = 2;

  @override
  void initState() {
    rotationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
        lowerBound: -pi / 8,
        upperBound: pi / 8)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          setState(() {
            if (counter > 0) {
              if (forw)
                rotationController.forward();
              else
                rotationController.reverse();
              forw = !forw;
              counter--;
            } else {
              rotationController.animateTo(0);
              forw = false;
            }
          });
        }
      });
    rotationController.value = 0;

    super.initState();
  }

  void startAnimation() {
    setState(() {
      counter = 2;
      if (!rotationController.isAnimating) rotationController.forward(from: 0);
    });
  }

  void stopAnimation() {
    setState(() {
      counter = 0;
      if (rotationController.isAnimating) rotationController.stop();
    });
  }

  void resetAnimation() {
    setState(() {
      counter = 0;
      if (rotationController.isAnimating) rotationController.reset();
    });
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center,
      turns: Tween(begin: 0.0, end: 0.12).animate(rotationController),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(widget.color, BlendMode.modulate),
        child: Transform.rotate(
          angle: widget.angle,
          child: Transform(
            transform: Matrix4.skew(widget.alpha, widget.beta),
            child: Image(
                image: widget.template,
                width: widget.w *
                    (showDifferences ? 1 + scaleFactor : 1) *
                    widget.transformScaleX,
                height: widget.h *
                    (showDifferences ? 1 + scaleFactor : 1) *
                    widget.transformScaleY,
                fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}

class Robot extends StatefulWidget {
  var colors;

  var sideAntena = AssetImage('assets/Robot/side_antena.png');
  var centerAntena = AssetImage('assets/Robot/center_antena.png');
  var head = AssetImage('assets/Robot/head.png');
  var neck = AssetImage('assets/Robot/neck.png');
  var body = AssetImage('assets/Robot/body.png');
  var body1 = AssetImage('assets/Robot/body_1.png');
  var body2 = AssetImage('assets/Robot/body_2.png');
  var body3 = AssetImage('assets/Robot/body_3.png');
  var body4 = AssetImage('assets/Robot/body_4.png');
  var pelvis = AssetImage('assets/Robot/pelvis.png');
  var pelvis2 = AssetImage('assets/Robot/pelvis_2.png');
  var leg = AssetImage('assets/Robot/leg.png');
  var foot = AssetImage('assets/Robot/foot.png');
  var arm = AssetImage('assets/Robot/arm.png');
  var arm2 = AssetImage('assets/Robot/arm2.png');
  var hand = AssetImage('assets/Robot/hand.png');
  double w, h;
  var scaleFactor = 0.25;
  _Game3State controller;
  GlobalKey key;
  num transformScaleX = 1.0;
  num transformScaleY = 1.0;
  num dx = 0.0;
  num dy = 0.0;
  num alpha = 0.0;
  num beta = 0.0;

  Robot(this.w, this.h, this.colors, this.controller, {this.key})
      : super(key: key) {}

  @override
  State<StatefulWidget> createState() => _RobotState();
}

class _RobotState extends State<Robot> with TickerProviderStateMixin {
  var showDifferences = false;
  var scaleFactor = 0;
  AnimationController rotationController;
  bool forw = false;
  int counter = 0;
  BodyPart leftFoot,
      rightFoot,
      leftLeg,
      rightLeg,
      pelvis2,
      pelvis,
      body,
      body1,
      body2,
      body3,
      body4,
      leftArm,
      leftArm2,
      leftArm3,
      leftHand,
      rightArm,
      rightArm2,
      rightArm3,
      rightHand,
      neck,
      head;

  Animation headAnimation;
  Animation rightArmAnimation;
  Animation rightArm3Animation;
  Animation leftArmAnimation;
  Animation leftArm3Animation;
  bool animationReversable = true;
  bool animationRepeatable = false;
  double vMargin = 0, hMargin = 0;

  @override
  void initState() {
    rotationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("Completed");
          setState(() {
            if (animationReversable)
              rotationController.reverse();
            else if (animationRepeatable)
              rotationController.forward(from: 0);
            resetPartsAnimation();
          });
        } else if (status == AnimationStatus.dismissed) {
          print("Dismissed");
          setState(() {
            if (animationRepeatable)
              rotationController.forward(from: 0);
            else
            rotationController.reset();
          });
        }
      });
//    startAnimation();

    double screenWidth = 720;
    double screenHeight = 1280;
    double centerX = screenWidth / 2 - 64;
    centerX = widget.w * 0.5;
    double offsetY = screenHeight / 11;
    offsetY = widget.h * 0.1;
    var k = widget.w / 576;
    initBody(centerX, offsetY, k);
    super.initState();
  }

  void simpleAnimation() {
    rotationController.duration = Duration(milliseconds: 1000);
    animationRepeatable = false;
    animationReversable = true;
    headAnimation = Tween(begin: head.offset.dy, end: head.offset.dy - head.h/10)
        .animate(rotationController);
    headAnimation.addListener(() {
      setState(() {
        head.offset = Offset(head.offset.dx, headAnimation.value);
      });
    });
    rightArmAnimation =
        Tween(begin: rightArm.angle, end: rightArm.angle - pi / 2)
            .animate(rotationController);
    rightArmAnimation.addListener(() {
      setState(() {
        rightArm.angle = rightArmAnimation.value;
      });
    });
    rightArm3Animation =
        Tween(begin: rightArm3.angle, end: rightArm3.angle - pi / 2)
            .animate(rotationController);
    rightArm3Animation.addListener(() {
      setState(() {
        rightArm3.angle = rightArm3Animation.value;
      });
    });
    leftArmAnimation = Tween(begin: leftArm.angle, end: leftArm.angle + pi / 2)
        .animate(rotationController);
    leftArmAnimation.addListener(() {
      setState(() {
        leftArm.angle = leftArmAnimation.value;
      });
    });
    leftArm3Animation =
        Tween(begin: leftArm3.angle, end: leftArm3.angle + pi / 2)
            .animate(rotationController);
    leftArm3Animation.addListener(() {
      setState(() {
        leftArm3.angle = leftArm3Animation.value;
      });
    });
  }


  void simpleAnimation2() {
    rotationController.duration = Duration(milliseconds: 1000);
    animationRepeatable = true;
    animationReversable = true;
    rightArm.angle = pi*3/16;
    rightArm3.angle = pi*10/16;
    leftArm.angle = pi*5/4;

    leftArm3Animation =
        Tween(begin: 0.0, end: pi / 2)
            .animate(rotationController);
    leftArm3Animation.addListener(() {
      setState(() {
        leftArm3.angle = leftArm3Animation.value;
      });
    });
  }


  void simpleAnimation3() {
    rotationController.duration = Duration(milliseconds: 1100);
    animationRepeatable = true;
    animationReversable = true;

    var animation = Tween(begin: 0.0, end: 1.1).animate(rotationController);
    animation.addListener(() {
      setState(() {
        vMargin = sin(animation.value) * pelvis2.h/2;
        leftLeg.offset = leftLeg.initOffset - Offset(0, sin(animation.value)) * pelvis2.h/3;
        rightLeg.offset = rightLeg.initOffset - Offset(0, sin(animation.value)) * pelvis2.h/3;
        leftFoot.offset = leftFoot.initOffset - Offset(0, sin(animation.value)) * pelvis2.h/3;
        rightFoot.offset = rightFoot.initOffset - Offset(0, sin(animation.value)) * pelvis2.h/3;
      });
    });

  }

  void startAnimation() {
    setState(() {
      if (!rotationController.isAnimating) rotationController.forward(from: 0);
    });
  }

  void stopAnimation() {
    setState(() {
      if (rotationController.isAnimating) rotationController.stop();
      resetPartsAnimation();
    });
  }

  void resetPartsAnimation() {}

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  void initBody(double centerX, double offsetY, double k) {
    leftFoot = BodyPart(widget.foot, 21.0 * k, 57.0 * k,
        offset: Offset(centerX - 115 / 2 * k, offsetY + 360 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[11],
        controller: rotationController,
        key: GlobalKey());
    rightFoot = BodyPart(widget.foot, 21.0 * k, 57.0 * k,
        offset: Offset(centerX + (115 / 2 - 50 / 2) * k, offsetY + 360 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[11],
        controller: rotationController,
        key: GlobalKey());
    leftLeg = BodyPart(widget.leg, 50.0 * k, 74.0 * k,
        offset: leftFoot.offset +
            Offset(leftFoot.w / 2 - 25 * k, leftFoot.h / 2 - 74 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[10],
        controller: rotationController,
        key: GlobalKey());
    rightLeg = BodyPart(widget.leg, 50.0 * k, 74.0 * k,
        offset: rightFoot.offset +
            Offset(rightFoot.w / 2 - 25 * k, rightFoot.h / 2 - 74 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[10],
        controller: rotationController,
        key: GlobalKey());
    pelvis2 = BodyPart(widget.pelvis2, 115.0 * k, 50.0 * k,
        offset: Offset(centerX - 115 / 2 * k, leftLeg.offset.dy - 50 / 1.5 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[9],
        controller: rotationController,
        key: GlobalKey());
    pelvis = BodyPart(widget.pelvis, 84.0 * k, 37.0 * k,
        offset: pelvis2.offset +
            Offset(pelvis2.w / 2 - 84 / 2 * k, -pelvis2.h / 2 - 37 * k / 6),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[8],
        controller: rotationController,
        key: GlobalKey());
    body = BodyPart(widget.body, 132.0 * k, 157.0 * k,
        offset:
            pelvis.offset + Offset(pelvis.w / 2 - 132.0 / 2 * k, -157.0 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[2],
        controller: rotationController,
        key: GlobalKey());
    body1 = BodyPart(widget.body1, 97.0 * k, 45.0 * k,
        offset: body.offset + Offset(body.w / 2 - 97 / 2 * k, 15 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[4],
        controller: rotationController,
        key: GlobalKey());
    body2 = BodyPart(widget.body2, 49 * k, 50 * k,
        offset: body.offset + Offset(body.w / 3 - 49 / 2 * k, body.h * 3 / 7),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[5],
        controller: rotationController,
        key: GlobalKey());
    body3 = BodyPart(widget.body3, 25 * k, 62 * k,
        offset:
            body.offset + Offset(body.w * 3 / 4 - 25 / 2 * k, body.h * 3 / 7),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[6],
        controller: rotationController,
        key: GlobalKey());
    body4 = BodyPart(widget.body4, 97 * k, 16 * k,
        offset: body.offset + Offset(body.w / 2 - 97 / 2 * k, body.h * 0.85),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[7],
        controller: rotationController,
        key: GlobalKey());
    neck = BodyPart(widget.neck, 35.0 * k, 25.0 * k,
        offset: body.offset + Offset(body.w / 2 - 35 / 2 * k, -20 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[1],
        controller: rotationController,
        key: GlobalKey());
    head = BodyPart(widget.head, 96.0 * k, 85.0 * k,
        offset: neck.offset +
            Offset(neck.w / 2 - 96 / 2 * k, -neck.h / 2 - 85 * 3 / 4 * k),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[0],
        controller: rotationController,
        key: GlobalKey());
    leftArm = BodyPart(widget.arm, 96.0 * k, 35.0 * k,
        offset: body.offset + Offset(body.w / 8, body.h / 8),
        origin: Offset(0, 0),
        angle: pi,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
    rightArm = BodyPart(widget.arm, 96.0 * k, 35.0 * k,
        offset: body.offset + Offset(body.w - body.w / 8, body.h / 8),
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
    leftArm2 = BodyPart(widget.arm2, 40.0 * k, 40.0 * k,
        offset: leftArm.offset + Offset(leftArm.w, 0),
        origin: Offset(0, 0),
        angle: leftArm.angle,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
    rightArm2 = BodyPart(widget.arm2, 40.0 * k, 40.0 * k,
        offset: rightArm.offset +
            Offset(rightArm.w, 0),
        origin: Offset(0, 0),
        angle: rightArm.angle,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey(),
        rotationAlignment: Alignment.center);
    leftArm3 = BodyPart(widget.arm, 96.0 * k, 35.0 * k,
        offset: leftArm2.offset,
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
    rightArm3 = BodyPart(widget.arm, 96.0 * k, 35.0 * k,
        offset: rightArm2.offset,
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
    leftHand = BodyPart(widget.hand, 35.0 * k, 35.0 * k,
        offset: leftArm3.offset,
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[2],
        controller: rotationController,
        key: GlobalKey());
    rightHand = BodyPart(widget.hand, 35.0 * k, 35.0 * k,
        offset: rightArm3.offset,
        origin: Offset(0, 0),
        angle: 0,
        color: widget.colors[3],
        controller: rotationController,
        key: GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double centerX = screenWidth / 2 - 64;
    centerX = widget.w * 0.5;
    double offsetY = screenHeight / 11;
    offsetY = widget.h * 0.1;
    var k = widget.w / 576;
    return Container(
      margin: EdgeInsets.only(left: hMargin, top: vMargin),
      child: CustomPaint(painter: _RobotPainter(this)),
    );
  }
}

class _RobotPainter extends CustomPainter {
  _RobotState _robotState;
  AnimationController controller;

  _RobotPainter(this._robotState) {
    controller = _robotState.rotationController;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = new Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    paint.color = _robotState.neck.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTRB(
                _robotState.neck.offset.dx,
                _robotState.head.offset.dy + 2,
                _robotState.neck.offset.dx + _robotState.neck.w / 4,
                _robotState.neck.h + _robotState.neck.offset.dx),
            _robotState.neck.w / 15,
            _robotState.neck.w / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTRB(
                _robotState.neck.offset.dx + _robotState.neck.w / 8 * 3,
                _robotState.head.offset.dy + 2,
                _robotState.neck.offset.dx + _robotState.neck.w * 5 / 8,
                _robotState.neck.h + _robotState.neck.offset.dx),
            _robotState.neck.w / 15,
            _robotState.neck.w / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTRB(
                _robotState.neck.offset.dx + _robotState.neck.w / 8 * 6,
                _robotState.head.offset.dy + 2,
                _robotState.neck.offset.dx + _robotState.neck.w,
                _robotState.neck.h + _robotState.neck.offset.dx),
            _robotState.neck.w / 15,
            _robotState.neck.w / 15),
        paint);

    paint.color = _robotState.head.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.head.offset.dx,
                _robotState.head.offset.dy,
                _robotState.head.w,
                _robotState.head.h),
            _robotState.head.w / 3,
            _robotState.head.w / 3),
        paint);

    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    var h = _robotState.head;
    canvas.drawOval(Rect.fromLTWH(h.offset.dx + h.w/5, h.offset.dy + h.h/3, h.w/8, h.h/4), paint);
    canvas.drawOval(Rect.fromLTWH(h.offset.dx + h.w*4/5 - h.w/9, h.offset.dy + h.h/3, h.w/8, h.h/4), paint);
    paint.style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(h.offset.dx + h.w/5 + h.w/24, h.offset.dy + h.h/3 + h.h/10, h.w/10, h.h/10), paint);
    canvas.drawOval(Rect.fromLTWH(h.offset.dx + h.w*4/5 - h.w/9 + h.w/24, h.offset.dy + h.h/3 + h.h/10, h.w/10, h.h/10), paint);

    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromLTWH(h.offset.dx + h.w/4, h.offset.dy + h.h*11/16, h.w/2, h.h/6), 0, pi, false, paint);
    paint.style = PaintingStyle.fill;



    paint.color = _robotState.pelvis.color;
    Path pelvisPath = Path();
    pelvisPath.moveTo(
        _robotState.pelvis.offset.dx, _robotState.pelvis.offset.dy);
    pelvisPath.lineTo(_robotState.pelvis.offset.dx + _robotState.pelvis.w,
        _robotState.pelvis.offset.dy);
    pelvisPath.lineTo(
        _robotState.pelvis.offset.dx + _robotState.pelvis.w * 0.75,
        _robotState.pelvis.offset.dy + _robotState.pelvis.h);
    pelvisPath.lineTo(
        _robotState.pelvis.offset.dx + _robotState.pelvis.w * 0.25,
        _robotState.pelvis.offset.dy + _robotState.pelvis.h);
    pelvisPath.lineTo(
        _robotState.pelvis.offset.dx, _robotState.pelvis.offset.dy);
    canvas.drawPath(pelvisPath, paint);

    paint.color = _robotState.pelvis2.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.pelvis2.offset.dx,
                _robotState.pelvis2.offset.dy,
                _robotState.pelvis2.w,
                _robotState.pelvis2.h / 2),
            _robotState.pelvis2.w / 15,
            _robotState.pelvis2.w / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.pelvis2.offset.dx + _robotState.pelvis2.w / 24,
                _robotState.pelvis2.offset.dy + _robotState.pelvis2.h / 2.5,
                _robotState.pelvis2.w / 6,
                _robotState.pelvis2.h),
            _robotState.pelvis2.w / 15,
            _robotState.pelvis2.w / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.pelvis2.offset.dx +
                    _robotState.pelvis2.w -
                    _robotState.pelvis2.w / 24 -
                    _robotState.pelvis2.w / 5,
                _robotState.pelvis2.offset.dy + _robotState.pelvis2.h / 2.5,
                _robotState.pelvis2.w / 6,
                _robotState.pelvis2.h),
            _robotState.pelvis2.w / 15,
            _robotState.pelvis2.w / 15),
        paint);

    paint.color = _robotState.leftLeg.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.leftLeg.offset.dx,
                _robotState.leftLeg.offset.dy,
                _robotState.leftLeg.w,
                _robotState.leftLeg.h),
            _robotState.leftLeg.h / 10,
            _robotState.leftLeg.h / 10),
        paint);

    paint.color = _robotState.rightLeg.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.rightLeg.offset.dx,
                _robotState.rightLeg.offset.dy,
                _robotState.rightLeg.w,
                _robotState.rightLeg.h),
            _robotState.rightLeg.h / 10,
            _robotState.rightLeg.h / 10),
        paint);

    paint.color = _robotState.leftFoot.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.leftFoot.offset.dx,
                _robotState.leftFoot.offset.dy,
                _robotState.leftFoot.w,
                _robotState.leftFoot.h),
            _robotState.leftFoot.h / 6,
            _robotState.leftFoot.h / 6),
        paint);

    paint.color = _robotState.rightFoot.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.rightFoot.offset.dx,
                _robotState.rightFoot.offset.dy,
                _robotState.rightFoot.w,
                _robotState.rightFoot.h),
            _robotState.rightFoot.h / 6,
            _robotState.rightFoot.h / 6),
        paint);

    paint.color = _robotState.body.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.body.offset.dx,
                _robotState.body.offset.dy,
                _robotState.body.w,
                _robotState.body.h),
            _robotState.body.w / 15,
            _robotState.body.w / 15),
        paint);

    paint.color = _robotState.body1.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.body1.offset.dx,
                _robotState.body1.offset.dy,
                _robotState.body1.w,
                _robotState.body1.h),
            _robotState.body1.w / 15,
            _robotState.body1.w / 15),
        paint);

    paint.color = _robotState.body4.color;
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(
                _robotState.body4.offset.dx,
                _robotState.body4.offset.dy,
                _robotState.body4.w,
                _robotState.body4.h),
            _robotState.body4.w / 15,
            _robotState.body4.w / 15),
        paint);

    paint.color = _robotState.body2.color;
    Path body2Path = Path();
    body2Path.moveTo(_robotState.body2.offset.dx + _robotState.body2.w * 0.3,
        _robotState.body2.offset.dy);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w * 0.7,
        _robotState.body2.offset.dy);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w,
        _robotState.body2.offset.dy + _robotState.body2.h * 0.3);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w,
        _robotState.body2.offset.dy + _robotState.body2.h * 0.7);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w * 0.7,
        _robotState.body2.offset.dy + _robotState.body2.h);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w * 0.3,
        _robotState.body2.offset.dy + _robotState.body2.h);
    body2Path.lineTo(_robotState.body2.offset.dx,
        _robotState.body2.offset.dy + _robotState.body2.h * 0.7);
    body2Path.lineTo(_robotState.body2.offset.dx,
        _robotState.body2.offset.dy + _robotState.body2.h * 0.3);
    body2Path.lineTo(_robotState.body2.offset.dx + _robotState.body2.w * 0.3,
        _robotState.body2.offset.dy);
    canvas.drawPath(body2Path, paint);

    paint.color = _robotState.body3.color;
    canvas.translate(_robotState.body3.offset.dx, _robotState.body3.offset.dy);
    canvas.rotate(pi / 4);
    var sqW = _robotState.body3.w / sqrt(2);
    canvas.drawRRect(
        RRect.fromRectXY(Rect.fromLTWH(0, 0, sqW, sqW), sqW / 15, sqW / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(sqW / 2, sqW / 2.4, sqW, sqW), sqW / 15, sqW / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(
            Rect.fromLTWH(sqW, sqW / 1.2, sqW, sqW), sqW / 15, sqW / 15),
        paint);
    canvas.drawRRect(
        RRect.fromRectXY(Rect.fromLTWH(sqW * 3 / 2, sqW * 3 / 2.4, sqW, sqW),
            sqW / 15, sqW / 15),
        paint);
    canvas.rotate(-pi / 4);
    canvas.translate(
        -_robotState.body3.offset.dx, -_robotState.body3.offset.dy);

    paint.color = _robotState.rightArm.color;
    canvas.translate(
        _robotState.rightArm.offset.dx, _robotState.rightArm.offset.dy);
    canvas.rotate(_robotState.rightArm.angle);
    for (int i = 0; i < 5; i++)
      canvas.drawOval(
          Rect.fromLTWH(
              _robotState.rightArm.w / 5 * i,
              -_robotState.rightArm.h / 2,
              _robotState.rightArm.w / 4.5,
              _robotState.rightArm.h),
          paint);
    canvas.translate(
        -_robotState.rightArm.offset.dx, -_robotState.rightArm.offset.dy);

    paint.color = _robotState.rightArm3.color;
    canvas.translate(
        _robotState.rightArm3.offset.dx, _robotState.rightArm3.offset.dy);
    canvas.rotate(_robotState.rightArm3.angle);
    for (int i = 0; i < 5; i++)
      canvas.drawOval(
          Rect.fromLTWH(
              _robotState.rightArm3.w / 5 * i,
              -_robotState.rightArm3.h / 2,
              _robotState.rightArm3.w / 4.5,
              _robotState.rightArm3.h),
          paint);

    canvas.translate(
        -_robotState.rightArm3.offset.dx, -_robotState.rightArm3.offset.dy);


    paint.color = _robotState.rightArm2.color;
    canvas.translate(
        _robotState.rightArm.offset.dx - _robotState.rightArm2.w / 2,
        _robotState.rightArm.offset.dy - _robotState.rightArm2.h / 2);
    canvas.rotate(_robotState.rightArm2.angle);
    var offset = _robotState.rightArm2.offset - _robotState.rightArm.offset;
    canvas.drawOval(
        Rect.fromLTWH(offset.dx, offset.dy, _robotState.rightArm2.w,
            _robotState.rightArm2.h),
        paint);

/*
    canvas.translate(
        -_robotState.rightArm.offset.dx + _robotState.rightArm2.w / 2,
        -_robotState.rightArm.offset.dy + _robotState.rightArm2.h / 2);
*/

    paint.color = Colors.purpleAccent;
/*    canvas.translate(_robotState.rightHand.offset.dx, _robotState.rightHand.offset.dy);*/
    canvas.translate(offset.dx +_robotState.rightArm3.w, 0);
    canvas.rotate(_robotState.rightHand.angle);
    canvas.drawOval(
        Rect.fromLTWH(0,0, _robotState.rightHand.w,
            _robotState.rightHand.h),
        paint);
    canvas.rotate(-_robotState.rightHand.angle);
    canvas.translate(-offset.dx -_robotState.rightArm3.w, 0);
    canvas.translate(
        -_robotState.rightArm.offset.dx + _robotState.rightArm2.w / 2,
        -_robotState.rightArm.offset.dy + _robotState.rightArm2.h / 2);
    canvas.translate(
        _robotState.rightArm2.offset.dx, _robotState.rightArm2.offset.dy);
    canvas.rotate(-_robotState.rightArm2.angle);
    canvas.translate(
        -_robotState.rightArm2.offset.dx, -_robotState.rightArm2.offset.dy);
    canvas.translate(
        _robotState.rightArm3.offset.dx, _robotState.rightArm3.offset.dy);
    canvas.rotate(-_robotState.rightArm3.angle);
    canvas.translate(
        -_robotState.rightArm3.offset.dx, -_robotState.rightArm3.offset.dy);
    canvas.translate(
        _robotState.rightArm.offset.dx, _robotState.rightArm.offset.dy);
    canvas.rotate(-_robotState.rightArm.angle);
    canvas.translate(
        -_robotState.rightArm.offset.dx, -_robotState.rightArm.offset.dy);


    paint.color = _robotState.leftArm.color;
    canvas.translate(
        _robotState.leftArm.offset.dx, _robotState.leftArm.offset.dy);
    canvas.rotate(_robotState.leftArm.angle);
    for (int i = 0; i < 5; i++)
      canvas.drawOval(
          Rect.fromLTWH(
              _robotState.leftArm.w / 5 * i,
              -_robotState.leftArm.h / 2,
              _robotState.leftArm.w / 4.5,
              _robotState.leftArm.h),
          paint);
    canvas.translate(
        -_robotState.leftArm.offset.dx, -_robotState.leftArm.offset.dy);

    paint.color = _robotState.leftArm3.color;
    canvas.translate(
        _robotState.leftArm3.offset.dx, _robotState.leftArm3.offset.dy);
    canvas.rotate(_robotState.leftArm3.angle);
    for (int i = 0; i < 5; i++)
      canvas.drawOval(
          Rect.fromLTWH(
              _robotState.leftArm3.w / 5 * i,
              -_robotState.leftArm3.h / 2,
              _robotState.leftArm3.w / 4.5,
              _robotState.leftArm3.h),
          paint);
    canvas.translate(
        -_robotState.leftArm3.offset.dx, -_robotState.leftArm3.offset.dy);

    paint.color = _robotState.leftArm2.color;
    canvas.translate(_robotState.leftArm.offset.dx + _robotState.leftArm2.w / 2,
        _robotState.leftArm.offset.dy + _robotState.leftArm2.h / 2);
    canvas.rotate(_robotState.leftArm2.angle);
    offset =  _robotState.leftArm.offset - _robotState.leftArm2.offset;
    canvas.drawOval(
        Rect.fromLTWH(offset.dx, offset.dy, _robotState.leftArm2.w,
            _robotState.leftArm2.h),
        paint);
/*
    canvas.translate(-_robotState.leftArm.offset.dx - _robotState.leftArm2.w / 2,
        -_robotState.leftArm.offset.dy - _robotState.leftArm2.h / 2);
*/

    paint.color = Colors.redAccent;
//    canvas.translate(_robotState.leftHand.offset.dx, _robotState.leftHand.offset.dy);
    canvas.translate(offset.dx -_robotState.leftArm3.w, 0);
    canvas.rotate(_robotState.leftHand.angle);

    canvas.drawOval(
        Rect.fromLTWH(0, 0, _robotState.leftHand.w,
            _robotState.leftHand.h),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BodyPart extends StatefulWidget {
  double w = 0;
  double h = 0;
  Color color;
  AssetImage image;
  Offset origin;
  Offset offset;
  Offset initOffset;
  double angle = 0;
  var controller;
  double animateFrom = 0.0;
  double animateTo = 0.0;
  GlobalKey<_BodyPartState> key;
  Alignment rotationAlignment = Alignment.centerLeft;

  BodyPart(this.image, this.w, this.h,
      {this.color,
      this.origin,
      this.offset,
      this.angle,
      this.controller,
      this.key,
      this.rotationAlignment = Alignment.centerLeft})
      : super(key: key) {
    initOffset = offset;
  }

  @override
  State<StatefulWidget> createState() => _BodyPartState();
}

class _BodyPartState extends State<BodyPart> with TickerProviderStateMixin {
  _BodyPartState();

  AnimationController _controller;

  @override
  void initState() {
    _controller = widget.controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetOffset() {
    setState(() {
      widget.offset = widget.initOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: _controller.duration,
        left: widget.offset.dx,
        top: widget.offset.dy,
        child: Container(
          alignment: Alignment.centerLeft,
          child: RotationTransition(
            alignment: widget.rotationAlignment,
            turns: Tween(begin: widget.animateFrom, end: widget.animateTo)
                .animate(_controller),
            child: Transform.rotate(
              angle: widget.angle,
              child: Image(
                  image: AssetImage(widget.image.assetName),
                  width: widget.w,
                  height: widget.h,
                  color: widget.color,
                  fit: BoxFit.fill),
            ),
          ),
        ));
  }
}
