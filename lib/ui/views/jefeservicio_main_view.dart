import 'package:flutter/material.dart';
import '../viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

import 'login_view.dart';

class JefeServicioMainView extends StatelessWidget {
  const JefeServicioMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Jefe de Servicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<LoginViewModel>().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text("Bienvenido, Doctor/a")),
    );
  }
}
