import 'package:flutter/cupertino.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/settings/settings.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => MainMenu(),
  "/Settings": (BuildContext context) => Settings(),
};