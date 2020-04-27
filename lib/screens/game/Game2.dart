import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';
import 'dart:math';

import 'AnswerButton.dart';

class Game2 extends StatefulWidget {
  String folderName;
  int level = 0;

  Game2({this.folderName = 'assets/balloons/', this.level = 0});

  @override
  State<StatefulWidget> createState() => _Game2State();
}

enum ANSWERS { SAME, DIFFERENT, NONE }
enum GAMES { MAIN, COLOR, FEEDBACK }

class _Game2State extends State<Game2> with TickerProviderStateMixin {
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

  //tutorial
  bool isTutorial = false;
  bool showPrevious = true;
  bool showHand = true;
  bool coloredGame = true;
  Duration handDuration = Duration(milliseconds: 600);
  bool repeatTillRight = true;
  int colorGameLength = 0;
  var colorGameColors = [];
  Widget previousWidget;
  Offset handOffset = Offset(9999, 9999);
  Animation handTween;

  Future<bool> loadSettings() async {
    Settings.read('tutorial').then((value) {
      showHand = value['showHand'] && !coloredGame;
      showPrevious = value['showTumb'];
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
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    List<AssetImage> images = [];
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
    List<ANSWERS> gameAnswers = [];
    await DefaultAssetBundle.of(context)
        .loadString(widget.folderName + 'answers.txt')
        .then((value) {
      List<String> answers = value.toString().split('\n');
      for (var answer in answers) {
        switch (answer.trim()) {
          case ";":
            break;
          case "s":
            gameAnswers.add(ANSWERS.SAME);
            break;
          case "d":
            gameAnswers.add(ANSWERS.DIFFERENT);
            break;
          case "f":
            gameAnswers.add(ANSWERS.NONE);
            gameAnswers.add(ANSWERS.DIFFERENT);
            break;
          default:
            break;
        }
      }
    });
    var answers = await DefaultAssetBundle.of(context).loadString(widget.folderName + 'answers.txt');
    _gameLevel = _GameLevel(answers);
//    _gameLevel = _GameLevel(images, gameAnswers,
//        plus: AssetImage('assets/plus.png'),
//        resetImages: <AssetImage>[
//          AssetImage('assets/balloons/BMTblue.JPG'),
//          AssetImage('assets/balloons/BMTgreen.JPG')
//        ]);
    mainWidget = _gameLevel.next();
    updateTimer();
    return true;
  }

  @override
  void initState() {
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

    if (_gameLevel == null) {
      controller.forward();
      return Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FittedBox(
                alignment: Alignment.center,
                fit: BoxFit.contain,
                child: Text(
                  countDown.toString(),
                  style: TextStyle(color: Colors.redAccent),
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
          ));
    }
    if (!coloredGame)
      updateBoxes();
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          key: _screen,
          children: [Column(
            children: [
              Expanded(
                flex: 80,
                child: getGameWidget(),
              ),
              Expanded(
                flex: 20,
                child: getAnswerWidget(),
              )
            ],
          ),
            AnimatedPositioned(
              child: Visibility(
                visible: showHand,
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
            )],
        ));
  }

  getGameWidget() {
    return Stack(
      children: <Widget>[
        Transform.rotate(
          angle: _gameLevel.hasAnswer() ? dragDelta * ROTATE_STEP : 0,
          alignment: Alignment.bottomCenter,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
            ),
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
              child: mainWidget,
            ),
          ),
        ),
        Visibility(
          visible: showPrevious && currentImageIndex > 0,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 120, height: 120, child: _gameLevel.getThumb()),
            ),
          ),
        ),
      ],
    );
  }

  getAnswerWidget() {
    if (coloredGame) {
      var colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
      return Row(
        children: [
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {choiceMade( _gameLevel.color == colors[0] ? ANSWERS.SAME : ANSWERS.DIFFERENT) },
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[0].withOpacity(0.8),
                  shapeColor: colors[0],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {choiceMade(_gameLevel.color == colors[1] ? ANSWERS.SAME : ANSWERS.DIFFERENT)},
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[1].withOpacity(0.8),
                  shapeColor: colors[1],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {choiceMade(_gameLevel.color == colors[2] ? ANSWERS.SAME : ANSWERS.DIFFERENT)},
                  enabled: _gameLevel.hasAnswer(),
                  backgroundColor: colors[2].withOpacity(0.8),
                  shapeColor: colors[2],
                  shape: BoxShape.rectangle)),
          Expanded(
              flex: 1,
              child: AnswerButton(
                  tapped: () => {choiceMade(_gameLevel.color == colors[3] ? ANSWERS.SAME : ANSWERS.DIFFERENT)},
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
              enabled: _gameLevel.hasAnswer(),
              image: AssetImage('assets/close.png'),
              backgroundColor: Color(0x88880000),
              shapeColor: Color(0x99990000),
              shape: BoxShape.circle)),
      Expanded(
          key: _buttonSame,
          flex: 1,
          child: AnswerButton(
              tapped: () => choiceMade(ANSWERS.SAME),
              enabled: _gameLevel.hasAnswer(),
              image: AssetImage('assets/correct.png'),
              backgroundColor: Color(0x88008800),
              shapeColor: Color(0x99009900),
              shape: BoxShape.circle))
    ]);
  }

  choiceMade(choice) {
    if (_gameLevel.isCorrectAnswer(choice)) {
      setState(() {
        mainWidget = _gameLevel.next();
        updateTimer();
      });
    } else {
      if (repeatTillRight) {
        updateTimer();
      } else {
        setState(() {
          mainWidget = _gameLevel.next();
          updateTimer();
        });
      }
    }
  }

  void updateTimer() {
    if (timer != null) timer.cancel();

    if (coloredGame) {
      timer = new Timer(
          Duration(seconds: 3), () {}
      );
      return;
    }

    if (_gameLevel.levelReturned) {
      timer = new Timer(Duration(seconds: 3), () {
        var ans = dragDelta < -50 ? ANSWERS.DIFFERENT : (dragDelta > 50) ? ANSWERS.SAME : showHand ? _gameLevel.getAnswer() : ANSWERS.NONE;
          choiceMade(ans);
      });
    } else {
      timer = new Timer(Duration(seconds: 1), () {
        choiceMade(null);
      });
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }



  void updateHand() {
    if (_buttonSameBox != null) {
      var off;
      if (_gameLevel.getAnswer() == ANSWERS.SAME) {
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
    setState(() {
    });
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
  List<AssetImage> images;
  List<List<dynamic>> stages;
  List<ANSWERS> answers;
  AssetImage plus;
  List<AssetImage> resetImages;
  int current = -1;
  bool levelReturned = false;
  bool coloredGame = true;
  Widget colorsWidget;
  Color color;
  List<Color> defaultColors = [Colors.redAccent, Colors.blue, Colors.greenAccent, Colors.greenAccent, Colors.deepPurple];

  _GameLevel(String stagesString){
    stages = json.decode(stagesString);
    for (var stage in stages) {
      for (int i = 0; i < stage.length - 1; i++)
        stage[i] = defaultColors[i % defaultColors.length];
      switch (stage[stage.length - 1]) {
        case "s":
          stage[stage.length - 1] = (ANSWERS.SAME);
          break;
        case "d":
          stage[stage.length - 1] = (ANSWERS.DIFFERENT);
          break;
        case "f":
          stage[stage.length - 1]  = (ANSWERS.NONE);
          break;
        default:
          break;
      }
//      stages[stage.length - 1] = stages[stage.length - 1];
    }
  }

  Future<Image> generateBalloonsImage(List<Color> colors) async {
    ui.PictureRecorder recorder = new ui.PictureRecorder();
    Canvas c = new Canvas(recorder);
    Paint paint = Paint();
    final ByteData data = await rootBundle.load('assets/balloons_template.png');
    var image = await loadImage(new Uint8List.view(data.buffer));
    fillBalloons(c, colors);
    c.drawImage(image, Offset(0,0), paint); // etc
    ui.Picture p = recorder.endRecording();
    image = await p.toImage(image.width, image.height);
    return Image.memory(Uint8List.sublistView(await image.toByteData(format: ui.ImageByteFormat.png)));
  }

  fillBalloons(Canvas c, colors) {
    Paint paint = Paint();
    paint.color = colors[0];
    c.drawRect(Rect.fromLTRB(100, 20, 151, 81), paint);
    c.drawRect(Rect.fromLTRB(122, 90, 123, 70), paint);
    c.drawRect(Rect.fromLTRB(110, 78, 151, 40), paint);
    c.drawRect(Rect.fromLTRB(140, 80, 123, 90), paint);
    paint.color = colors[1];
    c.drawRect(Rect.fromLTRB(160, 30, 220, 120), paint);
    c.drawRect(Rect.fromLTRB(220, 90, 230, 30), paint);
    paint.color = colors[2];
    c.drawRect(Rect.fromLTRB(230, 20, 305, 90), paint);
    paint.color = colors[3];
    c.drawRect(Rect.fromLTRB(57, 80, 125, 156), paint);
    c.drawRect(Rect.fromLTRB(125, 156, 138, 95), paint);
    paint.color = colors[4];
    c.drawRect(Rect.fromLTRB(158, 133, 217, 217), paint);
    paint.color = colors[5];
    c.drawRect(Rect.fromLTRB(220, 100, 300, 180), paint);
    paint.color = colors[6];
    c.drawRect(Rect.fromLTRB(40, 155, 140, 250), paint);
    paint.color = colors[7];
    c.drawRect(Rect.fromLTRB(140, 230, 220, 290), paint);
    paint.color = colors[8];
    c.drawRect(Rect.fromLTRB(220, 190, 300, 275), paint);
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<Image> completer = new Completer();
    return decodeImageFromList(img);
  }

  Widget next() {
    if (coloredGame) {
      var colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
      var size = Size(500, 300);
      color = colors[Random().nextInt(colors.length-1)];
      var left = min((Random().nextDouble()) * 0.7 + 0.1, 0.8);
      var top = min(Random().nextDouble() * 0.7 + 0.1, 0.8);
      var width = max(0.2, min( Random().nextDouble() * (1 - left), 0.5));
      var height = min((0.8 + Random().nextDouble()*0.4) * width, (1 - top) * 0.9);
      print(left);
      return LayoutBuilder(
        builder: (context, constrains) {
          return Stack(
            children: [
              AnimatedPositioned(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 200,
                    height: 200,
                    color: color,
                  ),
                ),
                left: left * constrains.maxWidth,
                width: width * constrains.maxWidth,
                top: top * constrains.maxHeight,
                height: height * constrains.maxHeight,
                duration: Duration(milliseconds: 200),
              )
            ],
          );
        }
      );
      return getMainWidget(null);
    }
    
    if (current < images.length) {
      if (levelReturned && getNextAnswer() != ANSWERS.NONE) {
        levelReturned = false;
        return getPlus();
      }
      current++;
      levelReturned = true;
      if (getAnswer() == ANSWERS.NONE) {
        return getMainWidget(resetImages[Random().nextInt(1)]);
      }
      var img = generateBalloonsImage(stages[current]);
      return getMainWidget(img);
    }
  }

  getAnswer({i = -1}) {
    if (coloredGame)
      return ANSWERS.SAME;
    if (!levelReturned) return ANSWERS.NONE;
    return answers[i > -1 ? i < images.length ? i : ANSWERS.NONE : current];
  }

  getNextAnswer() => getAnswer(i: current + 1);


  hasAnswer() {
    return getAnswer() != ANSWERS.NONE;
  }

  isCorrectAnswer(answer) {
    return answer == getAnswer() || getAnswer() == ANSWERS.NONE;
  }

  getMainWidget(image) {

    if (coloredGame) {
      return colorsWidget;
    }
    return Image(image: image);
  }

  getPlus() {
    return Image(image: plus);
  }

  getThumb() {
    if (current > 0) {
      return Image(
        width: 120,
        height: 120,
        image: images[current - 1],
      );
    }
    return Container();
  }
}
//
//class _ColorGameLevel extends _GameLevel{
//  _ColorGameLevel() {
//    super()
//  };
//}
