import 'package:flutter/material.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(const MiivvyApp());
}

class MiivvyApp extends StatelessWidget {
  const MiivvyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miivvy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
