import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/admissions_dashboard.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_scaffold.dart';
import 'admissions/admission_form_view.dart';
import 'admissions/admissions_search_view.dart';
import '../viewmodels/login_viewmodel.dart';
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
          ? _GlassBottomNav(
              selectedIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
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
                leading: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/logo.png', height: 32),
                      const SizedBox(width: 8),
                      const Text(
                        "KLINICO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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
                    icon: Icon(Icons.dashboard, color: AppTheme.primaryBlue),
                    label: Text('Mis pacientes'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_add, color: AppTheme.primaryBlue),
                    label: Text('Nuevo ingreso'),
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
                  // Header Móvil (App Title + Logout)
                  if (isMobile)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/logo.png', height: 28),
                              const SizedBox(width: 8),
                              const Text(
                                "KLINICO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const _LogoutButton(compact: true),
                        ],
                      ),
                    ),
                  // Dashboard y Vistas
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        switch (_selectedIndex) {
                          case 0:
                            return AdmissionDashboard();
                          case 1:
                            return const AdmissionFormView();
                          case 2:
                            return const AdmissionsSearchView();
                          default:
                            return AdmissionDashboard();
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

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (icon: Icons.dashboard, label: 'Mis pacientes'),
    (icon: Icons.person_add, label: 'Ingreso'),
    (icon: Icons.people, label: 'Pacientes'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final bool isSelected = index == selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: isSelected
                          ? BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.primaryBlue.withValues(
                                    alpha: 0.7,
                                  ),
                                  width: 2.5,
                                ),
                              ),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.20 : 1.0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: Icon(
                              item.icon,
                              size: 22,
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : Colors.black38,
                            ),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          splashColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
          highlightColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          child: IconButton(
            padding: compact
                ? const EdgeInsets.all(6)
                : const EdgeInsets.all(8),
            constraints: compact ? const BoxConstraints() : null,
            icon: Icon(
              Icons.logout,
              color: AppTheme.primaryBlue,
              size: compact ? 20 : 24,
            ),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                barrierColor: Colors.black.withValues(alpha: 0.05),
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                    size: 28,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Cerrar sesión',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.gradientStart,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Confirmar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
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
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
