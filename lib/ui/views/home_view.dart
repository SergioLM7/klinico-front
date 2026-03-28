import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'jefeservicio_main_view.dart';
import 'medico_main_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el rol del ViewModel (que lo guardó tras el login)
    final role = context.select<LoginViewModel, String?>((vm) => vm.userRole);

    switch (role) {
      case 'MEDICO':
        return const MedicoMainView();
      case 'JEFESERVICIO':
        return const JefeServicioMainView();
      // case 'ADMINISTRATIVO':
      //   return const AdministrativoMainView();
      default:
        // Por si acaso algo falla, devolvemos una vista de error o login
        return const Center(child: Text("Rol no reconocido"));
    }
  }
}
