import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:psycho_app/custom_widgets/keyboard/Keyboard.dart';
import 'package:psycho_app/custom_widgets/slideToConfirm/slideToConfirm.dart';
import 'package:psycho_app/screens/game/Statistics.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

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
    },
    "colorsGameLength": {
      "name": "Color game length",
      "values": [],
      "langs": [
        KeyboardLangs.numeric.toString()
      ]
    },
    "colorsGameColors": {
      "name": "Available colors",
      "values": [{'def': '0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x00ffff, 0xff00ff'}]
    }
  },
  "main": {
    "password": {
      "name": "Settings password",
      "values": [],
      "langs": [
        KeyboardLangs.numeric.toString(),
        KeyboardLangs.cyrillic.toString()
      ]
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
        {
          "Ru": [KeyboardLangs.cyrillic.toString()]
        },
        {
          "En": [KeyboardLangs.latin.toString()]
        },
        {
          "Ru&En": [
            KeyboardLangs.cyrillic.toString(),
            KeyboardLangs.latin.toString()
          ]
        }
      ]
    },
    "welcomeText": {
      "name": "Welcome text",
      "values": [],
    },
    "loginOnBoot": {
      "name": "Show reg page on launch",
      "values": [
        {"yes": true},
        {"no": false}
      ],
    },
    "loginRequired": {
      "name": "Login required to play",
      "values": [
        {"yes": true},
        {"no": false}
      ],
    }
  },
  "statistics": {}
};

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();

  Settings() {}

  Map<String, Map<String, String>> defaultSettings() {}

  static Future<Map<String, dynamic>> read(String key) async {
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

  static saveStats(Statistics stats, time) async {
    final directory = await Directory(
            (await getApplicationDocumentsDirectory()).path + '/stats/')
        .create();
    final user = await Settings.read('session');
    var file = File(
        "${directory.path}${user['name']}_${user['sex']}_${user['age']}_${user['bday']}_${time.toString()}.txt"
    );

    file.writeAsString(stats.answers.fold(
            "${user['name']}\n${user['sex']}\n${user['bday']}\n${user['bday']}\n${time.toString()}",
            (previousValue, element) =>
                previousValue + '\n' + element.toString()))
        .then((value) {
      print('stats saved');
    });
  }

  static Future<List> loadStats() async {
    final directory =
        Directory((await getApplicationDocumentsDirectory()).path + '/stats/');
    if (!directory.existsSync())
      directory.createSync();
    var files =
    (directory.listSync().where((element) => element is File).map((e) => e.path)).toList();
    return files;
  }

  static save(String key, Map<dynamic, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
    print('saved $value');
  }

  static setParam(String key, String name, value) async {
    await Settings.read(key).then(
        (v) {
          v[name] = value;
          save(key, v);
        }
    );
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
        alignment: Alignment.center,
        child: WillPopScope(
          child: FutureBuilder(
              future: settingsLoaded,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.done) if (password.isEmpty)
                  return Center(
                      child: DefaultTabController(
                    length: 3,
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.lightBlueAccent[200],
                        bottom: TabBar(
                          indicatorColor: Colors.white,

                          tabs: [
                            Tab(text: "Main"),
                            Tab(text: "Tutorial"),
                            Tab(text: "Statistics"),
                          ],
                        ),
                      ),
                      body: TabBarView(
                        physics: FixedExtentScrollPhysics(),
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
                  return Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                            alignment: Alignment.center,
                            color: Colors.lightBlueAccent[100].withOpacity(0.6),
                            padding: EdgeInsets.all(8)),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        color: Colors.lightBlue[200],
                        child:
                      Keyboard(
                          onEdited: (val) {
                            print(val);
                            if (val.length > 4)
                              val = val.substring(0, 4);
                            enteredPassword = val;
                             password == val
                                ? password = ''
                                : "";
                            setState(() {});
                          },
                          initValue: enteredPassword,
                          showInputField: true,
                          standalone: true,
                          heightRatio: 0.7,
                          layouts: [
                            Layout.numeric()
                          ]).setInputField(InputField(isPassword: true, minTextLength: 4,))
                      )
                    ],
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

/*  getNameInput({showkb = true, height = 60.0, fontsize = 50.0, context}) {
    return GestureDetector(
      onTap: () {
        showkb
            ? setState(() {
          Scaffold.of(context).showBottomSheet<void>(
                (context) => OrientationBuilder(
              builder: (context, orientation) {
                  return Container(

                      width: double.infinity,
                      color: Colors.transparent,
                      child: Column(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        Container(
                          child: Keyboard(
                            showInputField: true,
                            standalone: false,
                            layouts: [Layout.digital()],
                            onEdited: (val) {
                              setState(() {

                              });
                              print(val);
                            },
                            initValue: '',
                          ),
                        ),
                      ]));
              },
            ),
            backgroundColor: Colors.lightBlueAccent[100].withOpacity(0.0),
            elevation: 0,
          );
        })
            : {};
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: Text(
            '',
            style: TextStyle(fontSize: fontsize, color: Colors.lightBlue),
          ),
        ),
      ),
    );
  }
  */
}

class SettingsPage extends StatefulWidget {
  Map<dynamic, dynamic> map;
  Map<String, dynamic> cSettings = {};
  String name;

  void _save(String key, dynamic value) {
    cSettings[key] = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
      child: Container(
        color: Colors.lightBlueAccent[100].withOpacity(0.6),
        alignment: Alignment.center,
        child: LayoutBuilder(builder: (context, snapshot) {
          if (list != null && list.isNotEmpty)
            return Stack(
              children: <Widget>[
                ListView(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    children: fillSettings()),
                Container(
                  alignment: Alignment.bottomRight,
                  child:
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConfirmationSlider(
                        height: 60,
                        width: 300,
                        shadow: BoxShadow(color: Color.fromARGB(0, 0, 0, 0)),
                        backgroundColor: Colors.redAccent[100],
                        backgroundShape: BorderRadius.circular(30),
                        icon: Icons.delete,
                        text: 'Reset level stars',
                        textStyle: TextStyle(fontSize: 20, color: Colors.white),
                        foregroundColor: Colors.redAccent,
                        onConfirmation: () {
                          Settings.setParam('main', 'stats', {});
                        },
                        onStarted:(){}
                    ),
                  ),
                ),
              ],
            );
          else
            return Container();
        }),
      ),
      onWillPop: () {
        return Future(() => true);
      },
    ),
    );
  }

  @override
  void initState() {
    super.initState();
    readSettings().then((value) => setState(() {}));
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
      list.add(Param(
        key,
        value['name'],
        value['values'],
        widget._save,
        widget.cSettings[key] ??
            (value['values'].isNotEmpty ? value['values'] : ""),
        value['langs'],
        onEditing: (param) {

        },
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

  Param(this.id, this.name, this.args, this._save, this.value,
      List<dynamic> langs,
      {this.onEditing}) {
    if (args.isEmpty) {
      if (langs != null)
        langs.forEach((element) {
          var el = Layout.getKeyboardLangFromString(element);
          switch (el) {
            case KeyboardLangs.cyrillic:
              layouts.add(Layout.cyrillic());
              break;
            case KeyboardLangs.latin:
              layouts.add(Layout.latin());
              break;
            case KeyboardLangs.cyrillic_with_digits:
              layouts.add(Layout.cyrillic(withDigits: true));
              break;
            case KeyboardLangs.latin_with_digits:
              layouts.add(Layout.latin(withDigits: true));
              break;
            case KeyboardLangs.numeric:
              layouts.add(Layout.numeric());
              break;
            case KeyboardLangs.digits:
              layouts.add(Layout.digital());
          }
        });
      else {}
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
        isSelected.add(
            json.encode(widget.value) == json.encode(arg.values.elementAt(0)));
      }
    } else {}
  }

  dynamic getSelected() {
    return widget.args[currentIndex].values.elementAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment:
            editing ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 0),
            child: editing
                ? Container()
                : Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: Text(widget.name)),
          ),
          getInputWidget(),
        ],
      ),
    );
  }




  Widget getInputWidget() {
    if (widget.args.isEmpty) {
      if (widget.layouts.isNotEmpty) {
        return Flexible(
          flex: 100,
          child: GestureDetector(
            onTap: () {
              setState(() {
                editing = !editing;
                if (editing) {
                  Scaffold.of(context).showBottomSheet<void>(
                        (context) => OrientationBuilder(
                      builder: (context, orientation) {
                        if (orientation == Orientation.portrait)
                          return Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.transparent,
                              child: Column(children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: ()  {
                                      setState(() {
                                        widget._save(
                                            widget.id, widget.value);
                                        editing = !editing;
                                      });
                                      Navigator.of(context).pop();
                                      },
                                    child: Container(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Keyboard(
                                    showInputField: true,
                                    standalone: false,
                                    layouts: widget.layouts,
                                    onEdited: (val) {
                                      setState(() {
                                        widget.value = val;
                                      });
                                      print(val);
                                    },
                                    initValue: widget.value.toString(),
                                  ),
                                ),
                              ]));
                        else {
                          return Container();
                        }
                      },
                    ),
                    backgroundColor: Colors.lightBlueAccent[100].withOpacity(0.0),
                    elevation: 0,
                  );
                  /*showModalBottomSheet(
                      backgroundColor: Colors.blue,
                      context: context,
                      builder: (context) =>
                  Keyboard(
                    showInputField: true,
                    layouts: widget.layouts,
                    onEdited: (val) {
                      setState(() {
                        widget.value = val;
                      });
                      print(val);
                    },
                    initValue: widget.value.toString(),
                  )
                ).then((value) {
                  setState(() {
                    widget._save(
                        widget.id, widget.value);
                    editing = !editing;
                  });
                  });*/
                }
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.lightBlueAccent[100],
              ),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  isPassword && !editing
                      ? widget.value.replaceAll(RegExp('[0-9]'), '*')
                      : widget.value,
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),
        );
      } else {
        return Flexible(
          flex: 100,
          child: GestureDetector(
            onTap: () {
              setState(() {
                editing = !editing;
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.lightBlueAccent[100],
              ),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: TextFormField(
                  initialValue: isPassword && !editing
                      ? widget.value.replaceAll(RegExp('[0-9]'), '*')
                      : widget.value,
                  onChanged: (value) {
                    setState(() {
                      widget.value = value;
                      widget._save(widget.id, widget.value);
                    });
                  },
                  style: TextStyle(fontSize: 30),
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
          cursorColor: Colors.green,
          decoration: InputDecoration(
            focusColor: Colors.green,
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
        color: Colors.lightBlueAccent[100],
      ),
      child: ToggleButtons(
        borderColor: Colors.lightBlueAccent[100],
        fillColor: Colors.green,
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


  @override
  State<StatefulWidget> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<bool> checkBoxes = [];
  List<String> files;
  bool loaded = false;
  bool deleteDragStarted = false;

  
  Future<String> getChosenFiles() async {
    var chosenFiles = [];
    for (int i = 0; i < files.length; i++)
      if (checkBoxes[i])
        chosenFiles.add(files[i]);
    String fileToShare;
    if (chosenFiles.isEmpty)
      return "";
    if (chosenFiles.length == 1)
      fileToShare = chosenFiles[0];
    else {
      var encoder = ZipFileEncoder();
      var path = (await getApplicationDocumentsDirectory()).path + '/stats_${DateTime.now().year}:${DateTime.now().month}:${DateTime.now().day}:${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.zip';
    encoder.create(path);
    chosenFiles.forEach((element) { encoder.addFile(File(element)); });
    encoder.close();
    fileToShare = path;
  }
    return fileToShare;
  }

  Future<void> shareFiles() async {
    var fileToShare = await getChosenFiles();
    if (fileToShare.isEmpty)
      return;
    String fileName = fileToShare.substring(fileToShare.lastIndexOf('/') + 1);
    await Share.file(fileName.substring(fileName.lastIndexOf('.')), fileName, File(fileToShare).readAsBytesSync(), fileName.endsWith('.zip') ? 'application/zip' : 'text/plain')
        .then((value) =>
      fileName.endsWith('.zip') ? File(fileToShare).delete() : {}
    );
  }

  deleteFiles() async {
    var chosenFiles = [];
    for (int i = 0; i < files.length; i++)
      if (checkBoxes[i]) {
        var file = File(files[i]);
        if (file.existsSync()) {
          file.delete();
        }
      }
    loadStats();
  }

  download() async {

    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      status = await Permission.storage.request();
    }

    var filePath = await getChosenFiles();
    if (filePath.isNotEmpty) {
      var path = '';
      if (Platform.isIOS) {
        path = (await getDownloadsDirectory()).path;
      } else if (Platform.isAndroid) {
        path = '/storage/emulated/0/Download/';
      }
      var f = File(filePath);
      f.copy(path + filePath.substring(filePath.lastIndexOf('/') + 1)).then((value) => filePath.endsWith('.zip') ? File(filePath).delete() : {});
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Saved to downloads"),
        backgroundColor: Colors.lightBlueAccent[100].withOpacity(0.6),
        duration: Duration(milliseconds: 800),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.lightBlueAccent[100].withOpacity(0.6),
        child: loaded
            ? ListView.builder(
                itemCount: checkBoxes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.lightBlueAccent[100].withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    child: CheckboxListTile(
                      activeColor: Colors.green,
                      dense: true,
                      isThreeLine: false,
                      title: FittedBox(
                          fit: BoxFit.fill,
                          alignment: Alignment.centerLeft,
                          child: Text(files[index].split('/').last.replaceAll('.txt', ''),
                              style: TextStyle(color: Colors.black, fontSize: 20))),
                      value: checkBoxes[index],
                      onChanged: (value) {
                        setState(() {
                          checkBoxes[index] = !checkBoxes[index];
                        });
                      },
                    ),
                  );
                })
            :  SizedBox(
        width: 300,
        height: 300,
              child: CircularProgressIndicator(
                strokeWidth: 16,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConfirmationSlider(
              height: 60,
              width: 200,
              shadow: BoxShadow(color: Color.fromARGB(0, 0, 0, 0)),
              backgroundColor: Colors.redAccent[100],
              backgroundShape: BorderRadius.circular(30),
              icon: Icons.delete,
              textStyle: TextStyle(fontSize: 20, color: Colors.white),
              foregroundColor: Colors.redAccent,
              onConfirmation: () => deleteFiles(),
              onStarted:(){}
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 60,
              height: 60,
              child: RaisedButton(
                child: Icon(Icons.file_download, color: Colors.white),
                color: Colors.green,
                shape: CircleBorder(),
                onPressed: download,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 60,
              height: 60,
              child: RaisedButton(
                child: Icon(Icons.check, color: Colors.white),
                color: Colors.orange,
                shape: CircleBorder(),
                onPressed: () {
                  for (int i = 0; i < files.length; i++)
                    if (checkBoxes[i]) {
                      for (int j = 0; j < files.length; j++)
                        checkBoxes[j] = false;
                      setState(() {});
                      return;
                    } else
                    checkBoxes[i] = true;
                  setState(() {});
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 60,
              height: 60,
              child: RaisedButton(
                child: Icon(Icons.share, color: Colors.white),
                color: Colors.blueAccent,
                shape: CircleBorder(),
                onPressed: shareFiles,
              ),
            ),
          )
        ],
      ),
    );
  }

  loadStats(){
    Settings.loadStats().then((data) {
      setState(() {
        loaded = true;
        checkBoxes = List(data.length);
        checkBoxes.fillRange(0, data.length, false);
        files = data;
      });
    });
  }

  @override
  void initState() {
    loadStats();
    super.initState();
  }
}
