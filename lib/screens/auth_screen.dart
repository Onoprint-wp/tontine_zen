import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController(text: '+237600000001'); // Numéro test par défaut
  final _otpController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isNewUserFlow = false;
  String _phoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre numéro de téléphone')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneNumber = phone;
    });

    try {
      await SupabaseService.instance.signInWithPhone(phone);
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code envoyé au $phone (Pour les tests utilisez 123456)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le code OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseService.instance.verifyOtp(_phoneNumber, otp);
      
      if (response.user != null) {
        // Check if user has a profile, otherwise they need to create one (set name)
        final profile = await SupabaseService.instance.getCurrentProfile();
        
        if (profile == null || profile.fullName == 'Utilisateur anonyme' || profile.fullName.trim().isEmpty) {
          setState(() {
            _isNewUserFlow = true;
          });
        } else {
          _navigateToDashboard();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code invalide ou expiré : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completeProfile() async {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir votre nom complet')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.updateProfile(fullName: name);
      _navigateToDashboard();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _loginAsSimulatedUser(String email, String fullName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final client = SupabaseService.instance.client;
      try {
        await client.auth.signInWithPassword(
          email: email,
          password: 'TontineZen2026!',
        );
      } catch (e) {
        await client.auth.signUp(
          email: email,
          password: 'TontineZen2026!',
          data: {'full_name': fullName},
        );
        await SupabaseService.instance.updateProfile(fullName: fullName);
      }
      _navigateToDashboard();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur simulation : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo placeholder / App Icon
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'TONTINE ZEN',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                'Épargne sécurisée & Transparente',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              if (!_otpSent && !_isNewUserFlow) ...[
                // Enter Phone Number
                Text(
                  'Connexion par téléphone',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: '+2376xxxxxxxx',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Envoyer le code OTP'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Simulation Démo (Sélectionner un profil)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _loginAsSimulatedUser('ariel@tontine.com', 'Ariel Kamga'),
                  icon: const Icon(Icons.admin_panel_settings, color: AppConstants.primaryColor),
                  label: const Text('Ariel Kamga (Admin & Trésorier)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.roundTwelve),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _loginAsSimulatedUser('bernice@tontine.com', 'Bernice Noubissi'),
                  icon: const Icon(Icons.person, color: AppConstants.scoreColor),
                  label: const Text('Bernice Noubissi (Membre - En retard)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.scoreColor,
                    side: const BorderSide(color: AppConstants.scoreColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.roundTwelve),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _loginAsSimulatedUser('cedric@tontine.com', 'Cedric Fotso'),
                  icon: const Icon(Icons.person_outline, color: AppConstants.textPrimaryColor),
                  label: const Text('Cedric Fotso (Membre - En attente)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.textPrimaryColor,
                    side: const BorderSide(color: AppConstants.secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.roundTwelve),
                    ),
                  ),
                ),
              ] else if (_otpSent && !_isNewUserFlow) ...[
                // Enter OTP Code
                Text(
                  'Code de confirmation',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Saisissez le code envoyé par SMS au $_phoneNumber',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Code de vérification',
                    hintText: '123456',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Valider le code'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Modifier le numéro de téléphone',
                      style: TextStyle(color: AppConstants.textSecondaryColor)),
                ),
              ] else ...[
                // Complete Profile Flow
                Text(
                  'Création de profil',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez renseigner votre nom pour finaliser l\'inscription.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Ex: Jean Dupont',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Terminer l\'inscription'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
