import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Keyboard extends StatefulWidget {
  List<Layout> layouts;
  Function onEdited;
  bool showInputField;
  bool isPassword;
  String initValue;

  Keyboard({this.layouts, this.onEdited, this.initValue: ""}) {
    print('');
  }

  @override
  State createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  Layout currentLayout;
  int currentlayoutNumber = 0;
  double w, h;
  String editText;
  double textHeight;
  double textSize;

  @override
  Widget build(BuildContext context) {
    if (widget.layouts.isNotEmpty) {
      updateLayouts();
      currentLayout = widget.layouts[currentlayoutNumber];
      return currentLayout;
    } else {
      return Container();
    }
  }

  void updateLayouts() {
    widget.layouts.forEach((element) {
      if (widget.initValue != editText)
        setState(() {
          editText = widget.initValue;
        });
      element.changeLayout = changeLayout;
      element.onEdited =
          (val) {setState(() {
        editText = val;
        widget.initValue = editText;
        widget.onEdited(val);
      });};
      element.editText =  editText;
      element.canChange = widget.layouts.length > 1;
    });
  }

  @override
  void initState() {
    editText = widget.initValue;
    super.initState();
  }

  void changeLayout({Layout type}) {
    if (type != null) {
      currentLayout = type;
    } else {
      currentlayoutNumber = (currentlayoutNumber + 1) % widget.layouts.length;
      /*var i = widget.layouts.indexOf(currentLayout);
      i = i >= 0 ? (++i) % widget.layouts.length : 0;*/
      currentLayout = widget.layouts[currentlayoutNumber];
    }
    setState(() {});
  }
}

enum KeyboardLangs {
numeric,
digits,
latin,
latin_with_digits,
cyrillic,
cyrillic_with_digits,
}

class Layout extends StatefulWidget {

  static KeyboardLangs getKeyboardLangFromString(String s) {
    for (var e in KeyboardLangs.values) {
      if (e.toString() == s) {
        return e;
      }
    }
    return null;
  }

  int maxLength;
  bool showInputField = false;
  bool isPassword = false;
  EdgeInsetsGeometry padding;
  EdgeInsetsGeometry margin;
  String editText = "";
  AlignmentGeometry alignment;
  Function changeLayout;
  bool canChange = false;
  Function keyBuilder;
  Function onEdited;
  Function tapped;
  Function erase;
  double textHeightPercent = 0.2;

  Layout(
      {
        this.textHeightPercent = 0.2,
      this.maxLength = 999,
      this.showInputField = false,
      this.isPassword = false,
      this.padding,
      this.margin,
      this.canChange,
      this.alignment,
      this.keyBuilder,
      });

  Layout.numeric(
      {
        this.textHeightPercent = 0.2,
      this.maxLength = 999,
      this.showInputField = false,
      this.isPassword = false,
      this.padding,
      this.margin,
      this.canChange,
      this.alignment}) {
    this.keyBuilder = getNumericKeyboard;
  }


  Layout.digital(
      {
        this.textHeightPercent = 0.2,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange,
        this.alignment}) {
    this.keyBuilder = getDigitsLine;
  }

  Layout.latin(
      {
        bool withDigits = false,
        this.textHeightPercent = 0.2,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange,
        this.alignment}) {
    this.keyBuilder = withDigits ? getLatinKeyboardWithDigits : getLatinKeyboard;
  }

  Layout.cyrillic(
      {
        bool withDigits = false,
        this.textHeightPercent = 0.2,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange,
        this.alignment}) {
    this.keyBuilder = withDigits ? getCyrillicKeyboardWithDigits : getCyrillicKeyboard;
  }

  Column getNumericKeyboard(double w, double h) {
    var params = _getFitParams(3, 4, w, h, ratio: 1, strict: true);
    var size = params.key;
    double ratio = params.value;
    return
    Column (
        children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio),
      getButtonsLine([
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio),
      getButtonsLine([
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(tapped, text: '8'),
        _KeyboardButton(tapped, text: '9')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio),
      getButtonsLine(
          (canChange
              ? [
            _KeyboardButton((val) => changeLayout(),
                iconData: Icons.language, size: size)
          ]
              : (List<_KeyboardButton>())) +
          [
        _KeyboardButton(tapped, text: '0', size: Size(size.width * (canChange ? 1 : 2), size.height)),
        _KeyboardButton(erase,
            iconData: Icons.clear, size: size)
      ], ratio: ratio, borderRadius: 8, margin: 4)
    ]);
  }

