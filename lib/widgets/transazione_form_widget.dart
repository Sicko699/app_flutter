import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/conto_service.dart';
import '../services/categoria_service.dart';
import '../models/conto.dart';
import '../models/categoria.dart';
import '../models/sottocategoria.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';

class TransazioneFormWidget extends StatefulWidget {
  final Function(String titolo, String descrizione, double importo, String tipo, 
                String categoriaId, String sottocategoriaId, String contoId, 
                String? contoDestinazioneId, DateTime data, bool isRicorrente, 
                String? frequenzaRicorrenza, DateTime? dataFineRicorrenza) onSave;
  final VoidCallback? onFormReset;
  
  final String? initialTitolo;
  final double? initialImporto;
  final String? initialTipo;
  final String? initialCategoriaId;
  final String? initialSottocategoriaId;
  final String? initialContoId;
  final String? initialContoDestinazioneId;
  final DateTime? initialData;
  final bool? initialIsRicorrente;
  final String? initialFrequenzaRicorrenza;
  final DateTime? initialDataFineRicorrenza;

  const TransazioneFormWidget({
    super.key,
    required this.onSave,
    this.onFormReset,
    this.initialTitolo,
    this.initialImporto,
    this.initialTipo,
    this.initialCategoriaId,
    this.initialSottocategoriaId,
    this.initialContoId,
    this.initialContoDestinazioneId,
    this.initialData,
    this.initialIsRicorrente,
    this.initialFrequenzaRicorrenza,
    this.initialDataFineRicorrenza,
  });

  @override
  State<TransazioneFormWidget> createState() => _TransazioneFormWidgetState();
}

