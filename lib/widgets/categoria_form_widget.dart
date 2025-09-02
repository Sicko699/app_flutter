import 'package:flutter/material.dart';
import '../utils/onboarding_constants.dart';
import '../utils/color_utils.dart';
import '../models/sottocategoria.dart';

class CategoriaFormWidget extends StatefulWidget {
  final Function(String nome, String icona, String colore, List<Sottocategoria> sottocategorie) onSave;
  final String? initialNome;
  final String? initialIcona;
  final String? initialColore;
  final List<Sottocategoria>? initialSottocategorie;
  final bool isEditing;

  const CategoriaFormWidget({
    super.key,
    required this.onSave,
    this.initialNome,
    this.initialIcona,
    this.initialColore,
    this.initialSottocategorie,
    this.isEditing = false,
  });

  @override
  State<CategoriaFormWidget> createState() => _CategoriaFormWidgetState();
}

class _CategoriaFormWidgetState extends State<CategoriaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _sottocategoriaController = TextEditingController();
  
  IconData _selectedIcon = OnboardingConstants.availableIcons.first;
  Color _selectedColor = OnboardingConstants.availableColors.first;
  List<Sottocategoria> _sottocategorie = [];
  bool _showIconPicker = false;
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nomeController.text = widget.initialNome ?? '';
      _selectedIcon = _getIconFromName(widget.initialIcona ?? '');
      _selectedColor = _getColorFromHex(widget.initialColore ?? '');
      _sottocategorie = widget.initialSottocategorie ?? [];
    }
  }

  /// Converte il nome dell'icona in IconData
  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'Home': return Icons.home;
      case 'ShoppingCart': return Icons.shopping_cart;
      case 'Restaurant': return Icons.restaurant;
      case 'CarRental': return Icons.directions_car;
      case 'LocalGasStation': return Icons.local_gas_station;
      case 'LocalHospital': return Icons.medical_services;
      case 'School': return Icons.school;
      case 'Build': return Icons.work;
      case 'FitnessCenter': return Icons.fitness_center;
      case 'Movie': return Icons.movie;
      case 'MusicNote': return Icons.music_note;
      case 'LocalDrink': return Icons.local_bar;
      case 'Coffee': return Icons.local_cafe;
      case 'Flight': return Icons.flight;
      case 'LocalPharmacy': return Icons.local_pharmacy;
      case 'LocalGroceryStore': return Icons.local_grocery_store;
      case 'AccountBalance': return Icons.account_balance;
      case 'CreditCard': return Icons.credit_card;
      case 'Savings': return Icons.savings;
      case 'Fastfood': return Icons.fastfood;
      case 'Pets': return Icons.pets;
      case 'DirectionsBus': return Icons.directions_bus;
      case 'ElectricBolt': return Icons.electric_bolt;
      case 'Checkroom': return Icons.checkroom;
      case 'Phone': return Icons.phone;
      case 'Favorite': return Icons.favorite;
      default: return Icons.shopping_cart; // fallback
    }
  }

  /// Converte il colore hex in Color (per compatibilità con i dati esistenti)
  Color _getColorFromHex(String colorValue) {
    // Se è già in formato hex, usa ColorUtils
    if (colorValue.startsWith('#')) {
      return ColorUtils.hexToColor(colorValue);
    }
    // Se è un numero (vecchio formato), cerca il colore corrispondente
    try {
      int colorInt = int.parse(colorValue);
      Color foundColor = OnboardingConstants.availableColors.firstWhere(
        (color) => color.value == colorInt,
        orElse: () => OnboardingConstants.availableColors.first,
      );
      return foundColor;
    } catch (e) {
      return OnboardingConstants.availableColors.first; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sezione Nome
            _buildNameSection(isDark),
            const SizedBox(height: 24),
            
            // Sezione Personalizzazione
            _buildCustomizationSection(isDark),
            const SizedBox(height: 24),
            
            // Sezione Sottocategorie
            _buildSubcategoriesSection(isDark),
            const SizedBox(height: 32),
            
            // Pulsante Salva
            _buildSaveButton(),
            const SizedBox(height: 16), // Spazio extra per il padding
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection(bool isDark) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.label,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informazioni Categoria',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome Categoria',
                hintText: 'Es. Spesa, Entrate, Trasporti...',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 20,
                  ),
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
                  borderSide: BorderSide(color: _selectedColor, width: 2),
                ),
                filled: true,
                fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il nome della categoria';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationSection(bool isDark) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: _selectedColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalizzazione',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Selettore Icona
            _buildIconSelector(isDark),
            const SizedBox(height: 16),
            
            // Selettore Colore
            _buildColorSelector(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icona',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _showIconPicker = !_showIconPicker;
                _showColorPicker = false;
              });
            },
            borderRadius: BorderRadius.circular(12),
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
                      color: _selectedColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_selectedIcon, color: _selectedColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      OnboardingConstants.getIconName(_selectedIcon),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(
                    _showIconPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showIconPicker) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: OnboardingConstants.availableIcons.length,
              itemBuilder: (context, index) {
                final icon = OnboardingConstants.availableIcons[index];
                final isSelected = icon == _selectedIcon;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                        _showIconPicker = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withOpacity(0.2) : (isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50),
                        border: isSelected ? Border.all(color: _selectedColor, width: 2) : Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: _selectedColor, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildColorSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Colore',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _showColorPicker = !_showColorPicker;
                _showIconPicker = false;
              });
            },
            borderRadius: BorderRadius.circular(12),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      OnboardingConstants.getColorName(_selectedColor),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Icon(
                    _showColorPicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showColorPicker) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: OnboardingConstants.availableColors.length,
              itemBuilder: (context, index) {
                final color = OnboardingConstants.availableColors[index];
                final isSelected = color == _selectedColor;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _showColorPicker = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: isSelected ? Border.all(color: isDark ? Colors.white : Colors.white, width: 3) : Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: isSelected 
                          ? Icon(Icons.check, color: isDark ? Colors.white : Colors.white, size: 20)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubcategoriesSection(bool isDark) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sottocategorie',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${_sottocategorie.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Lista sottocategorie esistenti
            if (_sottocategorie.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _sottocategorie.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final sottocategoria = _sottocategorie[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              sottocategoria.nome,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _sottocategorie.removeAt(index);
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Aggiungi sottocategoria
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sottocategoriaController,
                    decoration: InputDecoration(
                      labelText: 'Nuova Sottocategoria',
                      hintText: 'Es. Ristoranti, Supermercati...',
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.orange,
                          size: 16,
                        ),
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
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: isDark ? Theme.of(context).colorScheme.surface : Colors.grey.shade50,
                    ),
                    onSubmitted: (_) => _aggiungiSottocategoria(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _aggiungiSottocategoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _salvaCategoria,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isEditing ? Icons.update : Icons.add,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.isEditing ? 'Aggiorna Categoria' : 'Crea Categoria',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _aggiungiSottocategoria() {
    if (_sottocategoriaController.text.trim().isNotEmpty) {
      setState(() {
        _sottocategorie.add(Sottocategoria(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _sottocategoriaController.text.trim(),
        ));
        _sottocategoriaController.clear();
      });
    }
  }

  void _salvaCategoria() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nomeController.text.trim(),
        _getIconName(_selectedIcon),
        _getColorHex(_selectedColor),
        _sottocategorie,
      );
    }
  }

  /// Converte IconData nel nome compatibile con IconUtils
  String _getIconName(IconData icon) {
    switch (icon) {
      case Icons.home: return 'Home';
      case Icons.shopping_cart: return 'ShoppingCart';
      case Icons.restaurant: return 'Restaurant';
      case Icons.directions_car: return 'CarRental';
      case Icons.local_gas_station: return 'LocalGasStation';
      case Icons.medical_services: return 'LocalHospital';
      case Icons.school: return 'School';
      case Icons.work: return 'Build';
      case Icons.sports_esports: return 'FitnessCenter';
      case Icons.movie: return 'Movie';
      case Icons.music_note: return 'MusicNote';
      case Icons.fitness_center: return 'FitnessCenter';
      case Icons.local_bar: return 'LocalDrink';
      case Icons.local_cafe: return 'Coffee';
      case Icons.flight: return 'Flight';
      case Icons.local_pharmacy: return 'LocalPharmacy';
      case Icons.local_grocery_store: return 'LocalGroceryStore';
      case Icons.account_balance: return 'AccountBalance';
      case Icons.credit_card: return 'CreditCard';
      case Icons.savings: return 'Savings';
      case Icons.attach_money: return 'AccountBalance';
      case Icons.fastfood: return 'Fastfood';
      case Icons.pets: return 'Pets';
      case Icons.directions_bus: return 'DirectionsBus';
      case Icons.electric_bolt: return 'ElectricBolt';
      case Icons.checkroom: return 'Checkroom';
      case Icons.phone: return 'Phone';
      case Icons.favorite: return 'Favorite';
      default: return 'ShoppingCart'; // fallback
    }
  }

  /// Converte Color nel formato hex compatibile con ColorUtils
  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sottocategoriaController.dispose();
    super.dispose();
  }
} 