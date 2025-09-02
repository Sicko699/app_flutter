import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conto_service.dart';
import '../services/transazione_service.dart';
import '../widgets/conto_form_widget.dart';
import '../models/conto.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  bool _showForm = false;
  bool _isEditing = false;
  Conto? _contoInModifica;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica Conto' : 'I miei Conti'),
        actions: [
          if (_showForm)
            IconButton(
              onPressed: () {
                setState(() {
                  _showForm = false;
                  _isEditing = false;
                  _contoInModifica = null;
                });
              },
              icon: const Icon(Icons.close),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _isEditing = false;
                  _contoInModifica = null;
                });
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Consumer2<ContoService, TransazioneService>(
        builder: (context, contoService, transazioneService, _) {
          if (_showForm) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ContoFormWidget(
                onSave: _isEditing ? _aggiornaConto : _salvaConto,
                onCancel: () {
                  setState(() {
                    _showForm = false;
                    _isEditing = false;
                    _contoInModifica = null;
                  });
                },
                initialNome: _contoInModifica?.nome,
                initialTipo: _contoInModifica?.tipo,
                initialSaldo: _contoInModifica?.saldo,
                isEditing: _isEditing,
              ),
            );
          }
          
          // Modalità lista - usa la struttura esistente
          return contoService.conti.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contoService.conti.length,
                  itemBuilder: (context, index) {
                          final conto = contoService.conti[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header con nome, tipo e menu
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: _getTipoColor(conto.tipo),
                                          child: Icon(
                                            _getTipoIcon(conto.tipo),
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                conto.nome,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                conto.tipo,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert, size: 20),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              _modificaConto(conto);
                                            } else if (value == 'delete') {
                                              _eliminaConto(conto);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit),
                                                  SizedBox(width: 8),
                                                  Text('Modifica'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Elimina', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Saldo Attuale',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '€ ${conto.saldo.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: conto.saldo >= 0 ? Colors.green[700] : Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildContoStatsImproved(conto, contoService, transazioneService),
                                   ],
                                 ),
                               ),
                          );
                        },
                      );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun conto aggiunto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi il tuo primo conto per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showForm = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Primo Conto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _salvaConto(String nome, String tipo, double saldo) async {
    final contoService = Provider.of<ContoService>(context, listen: false);
    bool successo = await contoService.creaConto(
      nome: nome,
      tipo: tipo,
      saldo: saldo,
    );

    if (successo && context.mounted) {
      setState(() {
        _showForm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conto aggiunto con successo!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${contoService.error}')),
      );
    }
  }

  Future<void> _aggiornaConto(String nome, String tipo, double saldo) async {
    if (_contoInModifica == null) return;
    
    final contoService = Provider.of<ContoService>(context, listen: false);
    bool successo = await contoService.aggiornaConto(
      contoId: _contoInModifica!.id,
      nome: nome,
      tipo: tipo,
    );

    if (successo && context.mounted) {
      setState(() {
        _showForm = false;
        _isEditing = false;
        _contoInModifica = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conto aggiornato con successo!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${contoService.error}')),
      );
    }
  }

  Future<void> _eliminaConto(Conto conto) async {
    // Mostra dialog di conferma
    bool conferma = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sei sicuro di voler eliminare il conto "${conto.nome}"?'),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Attenzione: Verranno eliminate anche tutte le transazioni associate a questo conto.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Questa azione non può essere annullata.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    ) ?? false;

    if (!conferma) return;

    final contoService = Provider.of<ContoService>(context, listen: false);
    bool successo = await contoService.eliminaConto(conto.id);

    if (successo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conto eliminato con successo!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${contoService.error}')),
      );
    }
  }

  void _modificaConto(Conto conto) {
    setState(() {
      _isEditing = true;
      _contoInModifica = conto;
      _showForm = true;
    });
  }

  Widget _buildContoStats(conto, ContoService contoService, TransazioneService transazioneService) {
    final stats = contoService.calcolaStatisticheMensili(
      conto.id, 
      transazioneService.transazioni
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(conto.tipo),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                'Entrate: € ${stats['entrate']!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Uscite: € ${stats['uscite']!.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContoStatsImproved(conto, ContoService contoService, TransazioneService transazioneService) {
    final stats = contoService.calcolaStatisticheMensili(
      conto.id, 
      transazioneService.transazioni
    );
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entrate',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '€ ${stats['entrate']!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_down,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uscite',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '€ ${stats['uscite']!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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