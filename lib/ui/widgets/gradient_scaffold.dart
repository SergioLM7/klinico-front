import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// [Scaffold] reutilizable con el degradado corporativo de Klinico como fondo.
///
/// Úsalo en cualquier vista en lugar de `Scaffold` + `backgroundColor` manual:
///
/// ```dart
/// return GradientScaffold(
///   appBar: AppBar(title: Text('Mi Vista')),
///   body: MiWidget(),
/// );
/// ```
class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  const GradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    // El Container ocupa TODA la pantalla (AppBar + body + espacio vacío)
    // El Scaffold es transparente → el degradado se ve en todo momento
    // extendBodyBehindAppBar → el body/gradient se pinta también detrás de la AppBar
    return Container(
      decoration: AppTheme.backgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: body,
      ),
    );
  }
}
