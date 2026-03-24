import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/api_client.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'ui/viewmodels/login_viewmodel.dart';
import 'ui/views/home_view.dart';
import 'ui/views/login_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiClient()),
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Klinico Medical App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(
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
    // Chequeamos el token a través del AuthRepository
    final authRepository = context.read<AuthRepository>();

    return FutureBuilder<String?>(
      future: authRepository.getToken(),
      builder: (context, snapshot) {
        // 1. Mientras está leyendo el storage (milésimas de segundo)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay un token guardado, vamos a la Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage(); // Aquí luego filtraremos por Rol
        }

        // 3. Si no hay nada, al Login
        return const LoginPage();
      },
    );
  }
}
