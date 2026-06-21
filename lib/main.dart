import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/supabase_service.dart';
import 'themes/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase before running app
  await SupabaseService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isUserLoggedIn = SupabaseService.instance.isAuthenticated;

    return MaterialApp(
      title: 'Tontine Zen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      
      // Localization setup
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''), // Français
        Locale('en', ''), // Anglais
      ],
      locale: const Locale('fr', ''), // Locale par défaut

      // Route check
      home: isUserLoggedIn ? const DashboardScreen() : const AuthScreen(),
    );
  }
}
