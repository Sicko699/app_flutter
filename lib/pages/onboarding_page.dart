import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profilo_service.dart';
import '../services/conto_service.dart';
import '../services/categoria_service.dart';
import '../utils/notch_safe_area.dart';
import 'onboarding_profile_page.dart';
import 'onboarding_accounts_page.dart';
import 'onboarding_categories_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<Widget> _pages = [
    const OnboardingProfilePage(),
    const OnboardingAccountsPage(),
    const OnboardingCategoriesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: NotchSafeArea(
        padding: EdgeInsets.only(
          top: 8,
        ),
        child: Column(
          children: [
            // Indicatore di progresso
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                  // Titolo dell'onboarding
                  Text(
                    'Setup Iniziale',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Barra di progresso
                  Row(
                    children: [
                      for (int i = 0; i < _pages.length; i++) ...[
                        Expanded(
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i <= _currentPage 
                                  ? theme.colorScheme.primary 
                                  : theme.colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Indicatori numerici
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profilo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _currentPage >= 0 ? FontWeight.bold : FontWeight.normal,
                          color: _currentPage >= 0 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'Conti',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _currentPage >= 1 ? FontWeight.bold : FontWeight.normal,
                          color: _currentPage >= 1 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'Categorie',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _currentPage >= 2 ? FontWeight.bold : FontWeight.normal,
                          color: _currentPage >= 2 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Contenuto delle pagine
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),
          
          // Pulsanti di navigazione
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pulsante Indietro
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Indietro',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 0) const SizedBox(width: 16),
                
                // Pulsante Avanti/Completa
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
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
                            _currentPage == _pages.length - 1 ? 'Completa' : 'Avanti',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      // Verifica che i dati della pagina corrente siano validi
      bool canProceed = await _validateCurrentPage();
      if (canProceed) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // Completa l'onboarding
      await _completeOnboarding();
    }
  }

  Future<bool> _validateCurrentPage() async {
    switch (_currentPage) {
      case 0:
        // Validazione profilo - verifica e salva i dati del profilo
        return await _validateAndSaveProfile();
      case 1:
        // Validazione conti
        final contoService = Provider.of<ContoService>(context, listen: false);
        if (contoService.conti.isEmpty) {
          _showValidationError('Aggiungi almeno un conto per continuare');
          return false;
        }
        return true;
      case 2:
        // Validazione categorie
        final categoriaService = Provider.of<CategoriaService>(context, listen: false);
        if (categoriaService.categorie.isEmpty) {
          _showValidationError('Crea almeno una categoria per continuare');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<bool> _validateAndSaveProfile() async {
    final profiloService = Provider.of<ProfiloService>(context, listen: false);
    
    // Se il profilo non esiste, mostra un errore
    if (profiloService.profiloCorrente == null) {
      _showValidationError('Salva il tuo profilo prima di continuare');
      return false;
    }
    
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Completa l'onboarding
      final profiloService = Provider.of<ProfiloService>(context, listen: false);
      bool successo = await profiloService.completaOnboarding();

      if (successo && context.mounted) {
        // Mostra messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Setup completato! Benvenuto in Track That!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Naviga alla home page
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: ${profiloService.error}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il completamento: $e')),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
} 