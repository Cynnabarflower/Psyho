import 'package:flutter/material.dart';


class Balloons extends StatefulWidget {
  @override
  _BalloonsState createState() => _BalloonsState();
}

class _BalloonsState extends State<Balloons> {

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
          child : Text("Balloons")
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Fade',
        child: Icon(Icons.brush),
        onPressed: () {

        },
      ),
    );
  }
}