  Column getCyrillicKeyboard(double w, double h) {
    var params = _getFitParams(12, 3, w, h, ratio: 3/4);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;

    return
    Column(
      children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Й', fontSize: 23),
        _KeyboardButton(tapped, text: 'Ц', fontSize: 24),
        _KeyboardButton(tapped, text: 'У', fontSize: 24),
        _KeyboardButton(tapped, text: 'К', fontSize: 24),
        _KeyboardButton(tapped, text: 'Е', fontSize: 24),
        _KeyboardButton(tapped, text: 'Н', fontSize: 24),
        _KeyboardButton(tapped, text: 'Г', fontSize: 24),
        _KeyboardButton(tapped, text: 'Ш', fontSize: 24),
        _KeyboardButton(tapped, text: 'Щ', fontSize: 24),
        _KeyboardButton(tapped, text: 'З', fontSize: 24),
        _KeyboardButton(tapped, text: 'Х', fontSize: 24),
        _KeyboardButton(tapped, text: 'Ъ', fontSize: 24)
      ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          size: buttonSize),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Ф'),
        _KeyboardButton(tapped, text: 'Ы'),
        _KeyboardButton(tapped, text: 'В'),
        _KeyboardButton(tapped, text: 'А'),
        _KeyboardButton(tapped, text: 'П'),
        _KeyboardButton(tapped, text: 'Р'),
        _KeyboardButton(tapped, text: 'О'),
        _KeyboardButton(tapped, text: 'Л'),
        _KeyboardButton(tapped, text: 'Д'),
        _KeyboardButton(tapped, text: 'Ж'),
        _KeyboardButton(tapped, text: 'Э')
      ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 24,
          size: buttonSize),
      getButtonsLine(
          ((canChange
                  ? [
                      _KeyboardButton((val) => changeLayout(),
                          iconData: Icons.language)
                    ]
                  : List<_KeyboardButton>(0))) +
              [
                _KeyboardButton(tapped, text: 'Я'),
                _KeyboardButton(tapped, text: 'Ч'),
                _KeyboardButton(tapped, text: 'С'),
                _KeyboardButton(tapped, text: 'М'),
                _KeyboardButton(tapped, text: 'И'),
                _KeyboardButton(tapped, text: 'Т'),
                _KeyboardButton(tapped, text: 'Ь'),
                _KeyboardButton(tapped, text: 'Б'),
                _KeyboardButton(tapped, text: 'Ю'),
                _KeyboardButton(erase, iconData: Icons.cancel, iconSize: 24)
              ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 24,
          size: buttonSize)
    ]);
  }

  Column getCyrillicKeyboardWithDigits(double w, double h) {
    var params = _getFitParams(12, 4, w, h, ratio: 3/4);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    return
      Column(
        children:
    [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3'),
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6'),
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(tapped, text: '8'),
        _KeyboardButton(tapped, text: '9'),
        _KeyboardButton(tapped, text: '0')
      ],
          ratio: rowRatio * 12/10,
          margin: margin,
          borderRadius: borderRadius,
          size: Size(buttonSize.width * 12/10, buttonSize.height)),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Й'),
        _KeyboardButton(tapped, text: 'Ц'),
        _KeyboardButton(tapped, text: 'У'),
        _KeyboardButton(tapped, text: 'К'),
        _KeyboardButton(tapped, text: 'Е'),
        _KeyboardButton(tapped, text: 'Н'),
        _KeyboardButton(tapped, text: 'Г'),
        _KeyboardButton(tapped, text: 'Ш'),
        _KeyboardButton(tapped, text: 'Щ'),
        _KeyboardButton(tapped, text: 'З'),
        _KeyboardButton(tapped, text: 'Х'),
        _KeyboardButton(tapped, text: 'Ъ')
      ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 24,
          size: buttonSize),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Ф'),
        _KeyboardButton(tapped, text: 'Ы'),
        _KeyboardButton(tapped, text: 'В'),
        _KeyboardButton(tapped, text: 'А'),
        _KeyboardButton(tapped, text: 'П'),
        _KeyboardButton(tapped, text: 'Р'),
        _KeyboardButton(tapped, text: 'О'),
        _KeyboardButton(tapped, text: 'Л'),
        _KeyboardButton(tapped, text: 'Д'),
        _KeyboardButton(tapped, text: 'Ж'),
        _KeyboardButton(tapped, text: 'Э')
      ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 24,
          size: buttonSize),
      getButtonsLine(
          ((canChange
              ? [
            _KeyboardButton((val) => changeLayout(),
                iconData: Icons.language)
          ]
              : List<_KeyboardButton>(0))) +
              [
                _KeyboardButton(tapped, text: 'Я'),
                _KeyboardButton(tapped, text: 'Ч'),
                _KeyboardButton(tapped, text: 'С'),
                _KeyboardButton(tapped, text: 'М'),
                _KeyboardButton(tapped, text: 'И'),
                _KeyboardButton(tapped, text: 'Т'),
                _KeyboardButton(tapped, text: 'Ь'),
                _KeyboardButton(tapped, text: 'Б'),
                _KeyboardButton(tapped, text: 'Ю'),
                _KeyboardButton(erase, iconData: Icons.cancel, iconSize: 24)
              ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 24,
          size: buttonSize)
    ]);
  }


  List<Widget> getDigitsLine(double w, double h) {
    var params = _getFitParams(10, 1, w, h, ratio: 3/4);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    return [
            getButtonsLine([
              _KeyboardButton(tapped, text: '1'),
              _KeyboardButton(tapped, text: '2'),
              _KeyboardButton(tapped, text: '3'),
              _KeyboardButton(tapped, text: '4'),
              _KeyboardButton(tapped, text: '5'),
              _KeyboardButton(tapped, text: '6'),
              _KeyboardButton(tapped, text: '7'),
              _KeyboardButton(tapped, text: '8',),
              _KeyboardButton(tapped, text: '9'),
              _KeyboardButton(tapped, text: '0'),
            ],
                margin: margin, borderRadius: borderRadius, ratio: rowRatio, size: buttonSize)
          ];
  }

  static MapEntry<Size, double> _getFitParams(
      int rowLength, int numberOfRows, double w, double h,
      {double ratio: 1, bool strict: false}) {
    double fitH = min(h, w / (rowLength / numberOfRows * ratio));
    if (strict) {
      var size = Size(fitH / numberOfRows * ratio, fitH / numberOfRows);
      return MapEntry(size, w / size.height);
    }
    double kh = fitH / numberOfRows;
    Size size = Size(fitH == h ? w / rowLength : kh * ratio, kh);
    return MapEntry(size, size.aspectRatio * rowLength);
  }

  static Widget getButtonsLine(List<_KeyboardButton> buttons,
      {double ratio,
      double margin: -1,
      double borderRadius: -1,
      double fontSize: -1,
      Size size}) {
    ratio = ratio ?? buttons.length * (size == null ? 1.0 : size.aspectRatio);
    buttons.forEach((_KeyboardButton element) {
      if (margin >= 0) element.margin = margin;
      if (borderRadius > 0) element.borderRadius = borderRadius;
      if (fontSize > 0) element.fontSize = fontSize;
      if (size != null) element.size = size;
    });

    return AspectRatio(
      aspectRatio: ratio,
      child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons,
          mainAxisAlignment: MainAxisAlignment.center),
    );
  }


  Column getLatinKeyboardWithDigits(double w, double h) {
    var params = _getFitParams(10, 4, w, h, ratio: 3/4);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    return Column(
        children:
     [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3'),
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6'),
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(tapped, text: '8'),
        _KeyboardButton(tapped, text: '9'),
        _KeyboardButton(tapped, text: '0')
      ],
          ratio: rowRatio,
          margin: margin,
          borderRadius: borderRadius,
          size: buttonSize),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Q'),
        _KeyboardButton(tapped, text: 'W'),
        _KeyboardButton(tapped, text: 'E'),
        _KeyboardButton(tapped, text: 'R'),
        _KeyboardButton(tapped, text: 'T'),
        _KeyboardButton(tapped, text: 'Y'),
        _KeyboardButton(tapped, text: 'U'),
        _KeyboardButton(tapped, text: 'I'),
        _KeyboardButton(tapped, text: 'O'),
        _KeyboardButton(tapped, text: 'P')
      ],
          size: buttonSize,
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'A'),
        _KeyboardButton(tapped, text: 'S'),
        _KeyboardButton(tapped, text: 'D'),
        _KeyboardButton(tapped, text: 'F'),
        _KeyboardButton(tapped, text: 'G'),
        _KeyboardButton(tapped, text: 'H'),
        _KeyboardButton(tapped, text: 'J'),
        _KeyboardButton(tapped, text: 'K'),
        _KeyboardButton(tapped, text: 'L'),
      ],
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin,
          size: buttonSize),
      getButtonsLine(
          (canChange
                  ? [
                      _KeyboardButton((val) => changeLayout(),
                          iconData: Icons.language)
                    ]
                  : (List<_KeyboardButton>())) +
              [
                _KeyboardButton(tapped, text: 'Z'),
                _KeyboardButton(tapped, text: 'X'),
                _KeyboardButton(tapped, text: 'C'),
                _KeyboardButton(tapped, text: 'V'),
                _KeyboardButton(tapped, text: 'B'),
                _KeyboardButton(tapped, text: 'N'),
                _KeyboardButton(tapped, text: 'M'),
                _KeyboardButton(erase, iconData: Icons.cancel)
              ],
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin,
          size: buttonSize)
    ]);
  }


  Column getLatinKeyboard(double w, double h) {
    var params = _getFitParams(10, 3, w, h, ratio: 3/4);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    return Column(
        children:
     [
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Q'),
        _KeyboardButton(tapped, text: 'W'),
        _KeyboardButton(tapped, text: 'E'),
        _KeyboardButton(tapped, text: 'R'),
        _KeyboardButton(tapped, text: 'T'),
        _KeyboardButton(tapped, text: 'Y'),
        _KeyboardButton(tapped, text: 'U'),
        _KeyboardButton(tapped, text: 'I'),
        _KeyboardButton(tapped, text: 'O'),
        _KeyboardButton(tapped, text: 'P')
      ],
          size: buttonSize,
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'A'),
        _KeyboardButton(tapped, text: 'S'),
        _KeyboardButton(tapped, text: 'D'),
        _KeyboardButton(tapped, text: 'F'),
        _KeyboardButton(tapped, text: 'G'),
        _KeyboardButton(tapped, text: 'H'),
        _KeyboardButton(tapped, text: 'J'),
        _KeyboardButton(tapped, text: 'K'),
        _KeyboardButton(tapped, text: 'L'),
      ],
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin,
          size: buttonSize),
      getButtonsLine(
          (canChange
              ? [
            _KeyboardButton((val) => changeLayout(),
                iconData: Icons.language)
          ]
              : (List<_KeyboardButton>())) +
              [
                _KeyboardButton(tapped, text: 'Z'),
                _KeyboardButton(tapped, text: 'X'),
                _KeyboardButton(tapped, text: 'C'),
                _KeyboardButton(tapped, text: 'V'),
                _KeyboardButton(tapped, text: 'B'),
                _KeyboardButton(tapped, text: 'N'),
                _KeyboardButton(tapped, text: 'M'),
                _KeyboardButton(erase, iconData: Icons.cancel)
              ],
          ratio: rowRatio,
          borderRadius: borderRadius,
          margin: margin,
          size: buttonSize)
    ]);
  }

  @override
  State<StatefulWidget> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<Layout> {
  String editText;
  double textHeight;
  double textSize;
  double w, h;

  _KeyboardLayoutState();

  @override
  Widget build(BuildContext context) {

    editText = widget.editText;
    widget.erase = erase;
    widget.tapped = tapped;
    return Expanded(
      child: Container(
        alignment: widget.alignment ?? Alignment.center,
        padding: widget.padding ?? EdgeInsets.all(8),
        margin: widget.margin ?? EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child:
          LayoutBuilder(builder: (context, constraints) {
            w = constraints.maxWidth;
            h = constraints.maxHeight;
            Column kb;
            if (h.isFinite) {
              textHeight = h * widget.textHeightPercent;
              h -= textHeight*1.03 + 2;
              kb = widget.keyBuilder(w, h);
            } else {
              kb = widget.keyBuilder(w, h);
              textHeight = w * widget.textHeightPercent * 16/9;
            }

            textSize = min(textHeight, w / (editText.length) * 1.0);
            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                      widget.showInputField
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                  Container(
                                      height: textHeight,
                                      alignment: Alignment.center,
                                      child: Text(
                                          widget.isPassword
                                              ? editText.replaceAll(
                                                  RegExp('[0-9]'), '*')
                                              : editText,
                                          style: TextStyle(
                                            fontSize: textSize,
                                            color: Colors.redAccent,
                                            textBaseline: TextBaseline.alphabetic,
                                          ))),
                                ])
                          : Container()
                ,kb
                ]
                    );
          }),

      ),
    );
  }

