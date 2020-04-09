import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

bool isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

class Keyboard extends StatefulWidget {
  List<Layout> layouts;
  Function onEdited;
  Function done;
  bool showInputField;
  bool isPassword;
  Widget child;
  bool visible;
  bool canChange = false;
  String _editText = '';
  InputField inputField;

  setInputField(InputField inputField) {
    this.inputField = inputField;
    inputField.text = _editText;
    return this;
  }

  Keyboard(
      {this.layouts,
      this.onEdited,
      initValue = "",
      this.child,
      this.visible = true,
      this.canChange,
      this.showInputField = false,
      this.done}) {
    _editText = initValue.toString();
    isPassword = isPassword ?? false;
    showInputField = showInputField ?? false;
    done = done ?? () {};
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
        children: [widget.child, widget.visible ? _getKeyboard() : Container()],
      );
    } else if (widget.visible) {
      return Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: <Widget>[
              Flexible(
                  flex: 1,
                  child: widget.showInputField && widget.inputField != null?
                  ()  {widget.inputField.text = widget._editText; return widget.inputField; }.call()
                  :
                  Container()
              ),
              Flexible(
                  flex: constraints.maxWidth > constraints.maxHeight ? 1 : 1,
                  child: Container(child: _getKeyboard()))
            ],
          ),
        ),
      );
    }

    return Container();
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
    widget.canChange = widget.canChange ?? widget.layouts.length > 1;
    widget.layouts.forEach((element) {
      element.changeLayout = changeLayout;
      element._editText = widget._editText;
      element.onEdited = (val) {
        setState(() {
          widget.onEdited(val);
        });
      };
      element.canChange = widget.canChange;
      ValueNotifier(widget._editText).addListener(() {
        element._editText = widget._editText;
      });
      ValueNotifier(element._editText).addListener(() {
        widget._editText = element._editText;
      });
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
  Size layoutSize;
  String _editText = '';

  Layout({
    this.textHeightPercent = 0.2,
    this.textSizePercent = 0.8,
    this.maxLength = 999,
    this.isPassword = false,
    this.padding,
    this.margin,
    this.canChange = false,
    this.alignment,
    this.keyBuilders,
  }) {
    padding = padding ?? EdgeInsets.all(8);
    margin = margin ?? EdgeInsets.all(8);
    textSizePercent = textSizePercent ?? 0.8;
    textHeightPercent = textHeightPercent ?? 0.2;

  }

  Layout.numeric(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [KeyBuilder(getNumericKeyboard)]);

  Layout.digital(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [KeyBuilder(getDigitsLine)]);

  Layout.latin(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      withDigits = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [
              KeyBuilder(
                  withDigits ? getLatinKeyboardWithDigits : getLatinKeyboard)
            ]);

  Layout.cyrillic(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      withDigits = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [
              KeyBuilder(withDigits
                  ? getCyrillicKeyboardWithDigits
                  : getCyrillicKeyboard)
            ]);

  Layout.month(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      withDigits = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [KeyBuilder(getMonthsKeyboard)]);

  Layout.dayMonth(
      {textHeightPercent = 0.2,
        maxLength = 999,
        isPassword = false,
        padding,
        margin,
        canChange = false,
        withDigits = false,
        alignment})
      : this(
      textHeightPercent: textHeightPercent,
      maxLength: maxLength,
      isPassword: isPassword,
      padding: padding,
      margin: margin,
      canChange: canChange,
      alignment: alignment,
      keyBuilders: [KeyBuilder(getDayMonthsKeyboard)]);

  Layout.gender(
      {textHeightPercent = 0.2,
      maxLength = 999,
      isPassword = false,
      padding,
      margin,
      canChange = false,
      withDigits = false,
      alignment})
      : this(
            textHeightPercent: textHeightPercent,
            maxLength: maxLength,
            isPassword: isPassword,
            padding: padding,
            margin: margin,
            canChange: canChange,
            alignment: alignment,
            keyBuilders: [KeyBuilder(getGenderKeyboard)]);

  void updateSize(w, h) {
    layoutSize = Size(w + padding.horizontal, h + padding.vertical);
  }

  Layout addKeyBuilder(dynamic kb, {double flex = -1, int index = -1}) {
    if (index == -1) index = keyBuilders.length;
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
        keyBuilders.insert(
            index, KeyBuilder(kb.keyBuilders[0].keyBuilder, flex: flex));
      else
        keyBuilders.insert(index, kb.keyBuilders[0]);
    }

    return this;
  }

  static Function getStringKeyBuilder(List<List<dynamic>> keys,
      {double keyRatio = 1, strictResize = true}) {
    return (double w, double h, context, Layout widget) {
      var maxWidth = 0;
      keys.forEach((element) {
        maxWidth = max(maxWidth, element.fold(0, (p, e) => p + e.length));
      });
      var params = _getFitParams(maxWidth, keys.length, w, h,
          ratio: keyRatio, strict: strictResize, context: context);
      var size = params.key;
      double ratio = params.value;
      List<Widget> children = [];
      for (var line in keys)
        children.add(getButtonListLine(widget.tapped,
            vals: line,
            size: size,
            borderRadius: 8,
            margin: 4,
            ratio: ratio,
            fontSize: 0.5,
            iconSize: 0.5));
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
    return getButtonsLine(buttons,
        ratio: ratio,
        margin: margin,
        borderRadius: borderRadius,
        fontSize: fontSize,
        iconSize: iconSize);
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
    return getButtonsLine(buttons,
        ratio: ratio,
        margin: margin,
        borderRadius: borderRadius,
        fontSize: fontSize,
        iconSize: iconSize,
        size: size);
  }

  static Column getMonthsKeyboard(double w, double h, context, Layout widget, {tapped, erase}) {
    erase = erase ?? widget.erase;
    var tapped0 = widget.tapped;
    tapped = tapped ?? (s) {
      widget._editText = "";
      if (s is List)
        s = s[0];
      tapped0(s);
    };

    var params =
    _getFitParams(3, 4, w, h, ratio: 2.6, strict: false, context: context);
    var size = params.key;
    double borderRadius = min(size.height, size.height) * 0.15;
    double margin =  min(size.height, size.height) * 0.05;
    double ratio = params.value;
    widget.updateSize((size.width) * 3, size.height * 4);
    return Column(children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Декабрь', value: ['декабрь','декабря'], color: Colors.lightBlueAccent[100]),
        _KeyboardButton(tapped, text: 'Январь', value: ['январь','января'], color: Colors.lightBlueAccent[100]),
        _KeyboardButton(tapped, text: 'Февраль', value: ['февраль', 'февраля'], color: Colors.lightBlueAccent[100])
      ],
          borderRadius: borderRadius,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Март',value: ['март', 'марта'], color: Colors.lime),
        _KeyboardButton(tapped, text: 'Апрель',value: ['апрель', 'апреля'], color: Colors.lime),
        _KeyboardButton(tapped, text: 'Май',value: ['май', 'мая'], color: Colors.lime)
      ],
          borderRadius: borderRadius,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Июнь',value: ['июнь', 'июня'], color: Colors.green),
        _KeyboardButton(tapped, text: 'Июль',value: ['июль', 'июля'], color: Colors.green),
        _KeyboardButton(tapped, text: 'Август',value: ['август', 'августа'], color: Colors.green)
      ],
          borderRadius: borderRadius,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: 'Сентябрь', value: ['сентябрь', 'сентября'], color: Colors.orangeAccent),
        _KeyboardButton(tapped, text: 'Октябрь', value: ['октябрь', 'октября'], color: Colors.orangeAccent),
        _KeyboardButton(tapped, text: 'Ноябрь', value: ['ноябрь', 'ноября'], color: Colors.orangeAccent)
      ],
          borderRadius: borderRadius,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
    ]);
  }

  static Column getDayMonthsKeyboard(double w, double h, context, Layout widget) {

    var tappedNum = (String s) {
      if (widget._editText.length > 0 && isDigit(widget._editText, 0)) {
        if (widget._editText.length > 1 && isDigit(widget._editText, 1)) {
          widget._editText = s + (widget._editText.length > 2 ? widget._editText.substring(2) : '');
        } else {
          widget._editText = widget._editText[0] + s + (widget._editText.length > 1 && widget._editText[1] == ' ' ? '' : ' ') + (widget._editText.length > 1 ? widget._editText.substring(1) : '');
        }

      } else {
        if (widget._editText.length > 0 &&  widget._editText[0] == ' ')
          widget._editText = s + widget._editText;
        else
          widget._editText = s +' '+ widget._editText;
      }
      widget.tapped('');
    };

    var tappedMonth = (s) {
      if (widget._editText.length > 0 && isDigit(widget._editText, 0)) {
        if (s is List)
          s = s[1];
        if (widget._editText.length > 1 && isDigit(widget._editText, 1)) {
          widget._editText = widget._editText.substring(0, 2) + ' ' + s;
        } else
          widget._editText = widget._editText.substring(0, 1) + ' ' + s;
      } else {
        if (s is List)
          s = s[1];
        widget._editText = s;
      }
      widget.tapped('');
    };


    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
                width: w/3.6 - 1,
                child: getNumericKeyboard(w/3.6 - 1, h, context, widget, tapped: tappedNum, showErase: false)),
            SizedBox(width: 4),
            SizedBox(
                width: w*2.6/3.6 - 3,
                child: getMonthsKeyboard(w*2.6/3.6 - 3, h, context, widget, tapped: tappedMonth)),
          ],
        )
      ],
    );
  }

  static Column getGenderKeyboard(double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped0 = widget.tapped;
    var tapped = (s) {
      widget._editText = "";
      tapped0(s);
    };
    double margin = 4;

    var params =
        _getFitParams(2, 1, w, h, ratio: 1, strict: true, context: context);
    var size = params.key;
    double ratio = params.value;
    widget.updateSize((size.width) * 2, size.height * 1);
    return Column(children: [
      getButtonsLine([
        _KeyboardButton(tapped, value: 'M', image: Image.asset('assets/male.png')),
        _KeyboardButton(tapped, value: 'F', image: Image.asset('assets/female.png')),
      ],
          borderRadius: 8,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5)
    ]);
  }

  static Column getNumericKeyboard(double w, double h, context, Layout widget, {tapped, erase, showErase = true}) {
    erase = erase ?? widget.erase;
    tapped = tapped ??  widget.tapped;
    var canChange = widget.canChange;

    var params =
        _getFitParams(3, 4, w, h, ratio: 1, strict: true, context: context);
    var size = params.key;
    double borderRadius = min(size.height, size.height) * 0.05;
    double margin =  min(size.height, size.height) * 0.05;
    double ratio = params.value;
    widget.updateSize((size.width) * 3, size.height * 4);
    return Column(children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3')
      ],
          borderRadius: 8,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6')
      ],
          borderRadius: 8,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine([
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(tapped, text: '8'),
        _KeyboardButton(tapped, text: '9')
      ],
          borderRadius: 8,
          margin: margin,
          size: size,
          ratio: ratio,
          fontSize: 0.5),
      getButtonsLine(
          (canChange
                  ? [
                      _KeyboardButton((val) => widget.changeLayout(),
                          iconData: Icons.language, size: size)
                    ]
                  : (List<_KeyboardButton>())) +
              [
                _KeyboardButton(tapped,
                    text: '0',
                    size: Size(size.width * (canChange && showErase ? 1 : canChange || showErase ? 2 : 3), size.height),
                    fontSize: min(size.width, size.height) * 0.5)
              ] +
              (showErase ? [ _KeyboardButton(erase, iconData: Icons.clear, size: size)] : [])
          ,
          ratio: ratio,
          borderRadius: 8,
          margin: margin,
          fontSize: 0.5,
          iconSize: min(size.width, size.height) * 0.5)
    ]);
  }

  static Column getCyrillicKeyboard(
      double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(12, 3, w, h, ratio: 3 / 4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    widget.updateSize((buttonSize.width) * 12, buttonSize.height * 3);

    return Column(children: [
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

  static Column getCyrillicKeyboardWithDigits(
      double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(12, 4, w, h, ratio: 3 / 4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    widget.updateSize((buttonSize.width) * 12, buttonSize.height * 4);
    return Column(children: [
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
          ratio: rowRatio * 12 / 10,
          fontSize: 0.5,
          margin: margin,
          borderRadius: borderRadius,
          size: Size(buttonSize.width * 12 / 10, buttonSize.height)),
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
    var params = _getFitParams(10, 1, w, h, ratio: 3 / 4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    widget.updateSize((buttonSize.width) * 10, buttonSize.height * 1);
    return Column(children: [
      getButtonsLine([
        _KeyboardButton(tapped, text: '1'),
        _KeyboardButton(tapped, text: '2'),
        _KeyboardButton(tapped, text: '3'),
        _KeyboardButton(tapped, text: '4'),
        _KeyboardButton(tapped, text: '5'),
        _KeyboardButton(tapped, text: '6'),
        _KeyboardButton(tapped, text: '7'),
        _KeyboardButton(
          tapped,
          text: '8',
        ),
        _KeyboardButton(tapped, text: '9'),
        _KeyboardButton(tapped, text: '0'),
      ],
          margin: margin,
          borderRadius: borderRadius,
          ratio: rowRatio,
          size: buttonSize,
          fontSize: 0.5)
    ]);
  }

  static MapEntry<Size, double> _getFitParams(
      int rowLength, int numberOfRows, double w, double h,
      {double ratio: 1, bool strict: false, context}) {
    double fitH = min(h, w / (rowLength / numberOfRows * ratio));
    if (strict) {
      if (h.isInfinite &&
          context != null &&
          MediaQuery.of(context).size.aspectRatio < 1) {}
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
      else if (size != null) if (fontSize > 0)
        element.fontSize = min(size.width, size.height) * fontSize;
      if (iconSize > 1)
        element.iconSize = iconSize;
      else if (size != null) if (iconSize > 0)
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

  static Column getLatinKeyboardWithDigits(
      double w, double h, context, Layout widget) {
    var erase = widget.erase;
    var tapped = widget.tapped;
    var canChange = widget.canChange;
    var params = _getFitParams(10, 4, w, h, ratio: 3 / 4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    widget.updateSize((buttonSize.width) * 10, buttonSize.height * 4);
    return Column(children: [
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
    var params = _getFitParams(10, 3, w, h, ratio: 3 / 4, context: context);
    var buttonSize = params.key;
    double rowRatio = params.value;
    double borderRadius = min(buttonSize.width, buttonSize.height) * 0.1;
    double margin = min(buttonSize.width, buttonSize.height) * 0.05;
    widget.updateSize((buttonSize.width) * 10, buttonSize.height * 3);
    return Column(children: [
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
    return LayoutBuilder(builder: (context, constraints) {
      w = constraints.maxWidth -
          widget.padding.horizontal -
          widget.margin.horizontal;
      h = constraints.maxHeight -
          widget.padding.vertical -
          widget.margin.vertical;
      double totalFlex = widget.keyBuilders
          .fold(0, (previousValue, element) => previousValue + element.flex);
      Widget kb;
      if (h.isFinite) {
        kb = Column(
            children: widget.keyBuilders.fold([], (previousValue, element) {
          previousValue.add(element.keyBuilder(
              w, h * element.flex / totalFlex, context, widget));
          return previousValue;
        }));
      } else {
        kb = Column(
            children: widget.keyBuilders.fold([], (previousValue, element) {
          previousValue.add(element.keyBuilder(
              w, h * element.flex / totalFlex, context, widget));
          return previousValue;
        }));
      }

      var al = Align(
        alignment: Alignment.bottomCenter,
        child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                  alignment: widget.alignment ?? Alignment.center,
                  padding: widget.padding ?? EdgeInsets.all(0),
                  margin: widget.margin ?? EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: kb)
            ]),
      );
      return al;
    });
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
      widget._editText += s;
      widget.onEdited(widget._editText);
    });
  }

  void erase(String s) {
    setState(() {
      if (widget._editText.isNotEmpty)
        widget._editText = widget._editText.substring(0, widget._editText.length - 1);
      widget.onEdited(widget._editText);
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
  Image image;
  Color color;
  double margin;
  double borderRadius;
  double fontSize;
  double iconSize;
  double w;
  double h;
  Size size;
  dynamic value;

  _KeyboardButton(this.tapped,
      {this.size,
      this.text,
      this.color,
      this.iconData,
      this.image,
        this.value,
      this.margin: 2,
      this.borderRadius: 2,
      this.fontSize: 28,
      this.iconSize: 28}) {
    color = color ?? Colors.redAccent;
    value = value ?? text;
  }

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
            tapped(widget.value);
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
                color: widget.color.withOpacity(pressed ? 0.66 : 1)),
            child: FittedBox(
              fit: BoxFit.fill,
              child:
              Wrap(
                alignment: WrapAlignment.spaceAround,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  icon == null ? widget.image == null ? text == ' ' ? Icon(Icons.space_bar) : Container() : widget.image:  Icon(icon),
                  text == null || text == ' ' ? Container(width: 1, height: 1,) :  Text(text, style: TextStyle(fontSize: fontSize))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InputField extends StatefulWidget {
  bool isPassword = false;
  double textHeightPercent = 1;
  double textSizePercent = 0.8;
  String text;
  String template;
  Function backward;
  Function forward;
  int minTextLength = 4;
  bool showButtons = true;


  InputField({this.isPassword, this.textHeightPercent, this.textSizePercent,
      this.text, this.forward, this.backward, this.template, this.minTextLength, this.showButtons}) {
    textHeightPercent = textHeightPercent ?? 1;
    textSizePercent = textSizePercent ?? 0.8;
    text = text ?? '';
    isPassword = isPassword ?? false;
    template = template ?? '&text';
    minTextLength = minTextLength ?? 4;
    showButtons = showButtons ?? true;
  }

  @override
  State createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  double textHeight;
  double textSize;
  double h;
  double w;
  double dragDelta = 0;
  String visibleText = '';


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          h = constraints.maxHeight;
          w = constraints.maxWidth;
          if (widget.showButtons) {
            if (widget.forward != null)
              w -= constraints.maxWidth * 0.1;
            if (widget.backward != null)
              w -= constraints.maxWidth * 0.1;

          }
          visibleText = widget.template.replaceAll("&text", widget.isPassword
              ? widget.text.replaceAll(RegExp('[0-9]'), '*')
              : widget.text);
          if (h.isFinite) {
            textHeight = h * widget.textHeightPercent;
            h -= textHeight + 2;
          } else {
            textHeight = w * widget.textHeightPercent * 16 / 9;
          }
          textSize = min(
              textHeight * widget.textSizePercent,
              w /
                  (1.3 *  max(visibleText.length, widget.minTextLength) -
                      max(visibleText.replaceAll(RegExp("([ШЩМЖЫQWM])"), "").length, widget.minTextLength) *
                          0.3) *
                  1.0);
          return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  dragDelta += details.primaryDelta;
                  print(dragDelta);
                });
              },
              onHorizontalDragEnd: (details) {
                setState(() {
                  if (dragDelta < - min(w * 0.2, 100)) {
                    widget.forward();
                  } else if (dragDelta > min(w * 0.2, 100)) {
                    widget.backward();
                  }
                  dragDelta = 0;
                });
              },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                        visibleText,
                        style: TextStyle(
                          fontSize: textSize,
                          color: Colors.redAccent,
                          textBaseline: TextBaseline.alphabetic,
                        )),
                  ]),
            ),
          );
        },
    );
  }
}

class KeyBuilder {
  Function keyBuilder;
  double flex = 1;

  KeyBuilder(this.keyBuilder, {this.flex = 1});
}
