import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transazione_service.dart';
import '../services/conto_service.dart';
import '../services/categoria_service.dart';
import '../models/transazione.dart';
import '../models/conto.dart';
import '../models/categoria.dart';
import '../models/sottocategoria.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';
import 'transactions_page.dart';
import 'edit_transaction_page.dart';

class TransactionsListPage extends StatefulWidget {
  const TransactionsListPage({super.key});

  @override
  State<TransactionsListPage> createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  String? _selectedTypeFilter; // null = tutti, 'entrata', 'uscita', 'trasferimento'

  @override
  void initState() {
    super.initState();
    _caricaDati();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _caricaDati() async {
    final transazioneService = Provider.of<TransazioneService>(context, listen: false);
    final contoService = Provider.of<ContoService>(context, listen: false);
    final categoriaService = Provider.of<CategoriaService>(context, listen: false);
    
    await transazioneService.caricaTransazioni();
    await contoService.caricaConti();
    await categoriaService.caricaCategorie();
  }

  List<Transazione> _filteredTransactions(List<Transazione> transazioni, ContoService contoService, CategoriaService categoriaService) {
    var filtered = transazioni;

    // Applica filtro per tipo se selezionato
    if (_selectedTypeFilter != null) {
      filtered = filtered.where((transazione) => transazione.tipo == _selectedTypeFilter).toList();
    }

    // Applica filtro per ricerca se presente
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transazione) {
        // Cerca nel titolo della transazione
        final matchesTitle = transazione.titolo.toLowerCase().contains(_searchQuery);
        
        // Cerca nel nome del conto
        final conto = contoService.conti.firstWhere(
          (c) => c.id == transazione.contoId,
          orElse: () => Conto(id: '', nome: '', tipo: '', saldo: 0.0, profileId: ''),
        );
        final matchesConto = conto.nome.toLowerCase().contains(_searchQuery);

        // Cerca nella categoria e sottocategoria
        bool matchesCategory = false;
        if (transazione.tipo != 'trasferimento' && transazione.categoriaId != null) {
          final categoria = categoriaService.categorie.firstWhere(
            (c) => c.id == transazione.categoriaId,
            orElse: () => Categoria(id: '', nome: '', icona: '', coloreIcona: '', profileId: '', sottocategorie: []),
          );
          
          // Cerca nel nome della categoria
          final matchesCategoryName = categoria.nome.toLowerCase().contains(_searchQuery);
          
          // Cerca nel nome della sottocategoria
          bool matchesSubcategory = false;
          if (transazione.sottocategoriaId != null) {
            final sottocategoria = categoria.sottocategorie.firstWhere(
              (s) => s.id == transazione.sottocategoriaId,
              orElse: () => Sottocategoria(id: '', nome: ''),
            );
            matchesSubcategory = sottocategoria.nome.toLowerCase().contains(_searchQuery);
          }
          
          matchesCategory = matchesCategoryName || matchesSubcategory;
        } else if (transazione.tipo == 'trasferimento') {
          // Per i trasferimenti, cerca anche nel conto di destinazione
          if (transazione.contoDestinazioneId != null) {
            final contoDestinazione = contoService.conti.firstWhere(
              (c) => c.id == transazione.contoDestinazioneId,
              orElse: () => Conto(id: '', nome: '', tipo: '', saldo: 0.0, profileId: ''),
            );
            matchesCategory = contoDestinazione.nome.toLowerCase().contains(_searchQuery) || 
                             'trasferimento'.contains(_searchQuery);
          } else {
            matchesCategory = 'trasferimento'.contains(_searchQuery);
          }
        }

        return matchesTitle || matchesConto || matchesCategory;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? _buildSearchField()
            : const Text('Tutte le Transazioni'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          if (!_isSearching)
            IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsPage(),
                  ),
                );
                // Ricarica i dati dopo l'aggiunta
                _caricaDati();
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Consumer3<TransazioneService, ContoService, CategoriaService>(
        builder: (context, transazioneService, contoService, categoriaService, _) {
          final transazioni = transazioneService.transazioni;
          final filteredTransazioni = _filteredTransactions(transazioni, contoService, categoriaService);

          if (transazioni.isEmpty) {
            return _buildEmptyState();
          }

          if (filteredTransazioni.isEmpty && (_searchQuery.isNotEmpty || _selectedTypeFilter != null)) {
            return _buildNoResultsState();
          }

          return RefreshIndicator(
            onRefresh: _caricaDati,
            child: Column(
              children: [
                // Filtri per tipo di transazione
                _buildTypeFilters(transazioni),
                
                // Header risultati ricerca o filtri
                if ((_searchQuery.isNotEmpty || _selectedTypeFilter != null) && filteredTransazioni.isNotEmpty)
                  _buildSearchResultsHeader(filteredTransazioni.length, transazioni.length),
                
                // Lista transazioni
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransazioni.length,
                    itemBuilder: (context, index) {
                      final transazione = filteredTransazioni[index];
                      return _buildTransazioneCard(transazione, contoService, categoriaService);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeFilters(List<Transazione> transazioni) {
    // Conta le transazioni per tipo
    final entrate = transazioni.where((t) => t.tipo == 'entrata').length;
    final uscite = transazioni.where((t) => t.tipo == 'uscita').length;
    final trasferimenti = transazioni.where((t) => t.tipo == 'trasferimento').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtra per tipo',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tutte',
                  count: transazioni.length,
                  isSelected: _selectedTypeFilter == null,
                  onSelected: () {
                    setState(() {
                      _selectedTypeFilter = null;
                    });
                  },
                  color: Colors.blue,
                  icon: Icons.list_alt,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Entrate',
                  count: entrate,
                  isSelected: _selectedTypeFilter == 'entrata',
                  onSelected: entrate > 0 ? () {
                    setState(() {
                      _selectedTypeFilter = _selectedTypeFilter == 'entrata' ? null : 'entrata';
                    });
                  } : null,
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Uscite',
                  count: uscite,
                  isSelected: _selectedTypeFilter == 'uscita',
                  onSelected: uscite > 0 ? () {
                    setState(() {
                      _selectedTypeFilter = _selectedTypeFilter == 'uscita' ? null : 'uscita';
                    });
                  } : null,
                  color: Colors.red,
                  icon: Icons.trending_down,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Trasferimenti',
                  count: trasferimenti,
                  isSelected: _selectedTypeFilter == 'trasferimento',
                  onSelected: trasferimenti > 0 ? () {
                    setState(() {
                      _selectedTypeFilter = _selectedTypeFilter == 'trasferimento' ? null : 'trasferimento';
                    });
                  } : null,
                  color: Colors.orange,
                  icon: Icons.swap_horiz,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback? onSelected,
    required Color color,
    required IconData icon,
  }) {
    final isEnabled = onSelected != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? color 
                : isEnabled 
                    ? color.withOpacity(0.1) 
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? color 
                  : isEnabled 
                      ? color.withOpacity(0.3) 
                      : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : isEnabled 
                        ? color 
                        : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : isEnabled 
                          ? color 
                          : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2) 
                      : isEnabled 
                          ? color.withOpacity(0.2) 
                          : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : isEnabled 
                            ? color 
                            : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Cerca per nome, categoria, conto...',
        hintStyle: TextStyle(color: Colors.grey[600]),
        border: InputBorder.none,
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildSearchResultsHeader(int filteredCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              children: [
                Text(
                  '$filteredCount di $totalCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  Text(
                    'per "$_searchQuery"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
                if (_selectedTypeFilter != null) ...[
                  Text(
                    '• ${_getTypeFilterLabel(_selectedTypeFilter!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedTypeFilter != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedTypeFilter = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTypeFilterLabel(String type) {
    switch (type) {
      case 'entrata':
        return 'Solo Entrate';
      case 'uscita':
        return 'Solo Uscite';
      case 'trasferimento':
        return 'Solo Trasferimenti';
      default:
        return 'Filtro Tipo';
    }
  }

  Widget _buildNoResultsState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surfaceVariant : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessun risultato trovato',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                children: [
                  if (_searchQuery.isNotEmpty && _selectedTypeFilter != null) ...[
                    const TextSpan(text: 'Nessuna transazione trovata per '),
                    TextSpan(
                      text: '"$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' nelle '),
                    TextSpan(
                      text: _getTypeFilterLabel(_selectedTypeFilter!).toLowerCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.\n\nProva con parole chiave diverse o rimuovi i filtri.'),
                  ] else if (_searchQuery.isNotEmpty) ...[
                    const TextSpan(text: 'Nessuna transazione trovata per '),
                    TextSpan(
                      text: '"$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: '.\n\nProva con parole chiave diverse o controlla l\'ortografia.'),
                  ] else if (_selectedTypeFilter != null) ...[
                    const TextSpan(text: 'Nessuna transazione di tipo '),
                    TextSpan(
                      text: _getTypeFilterLabel(_selectedTypeFilter!).toLowerCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' trovata.\n\nProva a rimuovere il filtro per vedere tutte le transazioni.'),
                  ] else ...[
                    const TextSpan(text: 'Nessuna transazione trovata con i filtri applicati.\n\nProva a modificare i criteri di ricerca.'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedTypeFilter = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Rimuovi Filtri'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
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
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna transazione',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aggiungi la tua prima transazione per iniziare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsPage(),
                ),
              );
              _caricaDati();
            },
            icon: const Icon(Icons.add),
            label: const Text('Aggiungi Prima Transazione'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransazioneCard(
    Transazione transazione,
    ContoService contoService,
    CategoriaService categoriaService,
  ) {
    final conto = contoService.conti.firstWhere(
      (c) => c.id == transazione.contoId,
      orElse: () => Conto(id: '', nome: 'Conto non trovato', tipo: '', saldo: 0.0, profileId: ''),
    );

    final categoria = transazione.tipo == 'trasferimento' 
        ? Categoria(
            id: '',
            nome: 'Trasf.',
            icona: '0xe5d4',
            coloreIcona: '0xFF2196F3',
            profileId: '',
            sottocategorie: [],
          )
        : categoriaService.categorie.firstWhere(
            (c) => c.id == transazione.categoriaId,
            orElse: () => Categoria(
              id: '',
              nome: 'Categoria non trovata',
              icona: '0xe0b0',
              coloreIcona: '0xFF000000',
              profileId: '',
              sottocategorie: [],
            ),
          );

    final sottocategoria = categoria.sottocategorie.firstWhere(
      (s) => s.id == transazione.sottocategoriaId,
      orElse: () => Sottocategoria(id: '', nome: ''),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(transazione.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'Elimina',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) => _confermaEliminazione(context, transazione),
        onDismissed: (direction) => _eliminaTransazione(transazione),
        child: ListTile(
          leading: CircleAvatar(
                                backgroundColor: ColorUtils.hexToColor(categoria.coloreIcona),
            child: Icon(
              IconUtils.getIconData(categoria.icona),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            transazione.titolo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transazione.tipo == 'trasferimento' 
                    ? '${conto.nome} → ${_getContoDestinazione(transazione, contoService)?.nome ?? 'Conto non trovato'}'
                    : conto.nome,
              ),
              if (sottocategoria.nome.isNotEmpty && transazione.tipo != 'trasferimento')
                Text(
                  '${categoria.nome} > ${sottocategoria.nome}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              if (transazione.isRicorrente) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.repeat, size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        transazione.frequenzaTesto,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€ ${transazione.importo.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transazione.tipo == 'entrata' ? Colors.green : 
                             transazione.tipo == 'trasferimento' ? Colors.blue : Colors.red,
                    ),
                  ),
                  Text(
                    '${transazione.data.day.toString().padLeft(2, '0')}/${transazione.data.month.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) {
                  if (value == 'edit') {
                    _modificaTransazione(transazione);
                  } else if (value == 'delete') {
                    _mostraDialogEliminazione(context, transazione);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Modifica'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Elimina', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => _modificaTransazione(transazione),
        ),
      ),
    );
  }

  void _modificaTransazione(Transazione transazione) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transazione: transazione),
      ),
    );
  }

  Future<bool?> _confermaEliminazione(BuildContext context, Transazione transazione) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma eliminazione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sei sicuro di voler eliminare la transazione "${transazione.titolo}"?'),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Attenzione: I saldi dei conti verranno aggiornati automaticamente.',
                style: TextStyle(
                  color: Colors.orange,
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
    );
  }

  void _mostraDialogEliminazione(BuildContext context, Transazione transazione) async {
    final conferma = await _confermaEliminazione(context, transazione);
    if (conferma == true) {
      _eliminaTransazione(transazione);
    }
  }

  Future<void> _eliminaTransazione(Transazione transazione) async {
    final transazioneService = Provider.of<TransazioneService>(context, listen: false);
    
    final successo = await transazioneService.eliminaTransazione(transazione.id);
    
    if (successo && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transazione eliminata con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${transazioneService.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Conto? _getContoDestinazione(Transazione transazione, ContoService contoService) {
    if (transazione.contoDestinazioneId == null) return null;
    return contoService.conti.firstWhere(
      (c) => c.id == transazione.contoDestinazioneId,
      orElse: () => Conto(id: '', nome: 'Conto non trovato', tipo: '', saldo: 0.0, profileId: ''),
    );
  }
} 