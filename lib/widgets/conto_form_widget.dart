import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/onboarding_constants.dart';

class ContoFormWidget extends StatefulWidget {
  final Function(String nome, String tipo, double saldo) onSave;
  final VoidCallback? onCancel;
  final String? initialNome;
  final String? initialTipo;
  final double? initialSaldo;
  final bool isEditing;

  const ContoFormWidget({
    super.key,
    required this.onSave,
    this.onCancel,
    this.initialNome,
    this.initialTipo,
    this.initialSaldo,
    this.isEditing = false,
  });

  @override
  State<ContoFormWidget> createState() => _ContoFormWidgetState();
}

class _ContoFormWidgetState extends State<ContoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _saldoController = TextEditingController();
  String _selectedTipo = OnboardingConstants.tipiConto.first;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nomeController.text = widget.initialNome ?? '';
      _saldoController.text = widget.initialSaldo?.toStringAsFixed(2) ?? '';
      _selectedTipo = widget.initialTipo ?? OnboardingConstants.tipiConto.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con gradiente
            _buildModernHeader(context),
            const SizedBox(height: 24),
            
            // Sezione Informazioni Base
            _buildBaseInfoSection(context),
            const SizedBox(height: 16),
            
            // Sezione Tipo
            _buildTypeSection(context),
            const SizedBox(height: 16),
            
            // Sezione Saldo
            _buildBalanceSection(context),
            const SizedBox(height: 32),
            
            // Pulsanti Azione
            _buildActionButtons(context),
            const SizedBox(height: 16), // Spazio extra per il padding
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.isEditing ? Icons.edit : Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Modifica Conto' : 'Nuovo Conto',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEditing 
                      ? 'Aggiorna le informazioni del conto'
                      : 'Aggiungi un nuovo conto alla tua gestione',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseInfoSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informazioni Base',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernTextField(
              controller: _nomeController,
              label: 'Nome Conto',
              hint: 'Es. Conto Principale, Portafoglio, ecc.',
              icon: Icons.account_balance,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci il nome del conto';
              }
              return null;
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tipo di Conto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernDropdown(
              value: _selectedTipo,
              label: 'Tipo di Conto',
              icon: Icons.account_tree,
              items: OnboardingConstants.tipiConto,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTipo = newValue!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Seleziona il tipo di conto';
              }
              return null;
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.euro,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Saldo Iniziale',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _saldoController,
              label: 'Saldo Iniziale',
              hint: '0.00',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci il saldo iniziale';
              }
              double? saldo = double.tryParse(value);
              if (saldo == null) {
                return 'Inserisci un valore numerico valido';
              }
              return null;
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark 
            ? theme.colorScheme.surface.withOpacity(0.8)
            : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildModernDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark 
            ? theme.colorScheme.surface.withOpacity(0.8)
            : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String tipo) {
        return DropdownMenuItem<String>(
          value: tipo,
          child: Text(tipo),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.euro),
        prefixText: '€ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: isDark 
            ? theme.colorScheme.surface.withOpacity(0.8)
            : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: validator,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (widget.onCancel != null) {
                widget.onCancel!();
              } else {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Annulla'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
            child: ElevatedButton(
              onPressed: _salvaConto,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              widget.isEditing ? 'Aggiorna Conto' : 'Aggiungi Conto',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ),
          ),
        ],
    );
  }

  void _salvaConto() {
    if (_formKey.currentState!.validate()) {
      double saldo = double.parse(_saldoController.text);
      widget.onSave(
        _nomeController.text.trim(),
        _selectedTipo,
        saldo,
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _saldoController.dispose();
    super.dispose();
  }
} 