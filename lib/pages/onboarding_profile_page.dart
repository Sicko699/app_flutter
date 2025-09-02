import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profilo_service.dart';
import '../utils/notch_safe_area.dart';

class OnboardingProfilePage extends StatefulWidget {
  const OnboardingProfilePage({super.key});

  @override
  State<OnboardingProfilePage> createState() => _OnboardingProfilePageState();
}

class _OnboardingProfilePageState extends State<OnboardingProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _dataDiNascitaController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _caricaProfiloEsistente();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _dataDiNascitaController.dispose();
    super.dispose();
  }

  Future<void> _caricaProfiloEsistente() async {
    final profiloService = Provider.of<ProfiloService>(context, listen: false);
    await profiloService.caricaProfiloUtente();
    
    final profilo = profiloService.profiloCorrente;
    if (profilo != null) {
      setState(() {
        _nomeController.text = profilo.nome;
        _cognomeController.text = profilo.cognome;
        _dataDiNascitaController.text = profilo.dataDiNascita;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  Text(
                    'Completa il tuo profilo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sottotitolo
                  Text(
                    'Inserisci le tue informazioni personali per personalizzare la tua esperienza',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Contenuto del form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo Nome
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci il tuo nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Cognome
                      TextFormField(
                        controller: _cognomeController,
                        decoration: InputDecoration(
                          labelText: 'Cognome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci il tuo cognome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo Data di Nascita
                      TextFormField(
                        controller: _dataDiNascitaController,
                        decoration: InputDecoration(
                          labelText: 'Data di Nascita',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 anni fa
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
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
                            _dataDiNascitaController.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Inserisci la tua data di nascita';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Pulsante Salva Profilo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _salvaProfilo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Consumer<ProfiloService>(
                            builder: (context, profiloService, _) {
                              if (profiloService.isLoading) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              }
                              return const Text(
                                'Salva Profilo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvaProfilo() async {
    if (_formKey.currentState!.validate()) {
      final profiloService = Provider.of<ProfiloService>(context, listen: false);
      
      final successo = await profiloService.creaProfiloUtente(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        dataDiNascita: _dataDiNascitaController.text.trim(),
      );

      if (successo && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilo salvato con successo!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio: ${profiloService.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
} 