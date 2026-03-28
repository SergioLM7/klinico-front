import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0, // Nivel de desenfoque
    this.opacity = 0.15, // Opacidad del fondo blanco
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ClipRRect para redondear el recorte del efecto
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      // 2. BackdropFilter aplica el desenfoque al fondo detrás del contenedor
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: opacity,
            ), // Fondo blanco muy suave
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            // Border suave para simular el borde del cristal
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
