import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'jefeservicio_main_view.dart';
import 'medico_main_view.dart';
import 'login_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Verificación post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<LoginViewModel>();
      if (vm.userRole == null) {
        _showUnauthorizedDialog();
      }
    });
  }

  void _showUnauthorizedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.05),
      builder: (context) => AlertDialog(
        title: const Text("Acceso no autorizado"),
        content: const Text(
          "Su sesión no tiene un rol asignado. Por favor, inicie sesión de nuevo.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select<LoginViewModel, String?>((vm) => vm.userRole);

    switch (role) {
      case 'MEDICO':
        return const MedicoMainView();
      case 'JEFESERVICIO':
        return const JefeServicioMainView();
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
