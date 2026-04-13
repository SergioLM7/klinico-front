import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/admission_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/episode_repository.dart';
import 'data/repositories/patient_repository.dart';
import 'data/repositories/service_repository.dart';
import 'data/services/auth_service.dart';
import 'ui/viewmodels/admission_viewmodel.dart';
import 'ui/viewmodels/episode_viewmodel.dart';
import 'ui/viewmodels/login_viewmodel.dart';
import 'ui/views/home_view.dart';
import 'ui/views/login_view.dart';

/// Clave global para poder navegar al Login desde el interceptor de 401
/// sin necesitar un BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => const FlutterSecureStorage()),
        Provider(
          create: (context) => ApiClient(
            getToken: () =>
                context.read<FlutterSecureStorage>().read(key: 'token'),
            // Callback (interceptor) que se invoca cuando la API devuelve 401 durante una sesión activa (token caducado en mitad del uso).
            onUnauthorized: () {
              // Capa 2: el token caducó durante la sesión → limpiar y redirigir
              final context = navigatorKey.currentContext;
              if (context != null) {
                context.read<LoginViewModel>().signOut();
              }
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ),
        Provider(
          create: (context) => AuthRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => AdmissionRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => EpisodeRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => PatientRepository(context.read<ApiClient>()),
        ),
        Provider(
          create: (context) => ServiceRepository(context.read<ApiClient>()),
        ),

        Provider(
          create: (context) => AuthService(
            authRepository: context.read<AuthRepository>(),
            storage: context.read<FlutterSecureStorage>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LoginViewModel(authService: context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AdmissionViewModel(
            repository: context.read<AdmissionRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EpisodeViewModel(repository: context.read<EpisodeRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinico Medical App',
      navigatorKey: navigatorKey, // necesario para navegar desde el interceptor
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Decodifica el JWT, comprueba expiración y carga el rol en el ViewModel
      future: context.read<LoginViewModel>().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: AppTheme.backgroundDecoration,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // initialize() devuelve true = sesión válida con rol cargado
        if (snapshot.data == true) {
          return const HomePage();
        }

        // Token caducado, inexistente o inválido → Login
        return const LoginPage();
      },
    );
  }
}
