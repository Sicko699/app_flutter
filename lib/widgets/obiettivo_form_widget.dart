import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/obiettivo_risparmio_service.dart';
import '../models/obiettivo_risparmio.dart';

class ObiettivoFormWidget extends StatefulWidget {
  final ObiettivoRisparmio? obiettivo;

  const ObiettivoFormWidget({super.key, this.obiettivo});

  @override
  State<ObiettivoFormWidget> createState() => _ObiettivoFormWidgetState();
}

class _ObiettivoFormWidgetState extends State<ObiettivoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _importoTargetController = TextEditingController();
  final _dataScadenzaController = TextEditingController();
  
  String _selectedIcona = 'Savings';
  String _selectedColore = '#B0BEC5';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _icone = [
    {'nome': 'Savings', 'icona': Icons.savings, 'colore': '#B0BEC5'},
    {'nome': 'Car', 'icona': Icons.directions_car, 'colore': '#FF5722'},
    {'nome': 'Home', 'icona': Icons.home, 'colore': '#4CAF50'},
    {'nome': 'Vacation', 'icona': Icons.flight, 'colore': '#2196F3'},
    {'nome': 'Gift', 'icona': Icons.card_giftcard, 'colore': '#E91E63'},
    {'nome': 'Education', 'icona': Icons.school, 'colore': '#9C27B0'},
    {'nome': 'Health', 'icona': Icons.health_and_safety, 'colore': '#F44336'},
    {'nome': 'Electronics', 'icona': Icons.devices, 'colore': '#607D8B'},
    {'nome': 'Clothing', 'icona': Icons.checkroom, 'colore': '#FF9800'},
    {'nome': 'Food', 'icona': Icons.restaurant, 'colore': '#795548'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.obiettivo != null) {
      _nomeController.text = widget.obiettivo!.nome;
      _importoTargetController.text = widget.obiettivo!.importoTarget.toString();
      _dataScadenzaController.text = widget.obiettivo!.dataScadenza;
      _selectedIcona = widget.obiettivo!.icona;
      _selectedColore = widget.obiettivo!.coloreIcona;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _importoTargetController.dispose();
    _dataScadenzaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header moderno con gradiente
            _buildModernHeader(),
            
            // Contenuto del form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome obiettivo
                      _buildModernTextField(
                        controller: _nomeController,
                        label: 'Nome Obiettivo',
                        icon: Icons.flag,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci un nome per l\'obiettivo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Importo target
                      _buildAmountField(),
                      const SizedBox(height: 20),
                      // Data scadenza
                      _buildDateField(),
                      const SizedBox(height: 24),

                      // Selezione icona
                      _buildIconSection(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer con pulsanti
            _buildFooter(),
          ],
        ),
      ),
    );
  }



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dataScadenzaController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveObiettivo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
      
      if (widget.obiettivo == null) {
        // Crea nuovo obiettivo
        final success = await obiettivoService.creaObiettivo(
          nome: _nomeController.text.trim(),
          icona: _selectedIcona,
          coloreIcona: _selectedColore,
          importoTarget: double.parse(_importoTargetController.text),
          dataScadenza: _dataScadenzaController.text,
        );

        if (success && context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obiettivo creato con successo!')),
          );
        }
      } else {
        // Aggiorna obiettivo esistente
        final success = await obiettivoService.aggiornaObiettivo(
          obiettivoId: widget.obiettivo!.id,
          nome: _nomeController.text.trim(),
          icona: _selectedIcona,
          coloreIcona: _selectedColore,
          importoTarget: double.parse(_importoTargetController.text),
          dataScadenza: _dataScadenzaController.text,
        );

        if (success && context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obiettivo aggiornato con successo!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteObiettivo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questo obiettivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
        final success = await obiettivoService.eliminaObiettivo(widget.obiettivo!.id);

        if (success && context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obiettivo eliminato con successo!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(_selectedColore.replaceAll('#', '0xFF'))),
            Color(int.parse(_selectedColore.replaceAll('#', '0xFF'))).withOpacity(0.8),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _getSelectedIcon(),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.obiettivo == null ? 'Nuovo Obiettivo' : 'Modifica Obiettivo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.obiettivo == null 
                ? 'Crea un nuovo obiettivo di risparmio'
                : 'Modifica il tuo obiettivo di risparmio',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildAmountField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: _importoTargetController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Inserisci l\'importo target';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Inserisci un importo valido';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Importo Target',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Scadenza (opzionale)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dataScadenzaController.text.isEmpty 
                        ? 'Nessuna scadenza'
                        : _formatDisplayDate(_dataScadenzaController.text),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleziona Icona e Colore',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _icone.length,
          itemBuilder: (context, index) {
            final icona = _icone[index];
            final isSelected = _selectedIcona == icona['nome'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcona = icona['nome']!;
                  _selectedColore = icona['colore']!;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(int.parse(icona['colore']!.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(color: isDark ? Colors.white : Theme.of(context).colorScheme.primary, width: 3)
                      : Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Icon(
                    icona['icona'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (widget.obiettivo != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _deleteObiettivo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Elimina'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
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
              onPressed: _isLoading ? null : _saveObiettivo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(int.parse(_selectedColore.replaceAll('#', '0xFF'))),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.obiettivo == null ? 'Crea Obiettivo' : 'Salva Modifiche',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSelectedIcon() {
    final iconaData = _icone.firstWhere(
      (icona) => icona['nome'] == _selectedIcona,
      orElse: () => _icone.first,
    );
    return iconaData['icona'] as IconData;
  }

  String _formatDisplayDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 