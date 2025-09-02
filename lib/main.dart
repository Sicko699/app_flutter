import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/profilo_service.dart';
import 'services/conto_service.dart';
import 'services/categoria_service.dart';
import 'services/transazione_service.dart';
import 'services/obiettivo_risparmio_service.dart';
import 'services/app_data_service.dart';
import 'services/theme_service.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/register_page.dart';
import 'pages/main_navigation_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferences.getInstance(); // Inizializza SharedPreferences
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProfiloService()),
        ChangeNotifierProvider(create: (_) => ContoService()),
        ChangeNotifierProvider(create: (_) => CategoriaService()),
        ChangeNotifierProvider(create: (_) => TransazioneService()),
        ChangeNotifierProvider(create: (_) => ObiettivoRisparmioService()),
        ChangeNotifierProvider(create: (_) => AppDataService(
          authService: Provider.of<AuthService>(context, listen: false),
          profiloService: Provider.of<ProfiloService>(context, listen: false),
          contoService: Provider.of<ContoService>(context, listen: false),
          categoriaService: Provider.of<CategoriaService>(context, listen: false),
          transazioneService: Provider.of<TransazioneService>(context, listen: false),
          obiettivoRisparmioService: Provider.of<ObiettivoRisparmioService>(context, listen: false),
        )),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<TransazioneService>(
        builder: (context, transazioneService, child) {
          // Collega il ContoService al TransazioneService
          final contoService = Provider.of<ContoService>(context, listen: false);
          transazioneService.setContoService(contoService);
          
          return Consumer2<AuthService, ThemeService>(
            builder: (context, auth, themeService, _) {
              
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Track That',
                theme: ThemeService.lightTheme,
                darkTheme: ThemeService.darkTheme,
                themeMode: themeService.themeMode,
                home: _buildHomePage(context, auth),
                routes: {
                  '/register': (context) => const RegisterPage(),
                  '/onboarding': (context) => const OnboardingPage(),
                  '/home': (context) => const MainNavigationPage(),
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, AuthService auth) {
    if (auth.user != null) {
      // Utente autenticato - usa Selector per ottimizzare i rebuild
      return Selector<ProfiloService, bool?>(
        selector: (context, profiloService) => 
            profiloService.profiloCorrente?.primoAccesso,
        builder: (context, primoAccesso, _) {
          if (primoAccesso == null) {
            // Profilo non ancora caricato, mostra un loading
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (primoAccesso == true) {
            return const OnboardingPage();
          } else {
            return const MainNavigationPage();
          }
        },
      );
    } else {
      return const LoginPage();
    }
  }
}
