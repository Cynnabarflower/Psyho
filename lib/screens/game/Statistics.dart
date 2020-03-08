class Statistics {
  int delay;
  bool isCorrect;

  Statistics(this.delay, this.isCorrect);

  @override
  String toString() {
    return (isCorrect ? "OK! " : "NO ") + "(" + delay.toString() +")\n";
  }


}