import 'package:flutter/widgets.dart';

class AnswerButton extends StatefulWidget {
  AssetImage image;
  Color backgroundColor;
  Color shapeColor;
  BoxShape shape;
  Function tapped;
  bool enabled;

  @override
  State<StatefulWidget> createState() {
    return _AnswerButtonState();
  }

  AnswerButton(
      {this.image,
      this.backgroundColor,
      this.shapeColor,
      this.shape,
      this.tapped,
      this.enabled});
}

class _AnswerButtonState extends State<AnswerButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: widget.enabled
          ? ColorFilter.mode(const Color(0x00000000), BlendMode.dst)
          : ColorFilter.mode(const Color(0x99FFFFFF), BlendMode.lighten),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
        ),
        child: GestureDetector(
            onTap: widget.enabled ? widget.tapped : ()=>{},
            child: Container(
              padding: EdgeInsets.all(32),
              margin: EdgeInsets.all(8),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: widget.shapeColor, shape: widget.shape),
              child: Container(
                alignment: Alignment.center,
                child: Image(
                    color: widget.backgroundColor, fit: BoxFit.contain, image: widget.image),
              ),
            )),
      ),
    );
  }
}
