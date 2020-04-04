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

class _RegisterState extends State<Register> {
  String userName = "";
  String bDay = "";
  String editText = "";
  String qText = "What's your name?";
  var langs = [];
  Keyboard keyboard;

  Future<bool> loadSettings() async {
    await Settings.read('main').then((value) {
      if (value['fullScreen'])
        SystemChrome.setEnabledSystemUIOverlays([]);
      else
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
      if (value['lang'] != null) {
        langs = (value['lang']).map((e) => Layout.getKeyboardLangFromString(e)).toList();
      } else {
        langs = [KeyboardLangs.cyrillic_with_digits, KeyboardLangs.latin_with_digits];
      }
    });
    return true;
  }

  @override
  void initState() {
    editText = "";
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

    keyboard = Keyboard(
        onEdited: (value) {
          editText = value;
          value = userName.isEmpty ? editText.substring(0, editText.length < 25 ? editText.length : 25) : editText.substring(0, editText.length < 2 ? editText.length : 2);
          keyboard.setEditText(value);
          print(value);
         },
        initValue: "",
        layouts:
        userName.isEmpty ? (
            (langs.contains(KeyboardLangs.latin) ? [Layout.latin(showInputField: true)] : List<Layout>(0)) +
                (langs.contains(KeyboardLangs.cyrillic) ? [Layout.cyrillic(showInputField: true).addKeyBuilder(Layout.getStringKeyBuilder([[' ', 'OK']], keyRatio: 1), flex: 0.33)] : List<Layout>(0))
        ) : [Layout.numeric(showInputField: true)]
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
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
                  qText,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 14,
                      color: Colors.redAccent),
                ),
              ),
              keyboard
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: FlatButton(
          color: Colors.amber[200],
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(text: "OK", style: TextStyle(color: Colors.black))),
          onPressed: () {
            if (userName.isNotEmpty && editText.isNotEmpty) {
              bDay = editText;
            print(userName);
            Settings.save('session', {'name': userName, 'bDay' : bDay});
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainMenu()),
            );
          } else if (editText.isNotEmpty) {
              setState(() {
                if (keyboard != null) {
                  keyboard.setEditText('');
                }
                userName = editText;
                editText = "";
                qText = "How old are you?";
              });
            }
            },
        ),
      ),
    );
  }
}
