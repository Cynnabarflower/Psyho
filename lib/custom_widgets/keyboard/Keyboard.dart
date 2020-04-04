import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//will change later
String _editText = '';

class Keyboard extends StatefulWidget {
  List<Layout> layouts;
  Function onEdited;
  bool showInputField;
  bool isPassword;
  Widget child;
  bool visible;

  Keyboard({this.layouts, this.onEdited, initValue = "", this.child, this.visible = true, this.showInputField = null}) {
    _editText = initValue.toString();
  }

  setEditText(editText) {
    _editText = editText;
  }


  @override
  State createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  Layout currentLayout;
  int currentlayoutNumber = 0;
  double w, h;
  double textHeight;
  double textSize;

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return Stack(
        children: [
          widget.child,
          widget.visible ?
              LayoutBuilder(
                builder: (context, constraints) {
                  var size = MediaQuery.of(context).size;
                  w = size.width;
                  h = size.height * 2/3;
                  return SizedBox(
                    width: w,
                     height: h,
                     child:  _getKeyboard()
                  );
                },
              )
              : Container()
        ],
      );
    } else return widget.visible ? _getKeyboard() : Container();

  }

  Widget _getKeyboard() {
    if (widget.layouts.isNotEmpty) {
      updateLayouts();
      currentlayoutNumber %= widget.layouts.length;
      currentLayout = widget.layouts[currentlayoutNumber];
      return currentLayout;
    } else {
      return Container();
    }
  }

  void updateLayouts() {
    widget.layouts.forEach((element) {
      element.changeLayout = changeLayout;
      element.onEdited =
          (val) {setState(() {
        widget.onEdited(val);
      });};

      element.showInputField = widget.showInputField ?? element.showInputField;
      element.canChange = widget.layouts.length > 1;
    });
  }

  @override
  void initState() {
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
  AlignmentGeometry alignment;
  Function changeLayout;
  bool canChange = false;
  List<KeyBuilder> keyBuilders = [];
  Function onEdited;
  Function tapped;
  Function erase;
  double textHeightPercent = 0.2;
  double textSizePercent = 0.8;

  Layout(
      {
        this.textHeightPercent = 0.2,
        this.textSizePercent = 0.8,
      this.maxLength = 999,
      this.showInputField = false,
      this.isPassword = false,
      this.padding,
      this.margin,
      this.canChange = false,
      this.alignment,
      this.keyBuilders,
      });

  Layout.numeric(
      {
        this.textHeightPercent = 0.2,
      this.maxLength = 999,
      this.showInputField = false,
      this.isPassword = false,
      this.padding,
      this.margin,
      this.canChange = false,
      this.alignment}) {
    keyBuilders.add(KeyBuilder(getNumericKeyboard));
  }


  Layout.digital(
      {
        this.textHeightPercent = 0.2,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange = false,
        this.alignment}) {
    keyBuilders.add(KeyBuilder(getDigitsLine));
  }

  Layout.latin(
      {
        bool withDigits = false,
        this.textHeightPercent = 0.2,
        this.textSizePercent = 0.8,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange = false,
        this.alignment}) {
    keyBuilders.add(KeyBuilder(withDigits ? getLatinKeyboardWithDigits : getLatinKeyboard));
  }

  Layout.cyrillic(
      {
        bool withDigits = false,
        this.textHeightPercent = 0.2,
        this.textSizePercent = 0.8,
        this.maxLength = 999,
        this.showInputField = false,
        this.isPassword = false,
        this.padding,
        this.margin,
        this.canChange = false,
        this.alignment}) {
    keyBuilders.add(KeyBuilder(withDigits ? getCyrillicKeyboardWithDigits :   getCyrillicKeyboard));
  }

  Layout addKeyBuilder(dynamic kb, {double flex = -1, int index = -1}) {
    if (index == -1)
      index = keyBuilders.length;
    if (kb is KeyBuilder) {
      if (flex >= 0)
        keyBuilders.insert(index, KeyBuilder(kb.keyBuilder, flex: flex));
      else
        keyBuilders.insert(index, kb);
    } else if (kb is Function) {
      if (flex >= 0)
        keyBuilders.insert(index, KeyBuilder(kb, flex: flex));
      else
        keyBuilders.insert(index, KeyBuilder(kb));
    } else if (kb is Layout) {
      if (flex >= 0)
        keyBuilders.insert(index, KeyBuilder(kb.keyBuilders[0].keyBuilder, flex: flex));
      else
        keyBuilders.insert(index, kb.keyBuilders[0]);
    }

    return this;
  }

  static Function getStringKeyBuilder(List<List<dynamic>> keys, {double keyRatio = 1, strictResize = true}) {
    return (double w, double h, context, Layout widget) {
      var maxWidth = 0;
      keys.forEach((element) { maxWidth = max(maxWidth, element.fold(0, (p, e) => p + e.length)); });
      var params = _getFitParams(maxWidth, keys.length, w, h, ratio: keyRatio, strict: strictResize, context: context);
      var size = params.key;
      double ratio = params.value;
      List<Widget> children = [];
      for (var line in keys)
        children.add(getButtonListLine(widget.tapped, vals: line, size: size, borderRadius: 8, margin: 4, ratio: ratio, fontSize: 0.5, iconSize: 0.5));
      return Column(
        children: children,
      );

    };
  }

  static getButtonListLine(Function tapped,
      {List<dynamic> vals,
        double ratio,
        double margin: -1,
        double borderRadius: -1,
        double fontSize: -1,
        double iconSize = -1,
        Size size}) {
    List<_KeyboardButton> buttons = [];
    for (var i = 0; i < vals.length; i++) {
      var adjSize = Size(size.width * vals[i].length, size.height);
      buttons.add(_KeyboardButton(tapped, size: adjSize, text: vals[i]));
    }
    return getButtonsLine(buttons, ratio: ratio, margin: margin, borderRadius: borderRadius, fontSize: fontSize, iconSize: iconSize);
  }

  static getButtonSymbolLine(Function tapped,
      {String symbols,
        double ratio,
        double margin: -1,
        double borderRadius: -1,
        double fontSize: -1,
        double iconSize = -1,
        Size size}) {
    List<_KeyboardButton> buttons = [];
    for (var i = 0; i < symbols.length; i++)
      buttons.add(_KeyboardButton(tapped, size: size, text: symbols[i]));
    return getButtonsLine(buttons, ratio: ratio, margin: margin, borderRadius: borderRadius, fontSize: fontSize, iconSize: iconSize, size: size);
  }

  static Column getNumericKeyboard(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;

    var params = _getFitParams(3, 4, w, h, ratio: 1, strict: true, context: context);
    var size = params.key;
    double ratio = params.value;

    return
    Column (
        children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio, fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio, fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(tapped, text: '8'),
        _KeyboardButton(tapped, text: '9')
      ], borderRadius: 8, margin: 4, size: size, ratio: ratio, fontSize: 0.5),
      getButtonsLine(
          (canChange
              ? [
            _KeyboardButton((val) => widget.changeLayout(),
                iconData: Icons.language, size: size)
          ]
              : (List<_KeyboardButton>())) +
          [
        _KeyboardButton(tapped, text: '0', size: Size(size.width * (canChange ? 1 : 2), size.height), fontSize:  min(size.width, size.height) * 0.5),
        _KeyboardButton(erase,
            iconData: Icons.clear, size: size)
      ], ratio: ratio, borderRadius: 8, margin: 4, fontSize: 0.5, iconSize:  min(size.width, size.height) * 0.5)
    ]);
  }

  static Column getCyrillicKeyboard(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(12, 3, w, h, ratio: 3/4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;

    return
    Column(
      children: [
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
          fontSize: 0.5,
          iconSize: 1,
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
          fontSize: 0.5,
          size: buttonSize),
      getButtonsLine(
          ((canChange
                  ? [
                      _KeyboardButton((val) => widget.changeLayout(),
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
                _KeyboardButton(erase, iconData: Icons.cancel)
              ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          fontSize: 0.5,
          iconSize: 0.5,
          size: buttonSize)
    ]);
  }

  static Column getCyrillicKeyboardWithDigits(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(12, 4, w, h, ratio: 3/4, context: context);
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
          fontSize: 0.5,
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
          fontSize: 0.5,
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
          fontSize: 0.5,
          size: buttonSize),
      getButtonsLine(
          ((canChange
              ? [
            _KeyboardButton((val) => widget.changeLayout(),
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
          fontSize: 0.5,
          size: buttonSize)
    ]);
  }


  static Column getDigitsLine(double w, double h, context, Layout widget) {
    var tapped = widget.tapped;
    var params = _getFitParams(10, 1, w, h, ratio: 3/4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    return

      Column (
        children: [
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
                margin: margin, borderRadius: borderRadius, ratio: rowRatio, size: buttonSize, fontSize: 0.5)
          ]
      );
  }

  static MapEntry<Size, double> _getFitParams(
      int rowLength, int numberOfRows, double w, double h,
      {double ratio: 1, bool strict: false, context}) {
    double fitH = min(h, w / (rowLength / numberOfRows * ratio));
    if (strict) {
      if (h.isInfinite && context != null && MediaQuery.of(context).size.aspectRatio > 1) {
        
      }
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
        double iconSize = -1,
      Size size}) {
    ratio = ratio ?? buttons.length * (size == null ? 1.0 : size.aspectRatio);
    buttons.forEach((_KeyboardButton element) {
      if (margin >= 0) element.margin = margin;
      if (borderRadius > 0) element.borderRadius = borderRadius;
      if (fontSize > 1)
        element.fontSize = fontSize;
      else if (size != null)
        if (fontSize > 0)
          element.fontSize = min(size.width, size.height) * fontSize;
      if (iconSize > 1)
        element.iconSize = iconSize;
      else if (size != null)
        if (iconSize > 0)
          element.iconSize = min(size.width, size.height) * iconSize;

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


  static Column getLatinKeyboardWithDigits(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(10, 4, w, h, ratio: 3/4, context: context);
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
          fontSize: 0.5,
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
          fontSize: 0.5,
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
          fontSize: 0.5,
          size: buttonSize),
      getButtonsLine(
          (canChange
                  ? [
                      _KeyboardButton((val) => widget.changeLayout(),
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
          fontSize: 0.5,
          size: buttonSize)
    ]);
  }


  static Column getLatinKeyboard(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(10, 3, w, h, ratio: 3/4, context: context);
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
          fontSize: 0.5,
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
          fontSize: 0.5,
          margin: margin,
          size: buttonSize),
      getButtonsLine(
          (canChange
              ? [
            _KeyboardButton((val) => widget.changeLayout(),
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
          fontSize: 0.5,
          margin: margin,
          size: buttonSize)
    ]);
  }

  @override
  State<StatefulWidget> createState() => _KeyboardLayoutState();
}

class _KeyboardLayoutState extends State<Layout> {
  double textHeight;
  double textSize;
  double w, h;
  GlobalKey _inputField;

  @override
  Widget build(BuildContext context) {
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
            double totalFlex = widget.keyBuilders.fold(0, (previousValue, element) => previousValue + element.flex);
            Column kb;
            if (h.isFinite) {
              textHeight = h * widget.textHeightPercent;
              h -= textHeight + 2;
              kb = Column(
                children: widget.keyBuilders.fold([], (previousValue, element) {
                  previousValue.add(element.keyBuilder(w, h * element.flex/totalFlex, context, widget));
                  return previousValue;
                })
              );
            } else {
              kb = Column(
                  children: widget.keyBuilders.fold([], (previousValue, element) {
                    previousValue.add(element.keyBuilder(
                        w, h * element.flex / totalFlex, context, widget));
                    return previousValue;
                  }
                  )
              );
              textHeight = w * widget.textHeightPercent * 16/9;
            }
            textSize = min(textHeight * widget.textSizePercent, w / (
                1.3 * _editText.length - _editText.replaceAll(RegExp("([ШЩМЖЫQWM])"), "").length * 0.3
            ) * 1.0);
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
                                              ? _editText.replaceAll(
                                                  RegExp('[0-9]'), '*')
                                              : _editText,
                                          key: _inputField,
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
      _editText += s;
      widget.onEdited(_editText);
    });
  }

  void erase(String s) {
    setState(() {
    if (_editText.isNotEmpty)
      _editText = _editText.substring(0, _editText.length - 1);
    widget.onEdited(_editText);
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

   // fontSize = fontSize ?? (min(s.value.width, s.value.height) - margin);

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
              child: icon == null && text != ' '
                  ? Text(text,
                      style: TextStyle(fontSize: fontSize),
                      textAlign: TextAlign.center)
                  : Icon(icon == null ? Icons.space_bar: icon, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}

class KeyBuilder {
  Function keyBuilder;
  double flex = 1;

  KeyBuilder(this.keyBuilder, {this.flex = 1});

}
