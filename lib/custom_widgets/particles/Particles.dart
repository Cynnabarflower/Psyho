import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

import 'ParticleModel.dart';
import 'ParticlePainter.dart';

class Particles extends StatefulWidget {
  final int quan;
  final List<Color> colors;
  final Duration duration;
  double minSize;
  double maxSize;

  Particles({this.quan = 30, this.colors, this.duration, this.minSize = 0.1, this.maxSize = 0.9});

  @override
  _ParticlesState createState() => _ParticlesState();

}

class _ParticlesState extends State<Particles> {
  final Random random = Random();
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    generateParticles(widget.quan);
    super.initState();
  }

  void generateParticles(int count) {
    List.generate(count, (index) {
      particles.add(ParticleModel(random, widget.colors, widget.duration, widget.minSize/2, widget.maxSize/2));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }

}