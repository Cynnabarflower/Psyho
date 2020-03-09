import 'package:flutter/cupertino.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/register/register.dart';
import 'package:psycho_app/screens/settings/settings.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/": (BuildContext context) => Register(),
  "/Settings": (BuildContext context) => Settings(),
};