import 'package:flutter/material.dart';
import 'package:klinico_front/ui/widgets/gradient_scaffold.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/glass_container.dart';
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
      final role = vm.userRole;
      if (role == null || (role != 'MEDICO' && role != 'JEFESERVICIO')) {
        _showUnauthorizedDialog(
          role == null
              ? "Su sesión no tiene un rol asignado."
              : "El rol '$role' no tiene permisos para acceder a esta aplicación.",
        );
      }
    });
  }

  void _showUnauthorizedDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          blur: 20,
          opacity: 0.2,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_person_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                "Acceso no autorizado",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Volver al Login",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
        return const GradientScaffold(
          bottomNavigationBar: null,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          ),
        );
    }
  }
}
