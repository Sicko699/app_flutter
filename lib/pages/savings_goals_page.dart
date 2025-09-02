import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/obiettivo_risparmio_service.dart';
import '../services/conto_service.dart';
import '../services/transazione_service.dart';
import '../models/obiettivo_risparmio.dart';
import '../models/conto.dart';
import '../widgets/obiettivo_form_widget.dart';
import '../utils/color_utils.dart';

class SavingsGoalsPage extends StatefulWidget {
  const SavingsGoalsPage({super.key});

  @override
  State<SavingsGoalsPage> createState() => _SavingsGoalsPageState();
}

class _SavingsGoalsPageState extends State<SavingsGoalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaObiettivi();
    });
  }

  Future<void> _caricaObiettivi() async {
    final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
    final contoService = Provider.of<ContoService>(context, listen: false);
    await Future.wait([
      obiettivoService.caricaObiettivi(),
      contoService.caricaConti(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obiettivi di Risparmio'),
        actions: [
          IconButton(
            onPressed: () => _showAddObiettivoDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _caricaObiettivi,
        child: Consumer<ObiettivoRisparmioService>(
          builder: (context, obiettivoService, _) {
            if (obiettivoService.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final obiettivi = obiettivoService.obiettivi;

            if (obiettivi.isEmpty) {
              return _buildEmptyState();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(obiettivoService),
                const SizedBox(height: 24),
                _buildObiettiviList(obiettivi, obiettivoService),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessun obiettivo di risparmio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea il tuo primo obiettivo di risparmio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddObiettivoDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Crea Obiettivo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ObiettivoRisparmioService obiettivoService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riepilogo Obiettivi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Totale Risparmiato',
                    '€ ${obiettivoService.totaleRisparmiato.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Obiettivo Totale',
                    '€ ${obiettivoService.totaleTarget.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: obiettivoService.percentualeTotaleCompletamento / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                obiettivoService.percentualeTotaleCompletamento >= 100 
                    ? Colors.green 
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${obiettivoService.percentualeTotaleCompletamento.toStringAsFixed(1)}% completato',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildObiettiviList(List<ObiettivoRisparmio> obiettivi, ObiettivoRisparmioService obiettivoService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I tuoi Obiettivi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...obiettivi.map((obiettivo) => _buildObiettivoCard(obiettivo, obiettivoService)),
      ],
    );
  }

  Widget _buildObiettivoCard(ObiettivoRisparmio obiettivo, ObiettivoRisparmioService obiettivoService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showObiettivoDetails(context, obiettivo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorUtils.hexToColor(obiettivo.coloreIcona),
                      borderRadius: BorderRadius.circular(8),
                    ),
                                         child: Icon(
                       ObiettivoRisparmio.getIconData(obiettivo.icona),
                       color: Colors.white,
                       size: 20,
                     ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obiettivo.nome,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (obiettivo.dataScadenza.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Scadenza: ${_formatDate(obiettivo.dataScadenza)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (obiettivo.isCompletato)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completato',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '€ ${obiettivo.importoAttuale.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'di € ${obiettivo.importoTarget.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${obiettivo.percentualeCompletamento.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: obiettivo.isCompletato ? Colors.green : Colors.blue,
                          ),
                        ),
                        Text(
                          'Completato',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: obiettivo.percentualeCompletamento / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  obiettivo.isCompletato ? Colors.green : Colors.blue,
                ),
              ),
              if (!obiettivo.isCompletato) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showAddAmountDialog(context, obiettivo),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aggiungi Importo'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showAddObiettivoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ObiettivoFormWidget(),
    );
  }

  void _showObiettivoDetails(BuildContext context, ObiettivoRisparmio obiettivo) {
    showDialog(
      context: context,
      builder: (context) => ObiettivoFormWidget(obiettivo: obiettivo),
    );
  }

  void _showAddAmountDialog(BuildContext context, ObiettivoRisparmio obiettivo) {
    final amountController = TextEditingController();
    bool isLoading = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Conto? selectedConto;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Header con gradiente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtils.hexToColor(obiettivo.coloreIcona),
                        ColorUtils.hexToColor(obiettivo.coloreIcona).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          ObiettivoRisparmio.getIconData(obiettivo.icona),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aggiungi Importo',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        obiettivo.nome,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Contenuto
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Progress e importi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Attuale',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '€${obiettivo.importoAttuale.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Target',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '€${obiettivo.importoTarget.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: obiettivo.percentualeCompletamento / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorUtils.hexToColor(obiettivo.coloreIcona),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${obiettivo.percentualeCompletamento.toStringAsFixed(1)}% completato',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Selettore conto
                      Consumer<ContoService>(
                        builder: (context, contoService, _) {
                          final conti = contoService.conti;
                          
                          // Inizializza selectedConto se è null e ci sono conti disponibili
                          if (selectedConto == null && conti.isNotEmpty) {
                            selectedConto = conti.first;
                          }
                          
                          if (conti.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Nessun conto disponibile. Aggiungi un conto per continuare.',
                                      style: TextStyle(color: Colors.orange[700]),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          // Verifica che selectedConto sia ancora nella lista
                          if (selectedConto != null && !conti.contains(selectedConto)) {
                            selectedConto = conti.isNotEmpty ? conti.first : null;
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conto di origine',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonFormField<Conto>(
                                  value: selectedConto,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    border: InputBorder.none,
                                    filled: true,
                                    fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
                                  ),
                                  hint: const Text('Seleziona un conto'),
                                  items: conti.map((conto) {
                                    return DropdownMenuItem<Conto>(
                                      value: conto,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: _getTipoColor(conto.tipo),
                                            child: Icon(
                                              _getTipoIcon(conto.tipo),
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              '${conto.nome}\nSaldo: €${conto.saldo?.toStringAsFixed(2) ?? '0.00'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (Conto? value) {
                                    setState(() {
                                      selectedConto = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Campo importo
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Importo da aggiungere',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.euro, color: Colors.green, size: 20),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.green, width: 2),
                          ),
                          filled: true,
                          fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Annulla'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            final amount = double.tryParse(amountController.text);
                            if (amount != null && amount > 0 && selectedConto != null) {
                              // Verifica che il conto abbia fondi sufficienti
                              if (selectedConto!.saldo != null && selectedConto!.saldo! < amount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Saldo insufficiente nel conto selezionato'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              setState(() => isLoading = true);
                              
                              try {
                                final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
                                final contoService = Provider.of<ContoService>(context, listen: false);
                                final transazioneService = Provider.of<TransazioneService>(context, listen: false);
                                
                                // Aggiungi importo all'obiettivo
                                await obiettivoService.aggiungiImporto(
                                  obiettivoId: obiettivo.id,
                                  importo: amount,
                                  contoId: selectedConto!.id,
                                );
                                
                                // Crea una transazione per tracciare il trasferimento
                                await transazioneService.creaTransazione(
                                  titolo: 'Versamento obiettivo: ${obiettivo.nome}',
                                  descrizione: 'Versamento automatico per obiettivo di risparmio',
                                  importo: amount,
                                  tipo: 'uscita',
                                  categoriaId: '', // Categoria speciale per obiettivi
                                  sottocategoriaId: '', // Sottocategoria vuota per obiettivi
                                  contoId: selectedConto!.id,
                                  data: DateTime.now(),
                                );
                                
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('€${amount.toStringAsFixed(2)} aggiunto con successo da ${selectedConto!.nome}!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Errore: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            } else if (selectedConto == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Seleziona un conto di origine'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Aggiungi Importo',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
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
      case 'Risparmio':
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
      case 'Risparmio':
        return Icons.savings;
      default:
        return Icons.account_balance_wallet;
    }
  }
} 