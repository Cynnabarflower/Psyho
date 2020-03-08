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

  ParticleModel(this.random, this.colors) {
    restart();
  }

  restart({Duration time = Duration.zero, Color setColor}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final duration = Duration(milliseconds: 2000 + random.nextInt(2000));
    this.color = setColor == null ? colors[random.nextInt(colors.length)] :setColor;

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}