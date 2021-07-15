import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class LoginBackground extends StatelessWidget {
  LoginBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff0c0c0c),
        backgroundBlendMode: BlendMode.srcOver,
      ),
      child: PlasmaRenderer(
        type: PlasmaType.infinity,
        particles: 3,
        color: Color(0x44ff3232),
        blur: 1,
        size: 0.6,
        speed: 2.04,
        offset: 0,
        blendMode: BlendMode.plus,
        particleType: ParticleType.atlas,
        variation1: 0,
        variation2: 0,
        variation3: 0,
        rotation: 0,
        child: PlasmaRenderer(
          type: PlasmaType.infinity,
          particles: 3,
          color: Color(0x442327e4),
          blur: 1,
          size: 0.6,
          speed: 2.04,
          offset: 1.49,
          blendMode: BlendMode.plus,
          particleType: ParticleType.atlas,
          variation1: 0,
          variation2: 0,
          variation3: 0,
          rotation: 0,
        ),
      ),
    );
  }
}
