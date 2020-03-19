import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {

  @override
  _Settings createState() => _Settings();

  Map<String, Map<String, String>> map;

  Settings() {
    map = defaultSettings();
  }

  Map<String, Map<String, String>> defaultSettings() {
    map = Map<String, Map<String, String>>();
    var settings = Map<String, String>();
  }

}

class _Settings extends State<Settings> {

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
    return Scaffold(

      body: Center(
        child : DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.directions_car)),
                  Tab(icon: Icon(Icons.directions_transit)),
                  Tab(icon: Icon(Icons.directions_bike)),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                SettingsPage({

                }),
                SettingsPage({

                })
              ],
            ),
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Fade',
        child: Icon(Icons.brush),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {

  Map<String, List<dynamic>> map;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Param(),
    );
  }

  SettingsPage(this.map);

}


class Param extends StatefulWidget {

  Map<String, List<dynamic>> map;


  @override
  State<StatefulWidget> createState() {
    _ParamState();
  }
}

class _ParamState extends State {
  List<bool> isSelected = List(4);

  @override
  Widget build(BuildContext context) {
    return
      ToggleButtons(
        children: <Widget>[
          Icon(Icons.ac_unit),
          Icon(Icons.call),
          Icon(Icons.cake),
        ],
        onPressed: (int index) {
          setState(() {
            for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
              if (buttonIndex == index) {
                isSelected[buttonIndex] = true;
              } else {
                isSelected[buttonIndex] = false;
              }
            }
          });
        },
        isSelected: isSelected,
      );
  }
}

_read() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'my_int_key';
  final value = prefs.getInt(key) ?? 0;
  print('read: $value');
}

_save() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'my_int_key';
  final value = 42;
  prefs.setInt(key, value);
  print('saved $value');
}