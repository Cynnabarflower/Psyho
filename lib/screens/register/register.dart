import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:psycho_app/screens/main/main_menu.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String userName;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
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
        child: SizedBox(
          width: 600,
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    fillColor: Colors.amber[20],
                    filled: true,
                    labelText: "Name",
                  ),
                  onChanged: (value) => {userName = value.trim()},
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FlatButton(
        color: Colors.amber[200],
        child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "OK",
                style: TextStyle(
                    color: Colors.black
                )
            )
        ),
        onPressed:  () {
          print(userName);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainMenu()),
          );
        },
      ),
    );
  }
}
