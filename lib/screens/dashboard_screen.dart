import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/profile.dart';
import '../models/tontine.dart';
import '../widgets/reputation_score_widget.dart';
import '../widgets/tontine_card.dart';
import '../utils/constants.dart';
import 'auth_screen.dart';
import 'tontine_create_screen.dart';
import 'tontine_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Profile? _profile;
  List<Tontine> _tontines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await SupabaseService.instance.getCurrentProfile();
      final tontines = await SupabaseService.instance.getMyTontines();
      
      setState(() {
        _profile = profile;
        _tontines = tontines;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await SupabaseService.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  void _showJoinTontineDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejoindre une tontine'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Saisir le code / UUID de la tontine',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.isEmpty) return;

              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });

              try {
                await SupabaseService.instance.joinTontine(code);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vous avez rejoint la tontine !')),
                );
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Impossible de rejoindre : ${e.toString()}')),
                );
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('Rejoindre'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'TONTINE ZEN',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header & Trust Score
                    if (_profile != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bonjour,',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _profile!.fullName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _profile!.phone,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              ReputationScoreWidget(score: _profile!.trustScore, size: 80),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TontineCreateScreen(),
                                ),
                              ).then((value) {
                                if (value == true) _loadData();
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text('Créer'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showJoinTontineDialog,
                            icon: const Icon(Icons.group_add, color: AppConstants.primaryColor),
                            label: const Text('Rejoindre'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConstants.primaryColor,
                              side: const BorderSide(color: AppConstants.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.roundTwelve),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tontines Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mes Tontines',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '(${_tontines.length})',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_tontines.isEmpty)
                      Card(
                        color: AppConstants.cardColor.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: AppConstants.textSecondaryColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Vous ne faites partie d\'aucune tontine pour le moment.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _showJoinTontineDialog,
                                child: const Text(
                                  'Rejoindre avec un code d\'invitation',
                                  style: TextStyle(color: AppConstants.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._tontines.map((tontine) => TontineCard(
                            tontine: tontine,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TontineDetailScreen(tontine: tontine),
                                ),
                              ).then((value) => _loadData());
                            },
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
