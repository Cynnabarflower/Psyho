import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/custom_widgets/keyboard/Keyboard.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  String userName = "";
  String yearsOld = "";
  String bDay = "";
  String qText = "What's your name?";
  String gender = "";
  int currentStageNumber = 0;
  var stages = [];
  var langs = [];
  TabController _tabController;
  List<Keyboard> keyboards = [];
  double dragDelta;


  Future<bool> loadSettings() async {
    await Settings.read('main').then((value) {
      if (!value['loginOnBoot']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu()),
        );
      }
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (value['lang'] != null) {
        langs = (value['lang']).map((e) => Layout.getKeyboardLangFromString(e)).toList();
      } else {
        langs = [KeyboardLangs.cyrillic_with_digits, KeyboardLangs.latin_with_digits];
      }
      stages = [
        {
          'question': "What's your name?",
          'answer' : '',
          'layouts':             (langs.contains(KeyboardLangs.latin) ? [Layout.latin()] : List<Layout>(0)) +
              (langs.contains(KeyboardLangs.cyrillic) ? [Layout.cyrillic()] : List<Layout>(0))
        },
        {
          'question': "Are you a boy or a girl?",
          'answer' : '',
          'layouts': [Layout.gender()]
        },
        {
          'question': "How old are you?",
          'answer': '',
          'layouts': [Layout.numeric()]
        },
        {
          'question': "When is your birthday?",
          'answer': '',
          'layouts': [Layout.dayMonth()]
        }
      ];
    });
    return true;
  }

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      setState(() {
        currentStageNumber = _tabController.index;
      });
    });
    loadSettings().then((value) => setState((){}));
    super.initState();
/*    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);*/
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (langs.isEmpty) {
      return Scaffold(
        body: Center(
          child: GestureDetector(

            child: Container(
              alignment: Alignment.center,
              color: Colors.amber,
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      strokeWidth: 16,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                    ),
                  ),
                ),
            ),
          ),
        ),
      );
    }

    keyboards = [
      Keyboard( // Name
        onEdited: (value) {
          setState(() {
            userName = value.substring(0, value.length < 25 ? value.length : 25);
            keyboards[0].setEditText(userName);
            print(userName);
          });
        },
        done: () { next(); },
        initValue: userName,
        layouts: stages[0]['layouts'],
        showInputField: true,
      ),
      Keyboard( // Gender
        onEdited: (value) {
          setState(() {
            gender = value;
            keyboards[1].setEditText(bDay);
            print(gender);
            next();
          });
        },
        initValue: '',
        layouts: stages[1]['layouts'],
        showInputField: true,
      ),
      Keyboard( // Age
        onEdited: (String value) {
          setState(() {
            yearsOld = value.substring(0, min(value.length, 2));
            keyboards[2].setEditText(yearsOld);
            print(yearsOld);
          });
        },
        initValue: yearsOld,
        layouts: stages[2]['layouts'],
        showInputField: true,
      ),
      Keyboard( // bDay
        onEdited: (value) {
          setState(() {
            bDay = value;
            keyboards[3].setEditText(bDay);
            print(bDay);
          });
        },
        initValue: bDay,
        layouts: stages[3]['layouts'],
        showInputField: true,
      )
    ];

    keyboards[0].setInputField(
        InputField(forward: next, backward: previous)
    );

    keyboards[1].setInputField(
        InputField(forward: next, backward: previous)
    );
    keyboards[2].setInputField(
        InputField(forward: next, backward: previous)
    );
    keyboards[3].setInputField(
        InputField(forward: next, backward: previous)
    );

    var w = MediaQuery.of(context).size.width;
    var tabs = <Widget>[];
    for (var i  = 0; i < stages.length; i++)
      tabs.add(
          Container(
            color: Colors.amber,
            alignment: Alignment.center,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      stages[i]['question'],
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 14,
                          color: Colors.redAccent),
                    ),
                  ),
                  keyboards[i],
                ],
              ),
            ),
          )
      );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: WillPopScope(
        child: TabBarView(
          controller: _tabController,
          //physics: NeverScrollableScrollPhysics(),
          children: tabs,
        ),
          onWillPop: () {
/*            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMenu()),
            );*/
            previous();
            return new Future(() => false);
          }
      ),
      floatingActionButton: Visibility(
        visible: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: FlatButton(
            color: Colors.amber[200],
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(text: "OK", style: TextStyle(color: Colors.black))),
            onPressed: () {
              next();
              },
          ),
        ),
      ),
    );
  }

  next() {
    if (currentStageNumber == 0) {
      setState(() {
        if (userName.isNotEmpty) {
          currentStageNumber++;
        }
      });
    } else if (currentStageNumber == 1) {
      if (gender.isNotEmpty) {
        currentStageNumber++;
      }
      setState(() {});
    } else if (currentStageNumber == 2) {
      if (yearsOld.isNotEmpty) {
        currentStageNumber++;
      }
      setState(() {});
    } else if (currentStageNumber >= 3) {
      if (userName.isEmpty) {
        currentStageNumber = 0;
      } else if (gender.isEmpty)
        currentStageNumber = 1;
      else if (yearsOld.isEmpty)
        currentStageNumber = 2;
      else if (bDay.isNotEmpty) {
        Settings.save('session', {'name': userName, 'age': yearsOld, 'bday' : bDay, 'sex' : gender});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu()),
        );

        return;
      }

    }
    _tabController.animateTo(currentStageNumber);
  }
  previous() {
    if (currentStageNumber > 0) {
      currentStageNumber--;
      _tabController.animateTo(currentStageNumber);
    }
  }
}
