import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/categoria_service.dart';
import '../widgets/categoria_form_widget.dart';
import '../models/categoria.dart';
import '../models/sottocategoria.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';

class CategoriesManagementPage extends StatefulWidget {
  const CategoriesManagementPage({super.key});

  @override
  State<CategoriesManagementPage> createState() => _CategoriesManagementPageState();
}

class _CategoriesManagementPageState extends State<CategoriesManagementPage> {
  bool _showForm = false;
  Categoria? _categoriaInModifica;

  @override
  void initState() {
    super.initState();
    _caricaCategorie();
  }

  Future<void> _caricaCategorie() async {
    final categoriaService = Provider.of<CategoriaService>(context, listen: false);
    await categoriaService.caricaCategorie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Categorie'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (!_showForm)
            IconButton(
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _categoriaInModifica = null;
                });
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Consumer<CategoriaService>(
        builder: (context, categoriaService, child) {
          final categorie = categoriaService.categorie;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showForm 
                ? _buildFormView(categoriaService)
                : _buildListView(categorie, categoriaService),
          );
        },
      ),
    );
  }

  Widget _buildFormView(CategoriaService categoriaService) {
    return Container(
      key: const ValueKey('form'),
      child: Column(
        children: [
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: CategoriaFormWidget(
                onSave: _salvaCategoria,
                initialNome: _categoriaInModifica?.nome,
                initialIcona: _categoriaInModifica?.icona,
                initialColore: _categoriaInModifica?.coloreIcona,
                initialSottocategorie: _categoriaInModifica?.sottocategorie,
                isEditing: _categoriaInModifica != null,
              ),
            ),
          ),
          // Footer con pulsanti
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showForm = false;
                        _categoriaInModifica = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Annulla'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<dynamic> categorie, CategoriaService categoriaService) {
    return Container(
      key: const ValueKey('list'),
      child: categorie.isEmpty
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Le tue categorie',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${categorie.length} categorie create',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final categoria = categorie[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildModernCategoriaCard(categoria, categoriaService),
                        );
                      },
                      childCount: categorie.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna categoria creata',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crea categorie per organizzare meglio le tue transazioni.\nPotrai assegnare colori e sottocategorie per una gestione più dettagliata.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showForm = true;
                  _categoriaInModifica = null;
                });
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Crea Prima Categoria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCategoriaCard(dynamic categoria, CategoriaService categoriaService) {
    final color = ColorUtils.hexToColor(categoria.coloreIcona);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _modificaCategoria(categoria),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icona categoria con gradiente
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        IconUtils.getIconFromName(categoria.icona),
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
                            categoria.nome,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${categoria.sottocategorie.length} sottocategorie',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu actions
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _modificaCategoria(categoria);
                            break;
                          case 'delete':
                            _eliminaCategoria(categoria, categoriaService);
                            break;
                        }
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              const Text('Modifica'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              const Text('Elimina', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (categoria.sottocategorie.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sottocategorie',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...categoria.sottocategorie.take(4).map<Widget>((sottocategoria) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sottocategoria.nome,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            if (categoria.sottocategorie.length > 4)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${categoria.sottocategorie.length - 4}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.outline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _modificaCategoria(Categoria categoria) {
    setState(() {
      _showForm = true;
      _categoriaInModifica = categoria;
    });
  }

  Future<void> _eliminaCategoria(dynamic categoria, CategoriaService categoriaService) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Elimina Categoria',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Sei sicuro di voler eliminare la categoria '),
                          TextSpan(
                            text: '"${categoria.nome}"',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: '?\n\nQuesta azione non può essere annullata.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
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
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
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
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Elimina',
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
    );

    if (conferma == true) {
      final successo = await categoriaService.eliminaCategoria(categoria.id);
      if (successo && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria "${categoria.nome}" eliminata'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${categoriaService.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _salvaCategoria(String nome, String icona, String colore, List<Sottocategoria> sottocategorie) async {
    final categoriaService = Provider.of<CategoriaService>(context, listen: false);
    bool successo;
    bool isEditing = _categoriaInModifica != null;
    
    if (isEditing) {
    }

    if (isEditing) {
      // Modifica categoria esistente
      successo = await categoriaService.aggiornaCategoria(
        categoriaId: _categoriaInModifica!.id,
        nome: nome,
        icona: icona,
        coloreIcona: colore,
        sottocategorie: sottocategorie,
      );
    } else {
      // Crea nuova categoria
      successo = await categoriaService.creaCategoria(
        nome: nome,
        icona: icona,
        coloreIcona: colore,
        sottocategorie: sottocategorie,
      );
    }

    if (successo && mounted) {
      setState(() {
        _showForm = false;
        _categoriaInModifica = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing 
                ? 'Categoria aggiornata con successo!'
                : 'Categoria creata con successo!'
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      print('❌ Errore nel salvataggio: ${categoriaService.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore: ${categoriaService.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 