import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profilo_service.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _dataDiNascitaController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caricaProfilo();
    });
  }

  Future<void> _caricaProfilo() async {
    final profiloService = Provider.of<ProfiloService>(context, listen: false);
    await profiloService.caricaProfiloUtente();
  }

  void _iniziaModifica() {
    final profilo = Provider.of<ProfiloService>(context, listen: false).profiloCorrente;
    if (profilo != null) {
      _nomeController.text = profilo.nome;
      _cognomeController.text = profilo.cognome;
      _dataDiNascitaController.text = profilo.dataDiNascita;
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _annullaModifica() {
    setState(() {
      _isEditing = false;
    });
  }



  Future<void> _salvaModifiche() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profiloService = Provider.of<ProfiloService>(context, listen: false);
      bool successo = await profiloService.aggiornaProfiloUtente(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        dataDiNascita: _dataDiNascitaController.text.trim(),
      );

      if (successo && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profilo aggiornato con successo!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${profiloService.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'aggiornamento: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? Theme.of(context).colorScheme.surface 
          : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Profilo Utente',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<ProfiloService>(
            builder: (context, profiloService, _) {
              if (_isEditing) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: _isLoading ? null : _salvaModifiche,
                      icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_rounded),
                      tooltip: 'Salva',
                    ),
                    IconButton(
                      onPressed: _annullaModifica,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Annulla',
                    ),
                  ],
                );
              } else {
                return IconButton(
                  onPressed: _iniziaModifica,
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: 'Modifica',
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<ProfiloService>(
        builder: (context, profiloService, _) {
          final profilo = profiloService.profiloCorrente;

          if (profilo == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header con avatar e nome
                _buildProfileHeader(profilo, isDark),
                const SizedBox(height: 32),

                // Card con informazioni del profilo
                _buildProfileInfoCard(profilo, isDark),
                const SizedBox(height: 24),

                // Card azioni di sicurezza
                _buildSecurityActionsCard(isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(profilo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Avatar semplice
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              child: profilo.avatarUri != null
                  ? ClipOval(
                      child: Image.network(
                        profilo.avatarUri!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Nome completo
          Text(
            '${profilo.nome} ${profilo.cognome}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Email
          Text(
            profilo.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard(profilo, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Informazioni Personali',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isEditing) ...[
            _buildModernEditField('Nome', _nomeController, Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildModernEditField('Cognome', _cognomeController, Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildModernEditField('Data di Nascita', _dataDiNascitaController, Icons.calendar_today_rounded, isDate: true),
          ] else ...[
            _buildModernInfoField('Nome', profilo.nome, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildModernInfoField('Cognome', profilo.cognome, Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildModernInfoField('Data di Nascita', profilo.dataDiNascita, Icons.calendar_today_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityActionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sicurezza',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Pulsante reset password
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetPasswordDialog,
              icon: const Icon(Icons.lock_reset_outlined),
              label: const Text(
                'Reimposta Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoField(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernEditField(String label, TextEditingController controller, IconData icon, {bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            hintText: 'Inserisci $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onTap: isDate ? () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 6570)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
            }
          } : null,
          readOnly: isDate,
        ),
      ],
    );
  }

  void _showResetPasswordDialog() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profiloService = Provider.of<ProfiloService>(context, listen: false);
    final userEmail = profiloService.profiloCorrente?.email ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reimposta Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_reset_outlined,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Verrà inviata un\'email di reset password al tuo indirizzo email registrato.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (userEmail.isNotEmpty) 
              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handlePasswordResetFromProfile(userEmail);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Invia Email'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePasswordResetFromProfile(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email utente non disponibile'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.resetPassword(email);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email di reset inviata a $email'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${authService.error}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'invio: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _dataDiNascitaController.dispose();
    super.dispose();
  }
} 