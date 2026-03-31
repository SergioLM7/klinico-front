import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/glass_container.dart';
import 'home_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Definimos los controladores (se limpian en el dispose)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos al ViewModel para saber si hay errores o estamos cargando
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 145, 180, 198), Color(0xFFFFFFFF)],
          ),
        ),
        // Centrado total para Tablet
        child: SingleChildScrollView(
          // Por si sale el teclado
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ), // Bloqueamos el ancho
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(24.0),
                opacity: 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TODO: Logo e Icono
                      const Text(
                        "Klinico",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: !passwordVisible,
                        decoration: InputDecoration(
                          hintText: "Password",
                          labelText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                          alignLabelWithHint: false,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                      ),

                      const SizedBox(height: 20),

                      // El Botón de Acción
                      viewModel.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () => _handleLogin(context, viewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                  255,
                                  128,
                                  160,
                                  176,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text("Iniciar Sesión"),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, LoginViewModel vm) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final success = await vm.signIn(email, password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Acceso concedido. Bienvenida/o ${vm.userName ?? ''}."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("⛔️ Error en el inicio de sesión"),
          content: Text(vm.errorMessage ?? "Error desconocido"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      );
    }
  }
}
