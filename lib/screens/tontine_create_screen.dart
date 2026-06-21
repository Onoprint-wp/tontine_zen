import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class TontineCreateScreen extends StatefulWidget {
  const TontineCreateScreen({super.key});

  @override
  State<TontineCreateScreen> createState() => _TontineCreateScreenState();
}

class _TontineCreateScreenState extends State<TontineCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _frequency = 'weekly';
  int _maxMembers = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final amount = double.parse(_amountController.text.trim());

      await SupabaseService.instance.createTontine(
        name: name,
        amount: amount,
        frequency: _frequency,
        maxMembers: _maxMembers,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tontine créée avec succès !')),
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
        title: const Text('Créer une Tontine'),
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
                      'Créer un nouveau groupe d\'épargne',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Définissez les règles financières de votre tontine.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),

                    // Nom de la tontine
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la tontine',
                        hintText: 'Ex: Zen Investisseurs Mboa',
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Montant de cotisation
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Montant de cotisation (individuel)',
                        hintText: 'Ex: 10000',
                        suffixText: 'FCFA',
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir un montant';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Veuillez saisir un montant valide (> 0)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fréquence (Dropdown)
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      decoration: const InputDecoration(
                        labelText: 'Fréquence de cotisation',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Quotidienne')),
                        DropdownMenuItem(value: 'weekly', child: Text('Hebdomadaire')),
                        DropdownMenuItem(value: 'monthly', child: Text('Mensuelle')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _frequency = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre maximal de membres
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppConstants.textSecondaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Membres max',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _maxMembers > 2
                                  ? () => setState(() => _maxMembers--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_maxMembers',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            IconButton(
                              onPressed: _maxMembers < 50
                                  ? () => setState(() => _maxMembers++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Créer le groupe'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
