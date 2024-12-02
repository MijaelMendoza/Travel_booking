import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:carretera/auth_service/signin_page.dart';
import 'package:carretera/components/home_page.dart'; // Asegúrate de importar la pantalla principal
import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase usando las opciones específicas para la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura la persistencia en plataformas web
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(
    DevicePreview(
      enabled: !true, // Cambia a true para habilitar el Device Preview
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: Image.asset(
          'assets/nebulalogo.jpg',
        ),
        nextScreen:
            AuthWrapper(), // Cambia la siguiente pantalla al AuthWrapper
        splashTransition: SplashTransition.slideTransition,
        duration: 2000,
      ),
    );
  }
}

// Widget que decide si el usuario va a HomePage o SignInPage
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Si el usuario ya está autenticado, mostrar HomePage
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            return const HomePage(); // Asegúrate de definir esta pantalla
          } else {
            return const SignInPage();
          }
        }

        // Mostrar un indicador de carga mientras se verifica la autenticación
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
