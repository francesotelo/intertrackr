import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_application_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase before app launch

  // Rehydrate any persisted Firebase session before the first frame so a
  // signed-in user is not bounced back to the login screen on every launch.
  final appState = AppState();
  await appState.tryRestoreSession();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const InternTrackrApp(),
    ),
  );
}

class InternTrackrApp extends StatelessWidget {
  const InternTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.isDarkMode;

    return MaterialApp(
      title: 'InternTrackr',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FE),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF673AB7), // Deep Purple
          secondary: Color(0xFFE91E63), // Pink
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9575CD),
          secondary: Color(0xFFF48FB1),
          surface: Color(0xFF1E1E1E),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      initialRoute: appState.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add_application': (context) => const AddApplicationScreen(),
      },
    );
  }
}
