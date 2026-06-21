import 'package:flutter/material.dart';

class AppConstants {
  // Supabase Configuration
  // 10.0.2.2 est l'adresse de l'hôte local pour l'émulateur Android.
  // Pour le web ou un appareil réel sur le même réseau, utilisez localhost ou votre IP locale.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gureljfvknyzpskpvljs.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd1cmVsamZ2a255enBza3B2bGpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwNjM0NTgsImV4cCI6MjA5NzYzOTQ1OH0.g0LrUjkqTL50mgZD68ymXN7ZDJjrqyENkjWVKO1SiHI',
  );

  // App Colors (Pockora Dark Blue Theme)
  static const Color backgroundColor = Color(0xFF0F1A2E);
  static const Color cardColor = Color(0xFF1E2E4A);
  static const Color primaryColor = Color(0xFF00C853); // Vert gains
  static const Color secondaryColor = Color(0xFF8A9BB4); // Gris bleu
  static const Color alertColor = Color(0xFFFF3D00); // Rouge retards
  static const Color scoreColor = Color(0xFFFFD600); // Jaune score de réputation
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFF8A9BB4);

  // Corner radius
  static const double roundTwelve = 12.0;
}
