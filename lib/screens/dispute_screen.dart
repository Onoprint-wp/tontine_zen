import 'package:flutter/material.dart';
import '../models/tontine.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class DisputeScreen extends StatefulWidget {
  final Tontine tontine;
  final List<Map<String, dynamic>> members;

  const DisputeScreen({
    super.key,
    required this.tontine,
    required this.members,
  });

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _accusedId;
  bool _isLoading = false;
  List<Profile> _otherMembers = [];

  @override
  void initState() {
    super.initState();
    final currentUserId = SupabaseService.instance.currentUserId;
    // Filter out current user from potential accused list
    _otherMembers = widget.members
        .map((m) => m['profile'] as Profile)
        .where((p) => p.id != currentUserId)
        .toList();
    
    if (_otherMembers.isNotEmpty) {
      _accusedId = _otherMembers.first.id;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _accusedId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.reportDispute(
        tontineId: widget.tontine.id,
        accusedId: _accusedId!,
        description: _descriptionController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Litige signalé avec succès à l\'administration !')),
      );

      Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un Litige'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Déclarer un défaut de paiement',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.alertColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ce formulaire permet de signaler un membre n\'ayant pas honoré sa cotisation. L\'administration analysera la situation.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    if (_otherMembers.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Il n\'y a aucun autre membre dans cette tontine à signaler.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else ...[
                      // Select Accused Member
                      DropdownButtonFormField<String>(
                        value: _accusedId,
                        decoration: const InputDecoration(
                          labelText: 'Membre concerné',
                          prefixIcon: Icon(Icons.person_search),
                        ),
                        items: _otherMembers.map((profile) {
                          return DropdownMenuItem<String>(
                            value: profile.id,
                            child: Text(profile.fullName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _accusedId = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description du litige',
                          hintText: 'Expliquez en détail (ex : retard de plus de 7 jours sans explication...)',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez décrire la situation';
                          }
                          if (value.trim().length < 10) {
                            return 'Veuillez donner une description plus détaillée (10 caractères min)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 48),

                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.alertColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Soumettre le litige'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
