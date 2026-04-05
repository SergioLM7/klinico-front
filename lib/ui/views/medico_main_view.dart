import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/admissions_dashoard.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/header_bar.dart';
import 'login_view.dart';

class MedicoMainView extends StatefulWidget {
  const MedicoMainView({super.key});

  @override
  State<MedicoMainView> createState() => _MedicoMainViewState();
}

class _MedicoMainViewState extends State<MedicoMainView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return GradientScaffold(
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: Colors.black45,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Mis pacientes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_add),
                  label: 'Ingreso',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Pacientes',
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            // 1. MENÚ LATERAL (Solo para Tablet/Desktop)
            if (!isMobile) ...[
              NavigationRail(
                 backgroundColor: Colors.transparent,
                extended: width > 900, // Extendido solo si hay mucho espacio
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(
                    "KLINICO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: AppTheme.primaryBlue,
                        ),
                        onPressed: () => _handleLogout(context),
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.dashboard,
                      color: AppTheme.primaryBlue,
                    ),
                    label: Text('Mis pacientes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_add),
                    label: Text('Nuevo ingreso'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people),
                    label: Text('Pacientes'),
                  ),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1),
            ],

            // 2. ÁREA DE CONTENIDO
            Expanded(
              child: Column(
                children: [
                  // Barra Superior con Buscador
                  HeaderBar(),

                  // Dashboard de Pacientes (Cards)
                  Expanded(child: AdmissionDashboard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<LoginViewModel>().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
