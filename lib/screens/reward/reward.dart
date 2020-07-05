import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';
import 'dart:math';

class Reward extends StatefulWidget {

  Statistics statistics;
  bool showStats = false;
  var rating = 0;
  var levelName = '';
  var folderName = '';

  @override
  _RewardState createState() => _RewardState();

  Reward(this.folderName, this.levelName, this.statistics) {}

}

class _RewardState extends State<Reward> {

  num rating;

  @override
  void initState() {
    super.initState();
    rating = 0.0;
    if (widget.statistics.answers.length > 0) {
    for (var a in widget.statistics.answers)
    if (a.isCorrect)
    rating++;
    rating /= widget.statistics.answers.length;
    }
    Settings.read("main").then((val) {
      var stats = {};
      if (val == null || val.isEmpty || !val.containsKey("stats")) {
        stats[widget.folderName] = {};
        stats[widget.folderName][widget.levelName] = rating;
      } else {
        stats = val['stats'];
        if (!stats.containsKey(widget.folderName))
          stats[widget.folderName] = {};
        if (stats[widget.folderName].containsKey(widget.levelName))
          stats[widget.folderName][widget.levelName] = max(rating, stats[widget.folderName][widget.levelName] as num);
        else
          stats[widget.folderName][widget.levelName] = rating;
      }
      Settings.setParam('main', 'stats', stats);
    });
    Settings.setParam('main', 'first_launch', false);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int starQuan = 8;
    var starSize = min(MediaQuery.of(context).size.width/starQuan/1.5, MediaQuery.of(context).size.height/starQuan/1.5);
    var imageHeight = (MediaQuery.of(context).size.height - starSize) * 0.9 - 32 * 2 - 16;
    SystemChrome.setEnabledSystemUIOverlays([]);
    print(rating);
    List<Widget> stars = [];
    // 0.1 0.2  0.3 0.4  0.5 0.6  0.7 0.8  0.9 1.0
    for (int i = 1; i <= starQuan; i++)
      if (rating >= 1/starQuan * i)
        stars.add(Icon(
          Icons.star,
          size: starSize,
          color: Colors.amberAccent,
        ));
      else if (rating >= 1/starQuan * i - 1/starQuan/2)
        stars.add(Icon(
            Icons.star_half,
            color: Colors.amberAccent,
            size: starSize
        ));
      else stars.add(Icon(
            Icons.star_border,
            color: Colors.amberAccent,
            size: starSize
        ));

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        child: OrientationBuilder(builder: (context, orientation) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainMenu()),
              );
            },
            child: Container(
              color: Colors.lightBlue[100],
              child: Stack(
                children: [
                  Container(
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
                  ),
                  orientation == Orientation.landscape ?
                  Stack(
                    children: [
                      Positioned.fill(
                          child: Particles(
                            quan: 16,
                            colors: [
                              Colors.redAccent,
                              Colors.blueAccent,
                              Colors.green,
                              Colors.deepPurple,
                              Colors.orange
                            ],
                            duration:  Duration(milliseconds: 6000),
                            minSize: 0.05,
                            maxSize: 0.1,
                            yCurve: Curves.easeInOutCirc,
                            xCurve: Curves.ease,
                            volatileEnd: Offset(1.0, 0.25),
                            volatileStart: Offset(-0.1, 0.25),
                            start: Offset(0.0, 0.0),
                            end: Offset(1.0, 0.0),
                          )
                      ),
                      Positioned.fill(
                          child: Particles(
                            quan: 16,
                            colors: [
                              Colors.redAccent,
                              Colors.blueAccent,
                              Colors.green,
                              Colors.deepPurple,
                              Colors.orange
                            ],
                            duration:  Duration(milliseconds: 6000),
                            minSize: 0.05,
                            maxSize: 0.1,
                            yCurve: Curves.easeInOutCirc,
                            xCurve: Curves.ease,
                            volatileStart: Offset(1.1, 0.25),
                            volatileEnd: Offset(0.0, 0.25),
                            end: Offset(-0.1, 0.25),
                            start: Offset(1.1, 0.25),
                          )
                      ),
                      Positioned.fill(
                          child: Particles(
                            quan: 16,
                            colors: [
                              Colors.redAccent,
                              Colors.blueAccent,
                              Colors.green,
                              Colors.deepPurple,
                              Colors.orange
                            ],
                            duration:  Duration(milliseconds: 6000),
                            minSize: 0.05,
                            maxSize: 0.1,
                            yCurve: Curves.easeInOutCirc,
                            xCurve: Curves.ease,
                            volatileEnd: Offset(1.0, 0.25),
                            volatileStart: Offset(-0.1, 0.25),
                            start: Offset(-0.1, 0.5),
                            end: Offset(1.1, 0.5),
                          )
                      ),
                      Positioned.fill(
                          child: Particles(
                            quan: 16,
                            colors: [
                              Colors.redAccent,
                              Colors.blueAccent,
                              Colors.green,
                              Colors.deepPurple,
                              Colors.orange
                            ],
                            duration:  Duration(milliseconds: 6000),
                            minSize: 0.05,
                            maxSize: 0.1,
                            yCurve: Curves.easeInOutCirc,
                            xCurve: Curves.ease,
                            volatileStart: Offset(1.0, 0.25),
                            volatileEnd: Offset(0.0, 0.25),
                            end: Offset(-0.1, 0.75),
                            start: Offset(1.1, 0.75),
                          )
                      ),
                    ],
                  ) : Positioned.fill(
                      child: Particles(
                        quan: 60,
                        colors: [
                          Colors.redAccent,
                          Colors.blueAccent,
                          Colors.green,
                          Colors.deepPurple,
                          Colors.orange
                        ],
                        duration:  Duration(milliseconds: 4000),
                        minSize: 0.05,
                        maxSize: 0.1,
                        yCurve: Curves.ease,
                        xCurve: Curves.easeInOutCirc,
                        volatileEnd: Offset(3.0, -0.2),
                        volatileStart: Offset(0.0, 0.0),
                        start: Offset(0.5, 0.75),
                        end: Offset(-1, -0.1),
                      )
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        LimitedBox(
                          maxHeight: imageHeight,
                          child: Image(
                            image: AssetImage("assets/cup.png"),
                          ),
                        ),
//                        showStatas ? Container(
//                          height: 300,
//                          alignment: Alignment.center,
//                          child: FittedBox(
//                            alignment: Alignment.center,
//                            fit: BoxFit.scaleDown,
//                            child: RichText(
//                              textAlign: TextAlign.center,
//                              text: TextSpan(
//                                style: TextStyle(
//                                  fontWeight: FontWeight.bold,
//                                  shadows: List.generate(2, (index) => Shadow(offset: Offset(0.5,0.5))),
//                                  color: Colors.redAccent,
//                                ),
//                                  children: [
//                                    TextSpan(
//                                        style: TextStyle(
//                                            fontSize: 48),
//                                        text: "(" + widget.statistics.where((element) => element.isCorrect)
//                                            .length
//                                            .toString() + " / " +
//                                            widget.statistics.length.toString() +
//                                            ")\n"
//                                    ),
//                                    TextSpan(
//                                        style: TextStyle(fontSize: 32),
//                                        text: widget.statistics.map((e) =>
//                                            e.toString()).join()
//                                    ),
//                                  ]
//                              ),
//                            ),
//                          ),
//                        ) : Container(),
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.all(Radius.circular(16))),
                          child:                   Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: stars,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
