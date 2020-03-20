import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/custom_widgets/keyboard/Keyboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PARAMS = {
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
    "password": {"name": "Settings password", "values": []},
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
                          SettingsPage('statistics', PARAMS['statistics'])
                        ],
                      ),
                    ),
                  ));
                else {
                  return Center(
                    child: GestureDetector(
                      onTap: () {Navigator.pop(context);},
                      child: Container(
                          alignment: Alignment.center,
                          color: Colors.amber,
                          padding: EdgeInsets.all(8),
                          child: Container(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Keyboard(
                                      (val) { password == val ? setState(() {password = "";}) : "";},
                                      maxLength: 4, showInputField: true,
                              ),
                            ),
                          )),
                    ),
                  );
                }
                else
                  return Container();
              }),
          onWillPop: () {
            return new Future(() => true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      child: Container(
        color: Colors.amber,
        alignment: Alignment.center,
        child: FutureBuilder(
            future: loaded,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    children: list);
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
    loaded = readSettings();
  }

  Future<bool> readSettings() async {
    print('reading settings');
    var settings = await Settings.read(widget.name);
    widget.cSettings = settings;
    print(widget.cSettings);
    widget.map.forEach((key, value) {
      list.add(Param(key, value['name'], value['values'], widget._save,
          widget.cSettings.containsKey(key) ? widget.cSettings[key] : null));
    });
    return true;
  }
}

class Param extends StatefulWidget {
  String name;
  String id;
  List<dynamic> args = [];
  Function _save;
  dynamic value;

  @override
  _ParamState createState() => _ParamState();

  Param(this.id, this.name, this.args, this._save, this.value) {}
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
        isSelected.add(widget.value == arg.values.elementAt(0));
      }
    } else {}
  }

  dynamic getSelected() {
    return widget.args[currentIndex].values.elementAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: <Widget>[
          Row(
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
          editing ? Container(
            child: Keyboard((value){
              setState(() {
                widget.value = value;
                widget._save(widget.id, widget.value.trim());
              });
            }, maxLength: 4, showInputField: false),
          ) : Container()
        ],
      ),
    );
  }

  Widget getInputWidget() {
    if (widget.args.isEmpty) {
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
          onChanged: (value) => widget._save(widget.id, value.trim()),
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