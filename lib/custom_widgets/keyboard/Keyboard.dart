
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Keyboard extends StatefulWidget {

  Function edited;
  int maxLength;
  bool showInputField = false;
  bool isPassword = false;

  Keyboard(this.edited, {this.maxLength = 4, this.showInputField = false, this.isPassword = false});

  @override
  State<StatefulWidget> createState() => _KeyboardState();

}

class _KeyboardState extends State<Keyboard> {
  Widget keyboard;
  String editText = "";

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
          decoration: BoxDecoration(
              color: Colors.amberAccent,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.showInputField ? AspectRatio(
                aspectRatio: 3,
                child: Center(child: Text(widget.isPassword ? editText.replaceAll(RegExp('[0-9]'), '*') : editText, style: TextStyle(fontSize: 100, color: Colors.redAccent))),
              ) : Container(),
              AspectRatio(
                aspectRatio: 3,
                child: Row(children: [
                  _KeyboardButton(tapped, text: '1'),
                  _KeyboardButton(tapped, text: '2'),
                  _KeyboardButton(tapped, text: '3')
                ]),
              ),
              AspectRatio(
                aspectRatio: 3,
                child: Row(children: [
                  _KeyboardButton(tapped, text: '4'),
                  _KeyboardButton(tapped, text: '5'),
                  _KeyboardButton(tapped, text: '6'),
                ]),
              ),
              AspectRatio(
                aspectRatio: 3,
                child: Row(children: [
                  _KeyboardButton(tapped, text: '7'),
                  _KeyboardButton(tapped, text: '8'),
                  _KeyboardButton(tapped, text: '9'),
                ]),
              ),
              AspectRatio(
                aspectRatio: 3,
                child: Row(children: [
                  _KeyboardButton(tapped, text: '0', ratio: 2),
                  _KeyboardButton(erase, iconData: Icons.clear)
                ]),
              )
            ],
          ),
      );










    return
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(24, 2, 24, 2),
        decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.showInputField ? AspectRatio(
              aspectRatio: 3,
              child: Center(child: Text(widget.isPassword ? editText.replaceAll(RegExp('[0-9]'), '*') : editText, style: TextStyle(fontSize: 100, color: Colors.redAccent))),
            ) : Container(),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 8),
              child:Container(
                height:8.0,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: Row(children: [
                _KeyboardButton(tapped, text: '1'),
                _KeyboardButton(tapped, text: '2'),
                _KeyboardButton(tapped, text: '3')
              ]),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: Row(children: [
                _KeyboardButton(tapped, text: '4'),
                _KeyboardButton(tapped, text: '5'),
                _KeyboardButton(tapped, text: '6'),
              ]),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: Row(children: [
                _KeyboardButton(tapped, text: '7'),
                _KeyboardButton(tapped, text: '8'),
                _KeyboardButton(tapped, text: '9'),
              ]),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: Row(children: [
                _KeyboardButton(tapped, text: '0', ratio: 2),
                _KeyboardButton(erase, iconData: Icons.clear)
              ]),
            )
          ],
        ),
      );
  }

  @override
  void initState() {
    super.initState();
  }

  void tapped(String s) {
    setState(() {
      editText += s;
      widget.edited(editText);
      if (editText.length >= widget.maxLength)
        editText = "";
    });
  }

  void erase(String s) {
    setState(() {
      if (editText.isNotEmpty)
        editText = editText.substring(0, editText.length - 1);
      widget.edited(editText);
    });
  }

}

class _KeyboardButton extends StatefulWidget {

  String text = "";
  Function tapped;
  IconData iconData;
  Color color;
  double ratio;


  _KeyboardButton(this.tapped, {this.text, this.color, this.ratio = 1, this.iconData}) {
    print(ratio);
  }

  @override
  State createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<_KeyboardButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return getKeyboardButton(widget.text, tapped: widget.tapped, ratio: widget.ratio, icon: widget.iconData);
  }

  Widget getKeyboardButton(String text, {Function tapped, double ratio = 1, IconData icon}) {

    return AspectRatio(
      aspectRatio: ratio,
      child: GestureDetector(
        onTap: () {tapped(text);},
        onTapDown: (tapDownDetails) {
          setState(() {pressed = true;});
        },
        onTapCancel: () {
          setState(() {
            pressed = false;
          });
        },
        onTapUp: (tepUpDetails) {
          setState(() {
            pressed = false;
          });
        },
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.redAccent.withOpacity(pressed ? 0.66 : 1)),
          alignment: Alignment.center,
          child: icon == null ? Text(text, style: TextStyle(fontSize: 28),textAlign: TextAlign.center) : Icon(icon, size: 28),
        ),
      ),
    );
  }

}