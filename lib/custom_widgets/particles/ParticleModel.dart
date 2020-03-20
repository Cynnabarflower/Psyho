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

  ParticleModel(this.random, this.colors, this.duration, this.minSize, this.maxSize) {
    restart();
  }

  restart({Duration time = Duration.zero, Color setColor}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final liveTime = duration + Duration(milliseconds: random.nextInt((duration.inMilliseconds)));
    this.color = setColor == null ? colors[random.nextInt(colors.length)] :setColor;

    tween = MultiTrackTween([
      Track("x").add(
          liveTime, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          liveTime, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
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