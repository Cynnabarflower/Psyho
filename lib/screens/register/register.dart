import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:psycho_app/custom_widgets/dateChooser/DateChooser.dart';
import 'package:psycho_app/custom_widgets/keyboard/Keyboard.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  String userName = "";
  String yearsOld = "";
  DateTime bDay;
  String qText = "What's your name?";
  String gender = "";
  int currentStageNumber = 0;
  var stages = [];
  var langs = [];
  List<Widget> tabs = [];
  TabController _tabController;
  List<Keyboard> keyboards = [];
  double dragDelta;
  Widget mainMenu;


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
        langs = (value['lang'])
            .map((e) => Layout.getKeyboardLangFromString(e))
            .toList();
      } else {
        langs = [
          KeyboardLangs.cyrillic_with_digits,
          KeyboardLangs.latin_with_digits
        ];
      }
      stages = [
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

  GlobalKey _tabBarView;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 4);
    _tabController.addListener(() {

      setState(() {
        if (_tabController.index == tabs.length - 1) {
          setState(() {

          });
        }
        currentStageNumber = _tabController.index;
      });
    });
    loadSettings().then((value) => setState(() {}));
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
    _initTabs();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: OrientationBuilder(
          builder: (context, orientation) =>
              orientation == Orientation.landscape ||
                      _tabController.index == tabs.length - 1
                  ? WillPopScope(
                      child: TabBarView(
                        key: _tabBarView,
                        controller: _tabController,
                        physics: NeverScrollableScrollPhysics(),
                        children: tabs,
                      ),
                      onWillPop: () {
/*            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainMenu()),
              );*/
                        previous();
                        return new Future(() => false);
                      })
                  : Container(
                      color: Colors.amber,
                      child: Column(
                        children: getVerticalTabs(),
                      ),
                    )),
      floatingActionButton: Visibility(
        visible: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: FlatButton(
            color: Colors.amber[200],
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "OK", style: TextStyle(color: Colors.black))),
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
      else if (bDay != null) {
        Settings.save('session', {
          'name': userName,
          'age': yearsOld,
          'bday': ('${bDay.year}.${bDay.month}.${bDay.day}'),
          'sex': gender
        });
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

  _initTabs() {
    mainMenu = MainMenu(name: userName,);

    tabs = <Widget>[
      //Name
      Container(
        color: Colors.amber,
        alignment: Alignment.center,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What's your name?",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 14,
                      color: Colors.redAccent),
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 100,
                      ),
                      Expanded(
                         child: getNameInput(showkb: false, height: double.infinity, fontsize: 120.0)
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: Image(
                              width: 100,
                              color:  Colors.redAccent,
                              fit: BoxFit.contain,
                              image: AssetImage('assets/next.png')),
                          onTap: () {
                            setState(() {
                              _tabController.animateTo(1);
                            });
                          },
                        ),
                      ),
                    ]
                )
              ),
              Expanded(
                child: Keyboard(
                  // Name
                  onEdited: (value) {
                    setState(() {
                      userName = value.substring(
                          0, value.length < 25 ? value.length : 25);
                      print(userName);
                    });
                  },
                  done: () {
                    next();
                  },
                  initValue: userName,
                  layouts: (langs.contains(KeyboardLangs.latin)
                          ? [Layout.latin()]
                          : List<Layout>(0)) +
                      (langs.contains(KeyboardLangs.cyrillic)
                          ? [Layout.cyrillic()]
                          : List<Layout>(0)),
                  showInputField: false,
                ).setInputField(InputField(forward: next, backward: previous)),
              ),
            ],
          ),
        ),
      ),
      //Gender
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
                  "Are you a boy or a girl?",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 14,
                      color: Colors.redAccent),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Image(
                                width: 100,
                                color:  Colors.redAccent,
                                fit: BoxFit.contain,
                                image: AssetImage('assets/previous.png')),
                            onTap: () {
                              setState(() {
                                _tabController.animateTo(0);
                              });
                            },
                          ),
                        ),
                        (gender == 'M' || gender == 'F'
                          ? Image(
                              color: Colors.black,
                              fit: BoxFit.contain,
                              image: AssetImage(gender == 'M'
                                  ? 'assets/male.png'
                                  : 'assets/female.png'))
                          : Container()),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Image(
                                width: 100,
                                color:  Colors.redAccent,
                                fit: BoxFit.contain,
                                image: AssetImage('assets/next.png')),
                            onTap: () {
                              setState(() {
                                _tabController.animateTo(2);
                              });
                            },
                          ),
                        )]),
                    ),
                    Keyboard(
                      // Name
                      onEdited: (value) {
                        setState(() {
                          gender = value.substring(
                              0, value.length < 25 ? value.length : 25);
                          print(gender);
                        });
                      },
                      done: () {
                        next();
                      },
                      initValue: gender,
                      layouts: [Layout.gender()],
                      showInputField: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      //BDay
      Container(
        color: Colors.amber,
        alignment: Alignment.center,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "When is your birthday?",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 14,
                      color: Colors.redAccent),
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: Image(
                              width: 100,
                              color:  Colors.redAccent,
                              fit: BoxFit.contain,
                              image: AssetImage('assets/previous.png')),
                          onTap: () {
                            setState(() {
                              _tabController.animateTo(1);
                            });
                          },
                        ),
                      ),
                      Image(
                          color: Colors.redAccent,
                          fit: BoxFit.contain,
                          image: AssetImage('assets/cake.png'))
                          ,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          child: Image(
                              width: 100,
                              color:  Colors.redAccent,
                              fit: BoxFit.contain,
                              image: AssetImage('assets/next.png')),
                          onTap: () {
                            setState(() {
                              _tabController.animateTo(3);
                            });
                          },
                        ),
                      )]),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: DateChooser(
                    (val, _) {
                      setState(() {
                        bDay = val;
                      });
                    },
                    langs.contains(KeyboardLangs.cyrillic)
                        ? DateTimePickerLocale.ru
                        : DateTimePickerLocale.en_us,
                    init: bDay,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      mainMenu
    ];
  }

  getVerticalTabs() {
    return [
      Flexible(
        flex: 90,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "What's your name?",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 14,
                    color: Colors.redAccent),
              ),
              getNameInput(),
              Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Text(
                    "Are you a boy or a girl?",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 14,
                        color: Colors.redAccent),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Image(
                        color: gender == 'M' ? Colors.redAccent : Colors.black,
                        fit: BoxFit.contain,
                        image: AssetImage('assets/male.png')),
                    onTap: () {
                      setState(() {
                        gender = 'M';
                      });
                    },
                  ),
                  GestureDetector(
                    child: Image(
                        color: gender == 'F' ? Colors.redAccent : Colors.black,
                        fit: BoxFit.contain,
                        image: AssetImage('assets/female.png')),
                    onTap: () {
                      setState(() {
                        gender = 'F';
                      });
                    },
                  ),
                ],
              ),
              Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "When is your birthday?",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 16,
                            color: Colors.redAccent),
                      ),
                      Image(
                        width: 60,
                        height: 60,
                        color: Colors.redAccent,
                        image: AssetImage('assets/cake.png'),
                      )
                    ],
                  )),
              Container(
                alignment: Alignment.bottomCenter,
                child: DateChooser(
                  (val, _) {
                    setState(() {
                      bDay = val;
                    });
                  },
                  langs.contains(KeyboardLangs.cyrillic)
                      ? DateTimePickerLocale.ru
                      : DateTimePickerLocale.en_us,
                  init: bDay,
                ),
              ),
            ],
          ),
        ),
      ),
      Flexible(
        flex: 10,
        child: GestureDetector(
          onTap: () {
            Settings.save('session', {
              'name': userName,
              'age': yearsOld,
              'bday': ('${bDay.year}.${bDay.month}.${bDay.day}'),
              'sex': gender
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMenu()),
            );
          },
          child: Container(
            alignment: Alignment.center,
            color: Colors.redAccent,
            child: Text(
              'Done!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 14,
                  color: Colors.amberAccent),
            ),
          ),
        ),
      )
    ];
  }

  getNameInput({showkb = true, height = 60.0, fontsize = 64.0}) {
    return GestureDetector(
      onTap: () {
        showkb ?
        setState(() {
          showModalBottomSheet(
              barrierColor: Colors.black.withAlpha(1),
              backgroundColor: Colors.redAccent.withAlpha(100),
              context: context,
              builder: (context) => Keyboard(
                    showInputField: true,
                    standalone: false,
                    layouts: [Layout.cyrillic()],
                    onEdited: (val) {
                      setState(() {
                        userName = val;
                      });
                      print(val);
                    },
                    initValue: userName,
                  )).then((value) {
            setState(() {});
          });
        }) : {};
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: Text(
            userName,
            style: TextStyle(fontSize: fontsize, color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
