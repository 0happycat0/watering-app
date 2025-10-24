import 'package:flutter/material.dart';
import 'package:watering_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:watering_app/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // navigatorObservers: [routeObserver],
      theme: theme,
      home: LoginScreen(),
    );
  }
}