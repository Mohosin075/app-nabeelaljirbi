import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -MediaQuery.of(context).size.height * 0.51,
      left: -MediaQuery.of(context).size.width * 0.18,
      child: Transform.rotate(
        angle: 35.53 * 3.14159 / 180,
        child: Container(
          height: MediaQuery.of(context).size.width * 2.0,
          width: MediaQuery.of(context).size.width * 2.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(0xFF137CCF).withValues(alpha: 0.45),
                Color(0xFF137CCF).withValues(alpha: 0.40),
                Color(0xFF137CCF).withValues(alpha: 0.32),
                Color(0xFF137CCF).withValues(alpha: 0.24),
                Color(0xFF137CCF).withValues(alpha: 0.16),
                Color(0xFF137CCF).withValues(alpha: 0.10),
                Color(0xFF137CCF).withValues(alpha: 0.06),
                Color(0xFF137CCF).withValues(alpha: 0.03),
                Color(0xFF137CCF).withValues(alpha: 0.015),
                Color(0xFF137CCF).withValues(alpha: 0.005),
                Colors.transparent,
              ],
              stops: [
                0.0,
                0.1,
                0.2,
                0.3,
                0.4,
                0.5,
                0.65,
                0.75,
                0.85,
                0.95,
                1.0,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
