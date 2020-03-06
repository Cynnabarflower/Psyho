import 'package:flutter/material.dart';
import 'package:psycho_app/routes.dart';

void main() {
  runApp(FadeAppTest());
}

class FadeAppTest extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ExampleApp',
        initialRoute: '/',
        routes: routes,
    );
  }


}
