import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:carretera/auth_service/signin_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase usando las opciones específicas para la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura la persistencia en plataformas web
 
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
          'assets/images/nebulalogo.jpg',
        ),
        nextScreen: SignInPage(),
        splashTransition: SplashTransition.slideTransition,
        duration: 2000,
      ),
    );
  }
}
