import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/categoria_service.dart';
import '../widgets/categoria_form_widget.dart';

import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';
import '../utils/notch_safe_area.dart';

class OnboardingCategoriesPage extends StatefulWidget {
  const OnboardingCategoriesPage({super.key});

  @override
  State<OnboardingCategoriesPage> createState() => _OnboardingCategoriesPageState();
}

class _OnboardingCategoriesPageState extends State<OnboardingCategoriesPage> {
  bool _showForm = false;

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
    final theme = Theme.of(context);
    
    return Consumer<CategoriaService>(
      builder: (context, categoriaService, _) {
        if (categoriaService.categorie.isEmpty && !_showForm) {
          return _buildEmptyState(theme);
        }
        
        if (_showForm) {
          return _buildFormView(theme);
        }
        
        return _buildCategoriesList(theme, categoriaService);
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
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.category,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'Le tue categorie',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Crea le categorie per organizzare le tue spese e entrate',
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
                      Icons.category_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nessuna categoria ancora creata',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inizia creando la tua prima categoria',
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
                      label: const Text('Crea Prima Categoria'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
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
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'Aggiungi categoria',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Crea una nuova categoria con le sue sottocategorie',
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
              child: CategoriaFormWidget(
                onSave: (nome, icona, colore, sottocategorie) async {
                  final categoriaService = Provider.of<CategoriaService>(context, listen: false);
                  final success = await categoriaService.creaCategoria(
                    nome: nome,
                    icona: icona,
                    coloreIcona: colore,
                    sottocategorie: sottocategorie,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoria creata con successo!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _salvaCategoria();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore: ${categoriaService.error}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme, CategoriaService categoriaService) {
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
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.category,
                      size: 40,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'Le tue categorie',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Gestisci le tue categorie e sottocategorie',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Lista categorie
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: categoriaService.categorie.length,
                      itemBuilder: (context, index) {
                        final categoria = categoriaService.categorie[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: ColorUtils.hexToColor(categoria.coloreIcona),
                              child: Icon(
                                IconUtils.getIconFromName(categoria.icona),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(categoria.nome),
                            subtitle: Text('${categoria.sottocategorie.length} sottocategorie'),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Pulsante per creare altra categoria
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
                        label: const Text('Crea Altra Categoria'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Colors.purple,
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

  Future<void> _salvaCategoria() async {
    setState(() {
      _showForm = false;
    });
    await _caricaCategorie();
  }
} 