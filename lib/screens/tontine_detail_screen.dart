import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/tontine.dart';
import '../models/profile.dart';
import '../models/payment_round.dart';
import '../models/payment.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import 'dispute_screen.dart';

class TontineDetailScreen extends StatefulWidget {
  final Tontine tontine;

  const TontineDetailScreen({super.key, required this.tontine});

  @override
  State<TontineDetailScreen> createState() => _TontineDetailScreenState();
}

class _TontineDetailScreenState extends State<TontineDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];
  List<PaymentRound> _rounds = [];
  PaymentRound? _activeRound;
  List<Payment> _roundPayments = [];
  
  String _userRole = 'member';
  bool _hasSigned = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentUserId = SupabaseService.instance.currentUserId;
    _loadDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Load members
      _members = await SupabaseService.instance.getTontineMembers(widget.tontine.id);
      
      // Determine user role and signature status
      final userMembership = _members.firstWhere(
        (m) => m['profile'].id == _currentUserId,
        orElse: () => {'role': 'member', 'signed_contract_at': null},
      );
      
      _userRole = userMembership['role'] as String;
      _hasSigned = userMembership['signed_contract_at'] != null;

      // 2. Load payment rounds if active
      if (widget.tontine.status != 'pending_signatures') {
        _rounds = await SupabaseService.instance.getPaymentRounds(widget.tontine.id);
        if (_rounds.isNotEmpty) {
          // Find the active open round
          _activeRound = _rounds.firstWhere(
            (r) => r.status == 'open',
            orElse: () => _rounds.last,
          );
          
          if (_activeRound != null) {
            // Load payments for this active round
            _roundPayments = await SupabaseService.instance.getPaymentsForRound(_activeRound!.id);
          }
        }
      }
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

  Future<void> _signContract() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.signContract(widget.tontine.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrat OHADA signé électroniquement !')),
      );
      await _loadDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la signature : ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment(String paymentId, String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.confirmPayment(paymentId: paymentId, status: status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement validé par le Trésorier !')),
      );
      await _loadDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la confirmation : ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyTontineId() {
    Clipboard.setData(ClipboardData(text: widget.tontine.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code d\'invitation copié !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_CM',
      symbol: 'FCFA',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tontine.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Quick info bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code d\'invitation',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.tontine.id,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18, color: AppConstants.primaryColor),
                                  onPressed: _copyTontineId,
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.only(left: 8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rôle',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            _userRole == 'treasurer' ? 'Trésorier 🔑' : 'Membre 👤',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppConstants.primaryColor,
                  labelColor: AppConstants.primaryColor,
                  unselectedLabelColor: AppConstants.textSecondaryColor,
                  tabs: const [
                    Tab(text: 'Cycle & Cotisations'),
                    Tab(text: 'Membres'),
                  ],
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Cycle & Cotisations
                      _buildCycleTab(context, currencyFormat),
                      
                      // TAB 2: Membres
                      _buildMembersTab(context),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCycleTab(BuildContext context, NumberFormat currencyFormat) {
    // If pending signatures, show Legal Contract Signature View
    if (widget.tontine.status == 'pending_signatures') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTRAT D\'ACCORD DE TONTINE (OHADA)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Conforme aux dispositions de l\'Acte Uniforme OHADA relatif au droit des sociétés coopératives.',
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                    ),
                    const Divider(height: 32),
                    Text(
                      'Entre les soussignés, membres adhérant au groupe de tontine "${widget.tontine.name}" :\n\n'
                      '1. Engagement de Cotisation : Chaque membre s\'engage à cotiser la somme de ${currencyFormat.format(widget.tontine.amount)} de manière régulière selon la fréquence configurée (${widget.tontine.frequency == 'weekly' ? 'Hebdomadaire' : widget.tontine.frequency == 'monthly' ? 'Mensuelle' : 'Quotidienne'}).\n\n'
                      '2. Rôle du Trésorier : Le trésorier est chargé de valider manuellement la réception des cotisations de chaque membre (effectuées en mains propres ou par Mobile Money hors-application).\n\n'
                      '3. Pénalités de retard : Tout retard ou défaut de paiement sera consigné sur l\'application et impactera directement le score de réputation (Trust Score) de l\'adhérent (-5 points pour retard simple, -20 points pour défaut).\n\n'
                      '4. Résolution des différends : En cas de litige persistant, les parties conviennent de soumettre leur différend à une médiation interne ou à l\'arbitrage conformément aux règles locales.',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_hasSigned)
              ElevatedButton.icon(
                onPressed: _signContract,
                icon: const Icon(Icons.draw, color: Colors.black),
                label: const Text('Signer électroniquement (Case à cocher certifiée)'),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.roundTwelve),
                  border: Border.all(color: AppConstants.primaryColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppConstants.primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous avez signé ce contrat d\'accord.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Le groupe commencera à cotiser dès que tous les membres auront signé le contrat.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Active or completed tontine
    if (_activeRound == null) {
      return const Center(child: Text('Aucun tour actif trouvé.'));
    }

    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Round Box
          Card(
            color: AppConstants.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOUR ${_activeRound!.roundNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'En cours',
                          style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppConstants.backgroundColor, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bénéficiaire du tour', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          FutureBuilder<Profile?>(
                            future: SupabaseService.instance.getProfileById(_activeRound!.beneficiaryId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('Chargement...');
                              }
                              return Text(
                                snapshot.data?.fullName ?? 'Inconnu',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Fin du tour', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(_activeRound!.endDate),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.alertColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suivi des cotisations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.gavel, color: AppConstants.alertColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisputeScreen(
                        tontine: widget.tontine,
                        members: _members,
                      ),
                    ),
                  );
                },
                tooltip: 'Signaler un litige',
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_roundPayments.isEmpty)
            const Center(child: Text('Aucun paiement généré pour ce tour.'))
          else
            ..._roundPayments.map((payment) {
              final memberData = _members.firstWhere(
                (m) => m['profile'].id == payment.payerId,
                orElse: () => {'profile': Profile(id: '', phone: '', fullName: 'Inconnu', trustScore: 70, createdAt: DateTime.now())},
              );
              final Profile profile = memberData['profile'] as Profile;

              return Card(
                color: AppConstants.cardColor.withOpacity(0.6),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              profile.phone,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      _buildPaymentStatusIndicator(payment),
                      const SizedBox(width: 8),
                      // If treasurer and pending, show validation actions
                      if (_userRole == 'treasurer' && payment.status == 'pending')
                        PopupMenuButton<String>(
                          onSelected: (action) => _confirmPayment(payment.id, action),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'paid',
                              child: Text('✅ Reçu à l\'heure'),
                            ),
                            const PopupMenuItem(
                              value: 'late',
                              child: Text('⏰ Reçu en retard'),
                            ),
                          ],
                          icon: const Icon(Icons.check_circle_outline, color: AppConstants.primaryColor),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusIndicator(Payment payment) {
    String text = '';
    Color color = Colors.white;

    switch (payment.status) {
      case 'pending':
        text = 'En attente';
        color = AppConstants.textSecondaryColor;
        break;
      case 'paid':
        text = 'Payé';
        color = AppConstants.primaryColor;
        break;
      case 'late':
        text = 'En Retard';
        color = AppConstants.alertColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final Profile profile = member['profile'] as Profile;
        final String role = member['role'] as String;
        final bool signed = member['signed_contract_at'] != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.backgroundColor,
              child: Text(
                profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              profile.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${profile.phone} • Score: ${profile.trustScore}/100',
              style: const TextStyle(color: AppConstants.textSecondaryColor),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  role == 'treasurer' ? 'Trésorier' : 'Membre',
                  style: TextStyle(
                    color: role == 'treasurer' ? AppConstants.primaryColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signed ? '✍️ Signé' : '⏳ Non signé',
                  style: TextStyle(
                    color: signed ? AppConstants.primaryColor : AppConstants.scoreColor,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
