import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const TicketProMobile());
}

class TicketProMobile extends StatelessWidget {
  const TicketProMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TicketProMobile',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050814),
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}