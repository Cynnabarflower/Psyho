import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psycho_app/routes.dart';

void main() {
  runApp(FadeAppTest());
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
}

class FadeAppTest extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MaterialApp(
        title: 'App',
        initialRoute: '/',
        routes: routes,
    );
  }


}
