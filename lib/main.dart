import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
      theme: ThemeData(
        textTheme: GoogleFonts.comfortaaTextTheme(
          Theme.of(context).textTheme.copyWith(
            bodyText1: GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            bodyText2:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            button:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            caption:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline1:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            subtitle1:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            subtitle2:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            overline:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline2:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline3:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline4:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline5:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
            headline6:  GoogleFonts.comfortaa(fontWeight: FontWeight.w700),
          )
      )
      ),
    );
  }


}
