import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:simple_animations/simple_animations/rendering.dart';

import 'ParticleModel.dart';
import 'ParticlePainter.dart';

class Particles extends StatefulWidget {
  final int numberOfParticles;
  final List<Color> colors;

  Particles(this.numberOfParticles, this.colors);

  @override
  _ParticlesState createState() => _ParticlesState();

}

class _ParticlesState extends State<Particles> {
  final Random random = Random();
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    generateParticles(widget.numberOfParticles);
    super.initState();
  }

  void generateParticles(int count) {
    List.generate(count, (index) {
      particles.add(ParticleModel(random, widget.colors));
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