/*
  List<Widget> getLayout(LayoutType type) {
    double kh = h;
    switch (type) {
      case LayoutType.numeric:
        return getNumericKeyboard(w,kh);
      case LayoutType.latin_with_digits:
        return getDigitsLine(ratio: 10) + getLatinKeyboard(w,kh);
      case LayoutType.latin:
        return getLatinKeyboard(w,kh);
      case LayoutType.cyrillic_with_digits:
        return getDigitsLine(ratio: 12) + getCyrillicKeyboard();
      case LayoutType.cyrillic:
        return getCyrillicKeyboard();
      case LayoutType.digits:
        return getDigitsLine();
    }

  }
*/
  void tapped(String s) {
    setState(() {
      widget.editText += s;
      widget.onEdited(widget.editText);
    });
  }

  void erase(String s) {
    setState(() {
    if (widget.editText.isNotEmpty)
      widget.editText = widget.editText.substring(0, widget.editText.length - 1);
    widget.onEdited(widget.editText);
    });
  }


  @override
  void initState() {
    super.initState();
  }
}

class _KeyboardButton extends StatefulWidget {
  String text = "";
  Function tapped;
  IconData iconData;
  Color color;
  double margin;
  double borderRadius;
  double fontSize;
  double iconSize;
  double w;
  double h;
  Size size;

