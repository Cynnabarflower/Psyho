import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class Reward extends StatefulWidget {

  List<Statistics> statistics;
  bool showStats = false;

  @override
  _RewardState createState() => _RewardState();


  Future<bool> loadSettings() async {
    await Settings.read('main').then((value) {
        showStats = value['showStats'];
    });
    return true;
  }


  Reward(this.statistics) {
    loadSettings();
  }

}

class _RewardState extends State<Reward> {


  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showStatas = widget.showStats;
    SystemChrome.setEnabledSystemUIOverlays([]);
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
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Particles(
                          quan: 60,
                          colors: [
                        Colors.orangeAccent[400],
                        Colors.amber[300],
                        Colors.amberAccent[400],
                        Colors.redAccent[200],
                        Colors.yellowAccent
                      ],
                      duration:  Duration(milliseconds: 2000),
                        minSize: 0.1,
                        maxSize: 0.3,
                      )),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          const Color(0x88ffe200),
                          const Color(0x88fda72d),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("assets/cup.png"),
                        ),
                        showStatas ? Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  shadows: List.generate(2, (index) => Shadow(offset: Offset(0.5,0.5))),
                                  color: Colors.redAccent,
                                ),
                                  children: [
                                    TextSpan(
                                        style: TextStyle(
                                            fontSize: 48),
                                        text: "(" + widget.statistics.where((element) => element.isCorrect)
                                            .length
                                            .toString() + " / " +
                                            widget.statistics.length.toString() +
                                            ")\n"
                                    ),
                                    TextSpan(
                                        style: TextStyle(fontSize: 32),
                                        text: widget.statistics.map((e) =>
                                            e.toString()).join()
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ) : Container()
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
