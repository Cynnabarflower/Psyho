import 'package:flutter/cupertino.dart';
import 'package:psycho_app/screens/main/main_menu.dart';
import 'package:psycho_app/screens/register/register.dart';
import 'package:psycho_app/screens/settings/settings.dart';

import 'screens/language/language_choose.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/Language": (BuildContext context) => LanguageChoose(),
  "/Menu": (BuildContext context) => MainMenu(),
  "/Settings": (BuildContext context) => Settings(),
};