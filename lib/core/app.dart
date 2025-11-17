import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:watering_app/core/app_lifecycle_observer.dart';
import 'package:watering_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:watering_app/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: ToastificationConfig(
        // maxTitleLines: 2,
        // maxDescriptionLines: 6,
        marginBuilder: (context, alignment) =>
            const EdgeInsets.fromLTRB(0, 16, 0, 0),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // navigatorObservers: [routeObserver],
        builder: (context, child) {
          return AppLifecycleObserver(child: child!);
        },
        theme: theme,
        home: LoginScreen(),
      ),
    );
  }
}
