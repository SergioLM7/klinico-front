import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/admissions_dashoard.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import 'admissions/admission_form_view.dart';
import 'admissions/admissions_search_view.dart';
import 'servicekpis/service_new_admissions_view.dart';
import '../viewmodels/login_viewmodel.dart';
import 'login_view.dart';
import 'servicekpis/service_workload_view.dart';

class JefeServicioMainView extends StatefulWidget {
  const JefeServicioMainView({super.key});

  @override
  State<JefeServicioMainView> createState() => _JefeServicioMainViewState();
}

class _JefeServicioMainViewState extends State<JefeServicioMainView> {
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
                  icon: Icon(Icons.list),
                  label: 'Nuevos ingresos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_add),
                  label: 'Crear ingreso',
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
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GlassContainer(
                        blur: 10,
                        opacity: 0.2,
                        borderRadius: BorderRadius.circular(50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            splashColor: AppTheme.primaryBlue.withValues(
                              alpha: 0.3,
                            ),
                            highlightColor: AppTheme.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: AppTheme.primaryBlue,
                              ),
                              onPressed: () async {
                                final bool? confirm = await showDialog<bool>(
                                  context: context,
                                  barrierColor: Colors.black.withValues(
                                    alpha: 0.05,
                                  ),
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 10,
                                            sigmaY: 10,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.20,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.35,
                                                ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.orange,
                                                      size: 28,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Cerrar sesión',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  '¿Estás seguro de que deseas cerrar la sesión actual?',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(false),
                                                      child: const Text(
                                                        'Cancelar',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            AppTheme
                                                                .gradientStart,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      onPressed: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(true),
                                                      child: const Text(
                                                        'Confirmar',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );

                                if (confirm == true && context.mounted) {
                                  context.read<LoginViewModel>().signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.list, color: AppTheme.primaryBlue),
                    label: Text('Nuevos ingresos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.work_history, color: AppTheme.primaryBlue),
                    label: Text('Carga de trabajo'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard, color: AppTheme.primaryBlue),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_add, color: AppTheme.primaryBlue),
                    label: Text('Crear ingreso'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people, color: AppTheme.primaryBlue),
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
                  // Dashboard y Vistas
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        switch (_selectedIndex) {
                          case 0:
                            return const ServiceNewAdmissionsView();
                          case 1:
                            return const ServiceWorkloadView();
                          case 2:
                            return const AdmissionDashboard();
                          case 3:
                            return const AdmissionFormView();
                          case 4:
                            return const AdmissionsSearchView();
                          default:
                            return const ServiceNewAdmissionsView();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
