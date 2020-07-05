class Statistics {

  List<_Answer> answers = [];

  Statistics();

  @override
  String toString() {
    String s;
    for (var a in answers)
      s += (a.isCorrect ? "OK! " : "NO ") + "(" + a.delay.toString() +")\n";
    return s;
  }

  void add(delay, isCorrect) {
    answers.add(_Answer(isCorrect, delay));
  }

}

class _Answer {
  bool isCorrect;
  int delay;

  _Answer(this.isCorrect, this.delay);

  @override
  String toString() {
    return isCorrect ? "OK" : "NO" + ' ($delay)';
  }


}