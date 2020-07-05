import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class ParticleModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;
  Color color;
  List<Color> colors;
  Duration duration;
  double minSize = 0;
  double maxSize = 1;
  final Offset start;
  final Offset end;
  final Offset volatileStart;
  final Offset volatileEnd;
  final Curve xCurve;
  final Curve yCurve;

  ParticleModel(this.random, this.colors, this.duration, this.minSize, this.maxSize, {this.start = const Offset(-0.2, 1.2), this.end = const Offset(-0.2, -0.2), this.volatileStart = const Offset(1.4, 0), this.volatileEnd = const Offset(1.4, 0), this.xCurve =  Curves.easeInOutSine, this.yCurve =  Curves.easeIn}) {
    restart();
  }

  restart({Duration time = Duration.zero, Color setColor}) {
    final startPosition = Offset(start.dx + volatileStart.dx * random.nextDouble(), start.dy + volatileStart.dy * random.nextDouble());
    final endPosition = Offset(end.dx + volatileEnd.dx * random.nextDouble(), end.dy + volatileEnd.dy * random.nextDouble());
    final liveTime = duration + Duration(milliseconds: random.nextInt((duration.inMilliseconds)));
    this.color = setColor == null ? colors[random.nextInt(colors.length)] :setColor;

    tween = MultiTrackTween([
      Track("x").add(
          liveTime, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: xCurve),
      Track("y").add(
          liveTime, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: yCurve),
    ]);
    animationProgress = AnimationProgress(duration: liveTime, startTime: time);
    size = minSize + random.nextDouble()*(maxSize - minSize);
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}