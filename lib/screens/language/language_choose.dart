import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/custom_widgets/particles/Particles.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/register/register.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class LanguageChoose extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () async {
                        await Settings.setParam('main', 'lang', PARAMS['main']['lang']['values'][0]['Ru']);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  image: AssetImage('assets/ru_flag.png'),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Русский',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 54, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: InkWell(
                      onTap: () async {
                        await Settings.setParam('main', 'lang', PARAMS['main']['lang']['values'][1]['En']);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  image: AssetImage('assets/uk_flag.png'),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'English',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 54, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
