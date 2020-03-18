import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/main/main_menu.dart';

class Reward extends StatefulWidget {

  List<Statistics> statistics;

  @override
  _RewardState createState() => _RewardState();

  Reward(this.statistics);

}

class _RewardState extends State<Reward> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          60, [
                        Colors.orangeAccent[400],
                        Colors.amber[300],
                        Colors.amberAccent[400],
                        Colors.redAccent[200],
                        Colors.yellowAccent
                      ])),
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
                        Container(
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
