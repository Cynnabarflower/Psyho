import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:psycho_app/custom_widgets/keyboard/Keyboard.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';


var PARAMS = {
  "tutorial": {
    "showTumb": {
      "name": "Show previous picture",
      "values": [
        {"yes": true},
        {"no": false}
      ]
    },
    "showHand": {
      "name": "Show hand",
      "values": [
        {"yes": true},
        {"no": false}
      ]
    }
  },
  "main": {
    "password": {
      "name": "Settings password",
      "values": [],
      "langs": [KeyboardLangs.numeric.toString(), KeyboardLangs.cyrillic.toString()]
    },
    "showStats": {
      "name": "Show stats on reward screen",
      "values": [
        {"yes": true},
        {"no": false}
      ]
    },
    "fullScreen": {
      "name": "Full screen",
      "values": [
        {"yes": true},
        {"no": false}
      ]
    },
    "lang": {
      "name": "Keyboard languages",
      "values": [
        {"Ru": [KeyboardLangs.cyrillic.toString()]},
        {"En": [KeyboardLangs.latin.toString()]},
        {"Ru&En": [KeyboardLangs.cyrillic.toString(), KeyboardLangs.latin.toString()]}
      ]
    },
    "welcomeText" : {
      "name": "Welcome text",
      "values": [],
    }
  },
  "statistics": {}
};


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();

  Settings() {}

  Map<String, Map<String, String>> defaultSettings() {}

  static read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    Map<String, dynamic> settings = {};
    if (PARAMS.containsKey(key))
      PARAMS[key].forEach((key, value) {
        var values = value['values'];
        if (values != null && values.isNotEmpty)
          settings[key] = value['values'][0].values.elementAt(0);
        else
          settings[key] = "";
      });
    if (value != null) {
      json.decode(value).forEach((key, value) {
        settings[key] = value;
      });
    }
    return settings;
    return value != null ? json.decode(value) : Map<String, dynamic>();
  }

   static saveStats(List<dynamic> stats, time) async {
     final directory = await Directory((await getApplicationDocumentsDirectory()).path + '/stats/').create();
     final user = await Settings.read('session');
     var file = File("${directory.path}${user['name']}_${user['sex']}_${user['bday']}_${time.toString()}");

     file.writeAsString(
       stats.fold(
           "${user['name']}\n${user['sex']}\n${user['bday']}\n${time.toString()}",
               (previousValue, element) => previousValue + '\n' + element.toString())
     ).then((value) {
       print('stats saved');
     });
   }

   static loadStats() async {
     final directory = Directory((await getApplicationDocumentsDirectory()).path + '/stats/');
     var files = directory.listSync().where((element) => element is File).toList();
     return files;
   }

  static save(String key, Map<dynamic, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
    print('saved $value');
  }
}

class _SettingsState extends State<Settings> {
  Future<bool> settingsLoaded;
  String password;
  String enteredPassword = "";
  Map<int, bool> pressed = {};

  Future<bool> loadSettings() async {
    await Settings.read('main').then((value) {
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      password = value['password'];
    });
    return true;
  }

  @override
  void initState() {
    settingsLoaded = loadSettings();
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: Colors.amber,
        child: WillPopScope(
          child: FutureBuilder(
              future: settingsLoaded,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) if (password
                    .isEmpty)
                  return Center(
                      child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.orange,
                        bottom: TabBar(
                          indicatorColor: Colors.redAccent,
                          tabs: [
                            Tab(text: "Main"),
                            Tab(text: "Tutorial"),
                            Tab(text: "Statistics"),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        children: <Widget>[
                          SettingsPage('main', PARAMS['main']),
                          SettingsPage('tutorial', PARAMS['tutorial']),
                          StatisticsPage(),
                        ],
                      ),
                    ),
                  ));
                else {
                  print('password:' + password);
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {Navigator.pop(context);},
                          child: Container(
                              alignment: Alignment.center,
                              color: Colors.amber,
                              padding: EdgeInsets.all(8)),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child:
                            Container(
                              child: Keyboard(
                                  onEdited: (val) { password == val ? setState(() {password = "";}) : "";},
                                  initValue: "",
                                  showInputField: true,
                                  layouts: [
                                    Layout.latin(),
                                    Layout.cyrillic(),
                                    Layout.latin(withDigits: true),
                                    Layout.cyrillic(withDigits: true),
                                    Layout.numeric()
                                  ]),
                            )
                        )
                      ],
                    ),
                  );
                }
                else
                  return Container();
              }),
          onWillPop: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainMenu()),
            );
            return new Future(() => false);
          },
        ),
      ),
    );
  }

}