class _TransazioneFormWidgetState extends State<TransazioneFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _importoController = TextEditingController();
  
  String _tipoSelezionato = 'uscita';
  String? _categoriaSelezionata;
  String? _sottocategoriaSelezionata;
  String? _contoSelezionato;
  String? _contoDestinazioneSelezionato;
  DateTime _dataSelezionata = DateTime.now();
  bool _isRicorrente = false;
  String? _frequenzaSelezionata;
  DateTime? _dataFineRicorrenza;

  final List<String> _tipi = ['uscita', 'entrata', 'trasferimento'];
  final List<String> _frequenze = ['giornaliera', 'settimanale', 'mensile', 'annuale'];

  @override
  void initState() {
    super.initState();
    _titoloController.text = widget.initialTitolo ?? '';
    _importoController.text = widget.initialImporto?.toStringAsFixed(2) ?? '';
    _tipoSelezionato = widget.initialTipo ?? 'uscita';
    _categoriaSelezionata = widget.initialCategoriaId;
    _sottocategoriaSelezionata = widget.initialSottocategoriaId;
    _contoSelezionato = widget.initialContoId;
    _contoDestinazioneSelezionato = widget.initialContoDestinazioneId;
    _dataSelezionata = widget.initialData ?? DateTime.now();
    _isRicorrente = widget.initialIsRicorrente ?? false;
    _frequenzaSelezionata = widget.initialFrequenzaRicorrenza;
    _dataFineRicorrenza = widget.initialDataFineRicorrenza;
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _importoController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titoloController.clear();
    _importoController.clear();
    
    setState(() {
      _tipoSelezionato = 'uscita';
      _categoriaSelezionata = null;
      _sottocategoriaSelezionata = null;
      _contoSelezionato = null;
      _contoDestinazioneSelezionato = null;
      _dataSelezionata = DateTime.now();
      _isRicorrente = false;
      _frequenzaSelezionata = null;
      _dataFineRicorrenza = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Sezione principale
            _buildMainSection(),
            const SizedBox(height: 24),

            // Sezione categorie
            _buildCategorySection(),
            const SizedBox(height: 24),

            // Sezione data e ricorrenza
            _buildDateAndRecurrenceSection(),
            const SizedBox(height: 32),

            // Pulsanti azioni
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getTypeColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getTypeColors().first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icona tipo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          
          // Titolo tipo
          Text(
            _getTypeTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Descrizione tipo
          Text(
            _getTypeDescription(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo sezione
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_note,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Dettagli Transazione',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          // Titolo
            _buildModernTextField(
            controller: _titoloController,
              label: 'Titolo',
              icon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un titolo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

            // Importo
            _buildAmountField(),
            const SizedBox(height: 16),

            // Tipo selettore
            _buildTypeSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildAmountField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return TextFormField(
      controller: _importoController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Inserisci un importo';
              }
              final importo = double.tryParse(value.replaceAll(',', '.'));
              if (importo == null || importo <= 0) {
                return 'Inserisci un importo valido';
              }
              return null;
            },
      decoration: InputDecoration(
        labelText: 'Importo',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.euro, color: Colors.white, size: 20),
        ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo di Transazione',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _tipi.map((tipo) {
            final isSelected = _tipoSelezionato == tipo;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _tipoSelezionato = tipo;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _getTypeColor(tipo) : (isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _getTypeColor(tipo) : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: Column(
                  children: [
                    Icon(
                        _getTypeIcon(tipo),
                        color: isSelected ? Colors.white : _getTypeColor(tipo),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tipo.capitalize(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : _getTypeColor(tipo),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                ),
              );
            }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo sezione
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Conti e Categorie',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          // Conto
            _buildAccountSelector(),
            const SizedBox(height: 16),

            // Conto di destinazione (solo per trasferimenti)
            if (_tipoSelezionato == 'trasferimento') ...[
              _buildDestinationAccountSelector(),
              const SizedBox(height: 16),
            ],

            // Categoria
            if (_tipoSelezionato != 'trasferimento') ...[
              _buildCategorySelector(),
              const SizedBox(height: 16),

              // Sottocategoria
              _buildSubcategorySelector(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ContoService>(
            builder: (context, contoService, _) {
              final conti = contoService.conti;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conto',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _contoSelezionato,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                items: conti.map<DropdownMenuItem<String>>((conto) {
                  return DropdownMenuItem(
                    value: conto.id,
                        child: Row(
                          children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(
                                  conto.nome,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  conto.tipo,
                              style: TextStyle(
                                    color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                          ),
                          Text(
                            '€ ${(conto.saldo ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: (conto.saldo ?? 0.0) >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _contoSelezionato = value;
                  });
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestinationAccountSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ContoService>(
              builder: (context, contoService, _) {
        final conti = contoService.conti.where((conto) => conto.id != _contoSelezionato).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conto di Destinazione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _contoDestinazioneSelezionato,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  items: conti.map<DropdownMenuItem<String>>((conto) {
                    return DropdownMenuItem(
                      value: conto.id,
                        child: Row(
                          children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance, color: Colors.orange, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(
                                  conto.nome,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  conto.tipo,
                              style: TextStyle(
                                    color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                          ),
                          Text(
                            '€ ${(conto.saldo ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: (conto.saldo ?? 0.0) >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _contoDestinazioneSelezionato = value;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<CategoriaService>(
            builder: (context, categoriaService, _) {
              final categorie = categoriaService.categorie;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categoriaSelezionata,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                items: categorie.map<DropdownMenuItem<String>>((categoria) {
                  return DropdownMenuItem(
                    value: categoria.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 16,
                          backgroundColor: ColorUtils.hexToColor(categoria.coloreIcona),
                          child: Icon(
                            IconUtils.getIconData(categoria.icona),
                            color: Colors.white,
                            size: 20,
                          ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            categoria.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSelezionata = value;
                      _sottocategoriaSelezionata = null;
                  });
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategorySelector() {
    return Consumer<CategoriaService>(
            builder: (context, categoriaService, _) {
        if (_categoriaSelezionata == null) return const SizedBox.shrink();

              final categoria = categoriaService.categorie
                  .firstWhere((c) => c.id == _categoriaSelezionata);
              final sottocategorie = categoria.sottocategorie;

        if (sottocategorie.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sottocategoria (opzionale)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sottocategoriaSelezionata,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                items: sottocategorie.map<DropdownMenuItem<String>>((sottocategoria) {
                  return DropdownMenuItem(
                    value: sottocategoria.id,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.subdirectory_arrow_right, 
                              color: Theme.of(context).colorScheme.secondary, 
                              size: 16
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            sottocategoria.nome,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sottocategoriaSelezionata = value;
                  });
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateAndRecurrenceSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo sezione
            Row(
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
                Text(
                  'Data e Ricorrenza',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

          // Data
            _buildDateSelector(),
            const SizedBox(height: 20),

            // Transazione ricorrente
            _buildRecurrenceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Transazione',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dataSelezionata,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
              );
              if (date != null) {
                setState(() {
                  _dataSelezionata = date;
                });
              }
            },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade600 
                    : Colors.grey.shade300
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                  : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_dataSelezionata.day.toString().padLeft(2, '0')}/${_dataSelezionata.month.toString().padLeft(2, '0')}/${_dataSelezionata.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Switch ricorrenza
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade600 
                  : Colors.grey.shade300
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transazione Ricorrente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Ripeti questa transazione periodicamente',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
            value: _isRicorrente,
            onChanged: (value) {
              setState(() {
                    _isRicorrente = value;
                if (!_isRicorrente) {
                  _frequenzaSelezionata = null;
                  _dataFineRicorrenza = null;
                }
              });
            },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          ),

          if (_isRicorrente) ...[
            const SizedBox(height: 16),
          _buildFrequencySelector(),
          const SizedBox(height: 16),
          _buildEndDateSelector(),
        ],
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequenza',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade600 
                  : Colors.grey.shade300
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _frequenzaSelezionata,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              items: _frequenze.map<DropdownMenuItem<String>>((frequenza) {
                return DropdownMenuItem(
                  value: frequenza,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.repeat, 
                          color: Theme.of(context).colorScheme.primary, 
                          size: 16
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getFrequenzaTesto(frequenza),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _frequenzaSelezionata = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Fine Ricorrenza (opzionale)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dataFineRicorrenza ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
                );
                if (date != null) {
                  setState(() {
                    _dataFineRicorrenza = date;
                  });
                }
              },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey.shade600 
                    : Colors.grey.shade300
              ),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.8)
                  : Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_busy,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _dataFineRicorrenza != null
                      ? '${_dataFineRicorrenza!.day.toString().padLeft(2, '0')}/${_dataFineRicorrenza!.month.toString().padLeft(2, '0')}/${_dataFineRicorrenza!.year}'
                      : 'Nessuna data di fine',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _dataFineRicorrenza != null 
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
            child: ElevatedButton(
              onPressed: _salvaTransazione,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Salva Transazione',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
      ),
        ),
      ],
    );
  }

  void _salvaTransazione() {
    if (_formKey.currentState!.validate()) {
      final importo = double.parse(_importoController.text.replaceAll(',', '.'));
      
      widget.onSave(
        _titoloController.text.trim(),
        '', // Descrizione vuota
        importo,
        _tipoSelezionato,
        _categoriaSelezionata ?? '',
        _sottocategoriaSelezionata ?? '',
        _contoSelezionato!,
        _contoDestinazioneSelezionato,
        _dataSelezionata,
        _isRicorrente,
        _frequenzaSelezionata,
        _dataFineRicorrenza,
      );
      
      // Reset del form dopo il salvataggio
      _resetForm();
      
      // Notifica il callback opzionale
      widget.onFormReset?.call();
    }
  }

  String _getFrequenzaTesto(String frequenza) {
    switch (frequenza) {
      case 'giornaliera':
        return 'Ogni giorno';
      case 'settimanale':
        return 'Ogni settimana';
      case 'mensile':
        return 'Ogni mese';
      case 'annuale':
        return 'Ogni anno';
      default:
        return frequenza;
    }
  }

  // Metodi helper per il design moderno
  List<Color> _getTypeColors() {
    switch (_tipoSelezionato) {
      case 'entrata':
        return [Colors.green.shade400, Colors.green.shade600];
      case 'trasferimento':
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 'uscita':
      default:
        return [Colors.red.shade400, Colors.red.shade600];
    }
  }

  IconData _getTypeIcon([String? tipo]) {
    final tipoToUse = tipo ?? _tipoSelezionato;
    switch (tipoToUse) {
      case 'entrata':
        return Icons.trending_up;
      case 'trasferimento':
        return Icons.swap_horiz;
      case 'uscita':
      default:
        return Icons.trending_down;
    }
  }

  String _getTypeTitle() {
    switch (_tipoSelezionato) {
      case 'entrata':
        return 'Entrata';
      case 'trasferimento':
        return 'Trasf.';
      case 'uscita':
      default:
        return 'Uscita';
    }
  }

  String _getTypeDescription() {
    switch (_tipoSelezionato) {
      case 'entrata':
        return 'Registra un\'entrata di denaro';
      case 'trasferimento':
        return 'Sposta denaro tra conti';
      case 'uscita':
      default:
        return 'Registra una spesa';
    }
  }

  Color _getTypeColor(String tipo) {
    switch (tipo) {
      case 'entrata':
        return Colors.green;
      case 'trasferimento':
        return Colors.blue;
      case 'uscita':
      default:
        return Colors.red;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
} 