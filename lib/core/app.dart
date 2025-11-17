import 'package:flutter/material.dart';
import 'package:watering_app/core/app_lifecycle_observer.dart';
import 'package:watering_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:watering_app/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // navigatorObservers: [routeObserver],
      builder: (context, child) {
        return AppLifecycleObserver(child: child!);
      },
      theme: theme,
      home: LoginScreen(),
    );
  }
}