class SettingsPage extends StatefulWidget {
  Map<dynamic, dynamic> map;
  Map<String, dynamic> cSettings = {};
  String name;

  void _save(String key, dynamic value) {
    cSettings[key] = value;
    Settings.save(name, cSettings);
    Settings.save(name, cSettings);
  }

  SettingsPage(this.name, this.map) {}

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Widget> list = [];
  Future<bool> loaded;
  String editText = '';
  Param currentParam;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: WillPopScope(
      child: Container(
        color: Colors.amber,
        alignment: Alignment.center,
        child: LayoutBuilder(
            builder: (context, snapshot) {
              if (list != null && list.isNotEmpty)
                return Stack(
                  children: <Widget>[
                    ListView(
                        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        children: fillSettings()),

                    LayoutBuilder(
                      builder: (context, constraints) => currentParam == null ? Container(width: 0,height: 0,) : Container(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*2/3,
                          child: Keyboard(
                            showInputField: false,
                            layouts: currentParam.layouts,
                            onEdited: (val)  {
                              setState(() {
                                currentParam.value = val;
                                widget._save(currentParam.id, currentParam.value);
                                fillSettings();
                              });
                                print(val);
                            },
                            initValue: currentParam == null ? '' : currentParam.value.toString(),
                          ),
                        ),
                      ),
                    )

                  ],
                );
              else
                return Container();
            }),
      ),
      onWillPop: () {
        return Future(() => true);
      },
    ));
  }

  @override
  void initState() {
    super.initState();
    readSettings().then((value) => setState((){}));
  }

  Future<bool> readSettings() async {
    print('reading settings');
    var settings = await Settings.read(widget.name);
    widget.cSettings = settings;
    print(widget.cSettings);
    fillSettings();
    return true;
  }

  fillSettings() {
    list = [];
    widget.map.forEach((key, value) {
      list.add(Param(key, value['name'], value['values'], widget._save,
        widget.cSettings[key] ?? (value['values'].isNotEmpty ?  value['values'] : "")
        , value['langs'], onEditing: (param) { setState(() {
          currentParam = param;
        });},
      ));
    });
    return list;
  }
}

class Param extends StatefulWidget {
  String name;
  String id;
  List<dynamic> args = [];
  Function _save;
  dynamic value;
  List<Layout> layouts = [];
  Function onEditing;

  @override
  _ParamState createState() => _ParamState();

  Param(this.id, this.name, this.args, this._save, this.value, List<dynamic> langs, {this.onEditing}) {
    if (args.isEmpty) {
      if (langs != null)
      langs.forEach((element) {
        var el = Layout.getKeyboardLangFromString(element);
        switch (el) {
          case KeyboardLangs.cyrillic: layouts.add(Layout.cyrillic()); break;
          case KeyboardLangs.latin: layouts.add(Layout.latin()); break;
          case KeyboardLangs.cyrillic_with_digits: layouts.add(Layout.cyrillic(withDigits: true)); break;
          case KeyboardLangs.latin_with_digits: layouts.add(Layout.latin(withDigits: true)); break;
          case KeyboardLangs.numeric: layouts.add(Layout.numeric()); break;
          case KeyboardLangs.digits: layouts.add(Layout.digital());
        }
      });
      else {
      }
    }

  }
}

class _ParamState extends State<Param> {
  List<bool> isSelected = [];
  List<Widget> buttons = [];
  int currentIndex;
  bool editing = false;
  bool isPassword = true;


  @override
  void initState() {
    if (widget.args.isNotEmpty) {
      for (var arg in widget.args) {
        buttons.add(Text(
          arg.keys.elementAt(0),
          style: TextStyle(color: Colors.black),
        ));
        isSelected.add(json.encode(widget.value) == json.encode(arg.values.elementAt(0)));
      }
    } else {}
  }

  dynamic getSelected() {
    return widget.args[currentIndex].values.elementAt(0);
  }

