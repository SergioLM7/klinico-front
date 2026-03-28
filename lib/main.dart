import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
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
        Provider(
          create: (_) => ApiClient(
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
        ProxyProvider<ApiClient, AuthService>(
          update: (_, apiClient, _) => AuthService(apiClient),
        ),
        Provider(create: (_) => const FlutterSecureStorage()),
        ProxyProvider2<AuthService, FlutterSecureStorage, AuthRepository>(
          update: (_, authService, storage, _) =>
              AuthRepository(authService: authService, storage: storage),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              LoginViewModel(authRepository: context.read<AuthRepository>()),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 69, 212, 136),
        ),
        useMaterial3: true,
      ),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