  _KeyboardButton(this.tapped,
      {this.size,
      this.text,
      this.color,
      this.iconData,
      this.margin: 2,
      this.borderRadius: 2,
      this.fontSize: 28,
      this.iconSize: 28}) {}

  @override
  State createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<_KeyboardButton> {
  bool pressed = false;
  GlobalKey _key = GlobalKey();
  ValueNotifier<Size> s;

  @override
  Widget build(BuildContext context) {
    s = ValueNotifier(widget.size);
    return getKeyboardButton(widget.text,
        w: widget.w,
        h: widget.w,
        tapped: widget.tapped,
        icon: widget.iconData,
        margin: widget.margin,
        borderRadius: widget.borderRadius,
        fontSize: widget.fontSize,
        iconSize: widget.iconSize);
  }

  Widget getKeyboardButton(String text,
      {double w,
      double h,
      Function tapped,
      IconData icon,
      double margin: 8,
      double borderRadius: 8,
      double fontSize: 28,
      double iconSize: 28}) {
    return ValueListenableBuilder(
      valueListenable: s,
      builder: (context, value, child) => SizedBox(
        width: s.value.width,
        height: s.value.height,
        child: GestureDetector(
          onTapDown: (tapDownDetails) {
            setState(() {
              pressed = true;
            });
          },
          onTap: () {
              tapped(text);
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
            alignment: Alignment.center,
            margin: EdgeInsets.all(margin),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                color: Colors.redAccent.withOpacity(pressed ? 0.66 : 1)),
            child: FittedBox(
              fit: BoxFit.fill,
              child: icon == null
                  ? Text(text,
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center)
                  : Icon(icon, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
