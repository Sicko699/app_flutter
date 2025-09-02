import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conto_service.dart';
import '../widgets/conto_form_widget.dart';
import '../utils/notch_safe_area.dart';

class OnboardingAccountsPage extends StatefulWidget {
  const OnboardingAccountsPage({super.key});

  @override
  State<OnboardingAccountsPage> createState() => _OnboardingAccountsPageState();
}

class _OnboardingAccountsPageState extends State<OnboardingAccountsPage> {
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _caricaConti();
  }

  Future<void> _caricaConti() async {
    final contoService = Provider.of<ContoService>(context, listen: false);
    await contoService.caricaConti();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ContoService>(
      builder: (context, contoService, _) {
        if (contoService.conti.isEmpty && !_showForm) {
          return _buildEmptyState(theme);
        }
        
        if (_showForm) {
          return _buildFormView(theme);
        }
        
        return _buildAccountsList(theme, contoService);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NotchSafeArea(
        padding: EdgeInsets.only(
          top: context.notchSafeTopPadding + 16, // Padding dinamico per la notch
        ),
        child: Column(
          children: [
            // Header con icona e titolo
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), // Padding ridotto perché gestito da NotchSafeArea
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icona
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'I tuoi conti',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Aggiungi i tuoi conti bancari per iniziare a tracciare le tue finanze',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Contenuto vuoto
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessun conto ancora aggiunto',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inizia aggiungendo il tuo primo conto',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showForm = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi Primo Conto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NotchSafeArea(
        padding: EdgeInsets.only(
          top: context.notchSafeTopPadding + 16, // Padding dinamico per la notch
        ),
        child: Column(
          children: [
            // Header con icona e titolo
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), // Padding ridotto perché gestito da NotchSafeArea
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icona
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'Aggiungi conto',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Inserisci i dettagli del tuo conto bancario',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: ContoFormWidget(
                onSave: (nome, tipo, saldo) async {
                  final contoService = Provider.of<ContoService>(context, listen: false);
                  final success = await contoService.creaConto(
                    nome: nome,
                    tipo: tipo,
                    saldo: saldo,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conto aggiunto con successo!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _salvaConto();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore: ${contoService.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                onCancel: () {
                  setState(() {
                    _showForm = false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(ThemeData theme, ContoService contoService) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NotchSafeArea(
        padding: EdgeInsets.only(
          top: context.notchSafeTopPadding + 16, // Padding dinamico per la notch
        ),
        child: Column(
          children: [
            // Header con icona e titolo
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24), // Padding ridotto perché gestito da NotchSafeArea
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icona
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'I tuoi conti',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Gestisci i tuoi conti bancari',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Lista conti
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: contoService.conti.length,
                      itemBuilder: (context, index) {
                        final conto = contoService.conti[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getTipoColor(conto.tipo),
                              child: Icon(
                                _getTipoIcon(conto.tipo),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(conto.nome),
                            subtitle: Text(conto.tipo),
                            trailing: Text(
                              '€ ${conto.saldo.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Pulsante per aggiungere altro conto
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showForm = true;
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Aggiungi Altro Conto'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvaConto() async {
    setState(() {
      _showForm = false;
    });
    await _caricaConti();
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'Contanti':
        return Colors.green;
      case 'Conto':
        return Colors.blue;
      case 'Carta':
        return Colors.orange;
      case 'Investimento':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'Contanti':
        return Icons.money;
      case 'Conto':
        return Icons.account_balance;
      case 'Carta':
        return Icons.credit_card;
      case 'Investimento':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
} 