  @override
  Widget build(BuildContext context) {
    print('param built');
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: editing ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 0),
            child: editing ? Container() : Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                child: Text(widget.name)),
          ),
          getInputWidget(),
        ],
      ),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Padding(
//      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        crossAxisAlignment: CrossAxisAlignment.center,
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Row(
//            mainAxisAlignment: editing ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              AnimatedSwitcher(
//                duration: Duration(milliseconds: 0),
//                child: editing ? Container() : Padding(
//                    padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
//                    child: Text(widget.name)),
//              ),
//              getInputWidget(),
//            ],
//          ),
//
//          Padding(
//            padding: EdgeInsets.all(8),
//            child: Keyboard(
//              initValue: widget.value,
//                onEdited: (value){
//                  setState(() {
//                    widget.value = value;
//                    widget._save(widget.id, widget.value);
//                  });
//                },
//                layouts: widget.layouts,
//            visible: editing && widget.layouts.isNotEmpty),
//          )
//        ],
//      ),
//    );
//  }

  Widget getInputWidget() {
    if (widget.args.isEmpty) {
      if (widget.layouts.isNotEmpty) {
      return Flexible(
        flex: 100,
        child: GestureDetector(
          onTap: () {setState(() {
          editing = !editing;
          if (widget.onEditing != null) widget.onEditing( editing ? widget : null);
        });},
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.orangeAccent,
            ),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                isPassword && !editing ? widget.value.replaceAll(RegExp('[0-9]'), '*') : widget.value,
                style: TextStyle(
                  fontSize: 30
                ),
              ),
            ),
          ),
        ),
      );
      }
      else {
        return Flexible(
          flex: 100,
          child: GestureDetector(
            onTap: () {setState(() {
              editing = !editing;
            });},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.orangeAccent,
              ),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: TextFormField(
                  initialValue: isPassword && !editing ? widget.value.replaceAll(RegExp('[0-9]'), '*') : widget.value,
                  onChanged: (value) {
                    setState(() {
                      widget.value = value;
                      widget._save(widget.id, widget.value);
                    });
                  },
                  style: TextStyle(
                      fontSize: 30
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    if (widget.args.isEmpty && false) {
      return Container(
        width: 200,
        child: TextFormField(
          initialValue: widget.value,
          cursorColor: Colors.redAccent,
          decoration: InputDecoration(
            focusColor: Colors.redAccent,
            filled: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide.none,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => widget._save(widget.id, value),
        ),
      );
    }
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Colors.orangeAccent,
      ),
      child: ToggleButtons(
        borderColor: Colors.orange,
        fillColor: Colors.redAccent,
        borderWidth: 2,
        children: buttons,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        onPressed: (int index) {
          currentIndex = index;
          widget._save(widget.id, widget.args[index].values.elementAt(0));
          setState(() {
            for (int buttonIndex = 0;
                buttonIndex < isSelected.length;
                buttonIndex++) {
              if (buttonIndex == index) {
                isSelected[buttonIndex] = true;
              } else {
                isSelected[buttonIndex] = false;
              }
            }
          });
        },
        isSelected: isSelected,
      ),
    );
  }
}

class StatisticsPage extends StatefulWidget {

  Future<void> share() async {
    await FlutterShare.share(

    );
  }

  Future<String> getStatistics() async {

  }

  Future<void> shareFile() async {
    var statFile = await getStatistics();
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      filePath: statFile,
    );
  }

  @override
  State<StatefulWidget> createState() => _StatisticsPageState();


}

class _StatisticsPageState extends State<StatisticsPage> {


  List<String> checkBoxes = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          color: Colors.amber,
          child: FutureBuilder(
            future: Settings.loadStats(),
            builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done ?
            ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  checkBoxes = List(snapshot.data.length);
                  checkBoxes.fillRange(0, snapshot.data.length, '');
                  return Card(
                    color: Colors.orangeAccent.withOpacity(0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: CheckboxListTile(
                      title:  FittedBox(fit: BoxFit.fitWidth,child: Text(snapshot.data[index].toString().split('/').last, style: TextStyle(color: Colors.redAccent))),
                      value: checkBoxes[index].isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          checkBoxes[index] = snapshot.data[index].toString().split('/').last;
                        });

                      },
                    ),
                  );
                }) : Text('Loading...'),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        onPressed: widget.share,

      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

}