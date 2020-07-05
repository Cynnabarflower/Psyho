import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class DateChooser extends StatefulWidget {

  Function callback;
  DateTimePickerLocale locale;
  DateTime init;

  DateChooser(this.callback, this.locale, {this.init});

  @override
  State<StatefulWidget> createState() => _DateChooserState();

}

class _DateChooserState extends State<DateChooser> {

  var selectitem = 0;
  var minDate = DateTime.now().subtract(Duration(days: 365 * 100));
  var maxDate = DateTime.now().subtract(Duration(days: 365 * 4));



  @override
  Widget build(BuildContext context) {

    return Wrap(
      alignment: WrapAlignment.center,
      children: [Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
//            color: Colors.lightBlue[400].withOpacity(0.3),
            borderRadius: BorderRadius.all(Radius.circular(8))),

        child: DatePickerWidget(
          pickerTheme: DateTimePickerTheme(
            itemHeight: 200,
            itemTextStyle: GoogleFonts.comfortaa().copyWith(fontSize: 88, color: Colors.white),
            backgroundColor: Colors.lightBlue[400].withOpacity(0.4),
            pickerHeight: 238
          ),
          dateFormat: 'dd-MMM-yyyy',
          onChange: widget.callback,
          firstDate: minDate,
          lastDate: maxDate,
          initialDate: widget.init ?? DateTime.now().subtract(Duration(days: 365 * 8)),
          locale: widget.locale,
        )
      )]
    );
  }
}