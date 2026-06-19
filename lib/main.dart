import 'package:flutter/material';

void main() {
  runApp(const TontineZenApp());
}

class TontineZenApp extends StatelessWidget {
  const TontineZenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tontine Zen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1A2E), // Deep Blue from Design System
        primaryColor: const Color(0xFF2A4A7F), // Cobalt Blue
        cardColor: const Color(0xFF1A2A4A), // Marine Blue
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFFA0AEC0)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TONTINE ZEN LIGHT',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.spa,
              size: 80,
              color: Color(0xFF2F855A), // Emerald Green
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenue dans Tontine Zen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Prêt pour le prochain tour de table ?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
