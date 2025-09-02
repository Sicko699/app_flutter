import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/profilo_service.dart';
import '../services/categoria_service.dart';
import '../services/theme_service.dart';
import '../utils/string_extensions.dart';
import 'profile_page.dart';
import 'categories_management_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Inizializza il tema al caricamento della pagina
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      themeService.initializeTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: Consumer2<ProfiloService, AuthService>(
        builder: (context, profiloService, authService, _) {
          final profilo = profiloService.profiloCorrente;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sezione Profilo
              _buildSectionHeader('Profilo'),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      profilo?.nome.isNotEmpty == true 
                          ? profilo!.nome[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    profilo?.nome.isNotEmpty == true 
                        ? '${profilo!.nome} ${profilo.cognome}'
                        : 'Nome non impostato',
                  ),
                  subtitle: Text(profilo?.email ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Sezione Aspetto
              _buildSectionHeader('Aspetto'),
              Card(
                child: Column(
                  children: [
                    Consumer<ThemeService>(
                      builder: (context, themeService, child) {
                        return ListTile(
                          leading: const Icon(Icons.palette),
                          title: const Text('Tema'),
                          subtitle: Text(themeService.getCurrentThemeName().capitalize()),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _showThemeDialog,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sezione Gestione Dati
              _buildSectionHeader('Gestione Dati'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Gestione Categorie'),
                      subtitle: const Text('Modifica categorie e sottocategorie'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showCategoriesManagement,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sezione Informazioni
              _buildSectionHeader('Informazioni'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Informazioni App'),
                      subtitle: const Text('Versione e dettagli'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showAppInfo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sezione Account
              _buildSectionHeader('Account'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: const Text('Logout'),
                      subtitle: const Text('Disconnetti dal tuo account'),
                      onTap: _showLogoutDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text(
                        'Elimina Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: const Text('Elimina definitivamente il tuo account'),
                      onTap: _showDeleteAccountDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    final currentTheme = themeService.getCurrentThemeName();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sistema'),
              subtitle: const Text('Segue le impostazioni del dispositivo'),
              value: 'sistema',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                themeService.changeThemeByString(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Chiaro'),
              subtitle: const Text('Tema chiaro sempre attivo'),
              value: 'chiaro',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                themeService.changeThemeByString(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Scuro'),
              subtitle: const Text('Tema scuro sempre attivo'),
              value: 'scuro',
              groupValue: currentTheme,
              onChanged: (value) {
                Navigator.pop(context);
                themeService.changeThemeByString(value!);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }



  void _showCategoriesManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriesManagementPage(),
      ),
    );
  }



  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'Track That',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: const [
        Text('App per la gestione delle finanze personali'),
        SizedBox(height: 8),
        Text('Sviluppata con Flutter e Firebase'),
      ],
    );
  }



  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Logout'),
        content: const Text('Sei sicuro di voler uscire dall\'account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Account'),
        content: const Text(
          'Sei sicuro di voler eliminare definitivamente il tuo account? '
          'Questa azione non può essere annullata e tutti i tuoi dati verranno persi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profiloService = Provider.of<ProfiloService>(context, listen: false);
      
      // Elimina il profilo
      await profiloService.eliminaProfiloUtente();
      
      // Elimina l'account Firebase
      await authService.user?.delete();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account eliminato con successo')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
        );
      }
    }
  }
} 