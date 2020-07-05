import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsWindow extends StatelessWidget {

  var termsVisible = false;
  var questions = [];
  var terms;


  TermsWindow(this.termsVisible, this.questions, this.terms);

  @override
  Widget build(BuildContext context) {

    return  StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.lightBlue,
        contentPadding: EdgeInsets.only(top: 8),
        content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 12.0, left: 24.0, right: 24.0, bottom: 12.0),
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            style: TextStyle(color: Colors.white, fontSize: 46),
                            text: questions[0],
                          ),
                          TextSpan(
                              style: TextStyle(color: Colors.white, fontSize: 46, decoration: TextDecoration.underline,),
                              text: questions[1],
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    termsVisible = !termsVisible;
                                  });
                                }
                          )
                        ]
                    )
                ),
              ),
              Visibility(
                visible: termsVisible,
                child: Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 8, bottom: 8),
                    child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              blurRadius: 4,
                              color: Colors.white.withOpacity(0.2),
                              spreadRadius: 4)
                        ]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                              child: Text(
                                terms,
                                style: TextStyle(fontSize: 28, color: Colors.white),
                                textAlign: TextAlign.left,
                              )),
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 32.0, bottom: 32.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[400],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0)),
                    ),
//                              child: Icon(Icons.check_circle_outline, color: Colors.amberAccent, size: 56,),
                    child: Text(
                      "OK",
                      style: TextStyle(
                          color: Colors.white, fontSize: 46),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ]),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

}