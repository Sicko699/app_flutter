import 'package:flutter/foundation.dart';
import 'base_service.dart';
import 'auth_service.dart';
import 'profilo_service.dart';
import 'conto_service.dart';
import 'categoria_service.dart';
import 'transazione_service.dart';
import 'obiettivo_risparmio_service.dart';

/// Service responsabile del coordinamento e caricamento di tutti i dati dell'app
/// Gestisce le dipendenze tra i vari service
class AppDataService extends BaseService {
  final AuthService _authService;
  final ProfiloService _profiloService;
  final ContoService _contoService;
  final CategoriaService _categoriaService;
  final TransazioneService _transazioneService;
  final ObiettivoRisparmioService _obiettivoRisparmioService;

  AppDataService({
    required AuthService authService,
    required ProfiloService profiloService,
    required ContoService contoService,
    required CategoriaService categoriaService,
    required TransazioneService transazioneService,
    required ObiettivoRisparmioService obiettivoRisparmioService,
  })  : _authService = authService,
        _profiloService = profiloService,
        _contoService = contoService,
        _categoriaService = categoriaService,
        _transazioneService = transazioneService,
        _obiettivoRisparmioService = obiettivoRisparmioService {
    _init();
  }

  void _init() {
    // Ascolta i cambiamenti dello stato di autenticazione
    _authService.addListener(_handleAuthChange);
    
    // Se l'utente è già autenticato, carica i dati
    if (_authService.isAuthenticated) {
      _loadUserData();
    }
    
    setInitialized();
  }

  /// Gestisce i cambiamenti dello stato di autenticazione
  void _handleAuthChange() {
    if (_authService.isAuthenticated) {
      _loadUserData();
    } else {
      _clearAllData();
    }
  }

  /// Carica tutti i dati dell'utente autenticato
  Future<void> _loadUserData() async {
    if (!_authService.isAuthenticated) return;

    await executeOperation<void>(
      () async {
        // Carica i dati in ordine di dipendenza
        await _profiloService.refresh();
        await _categoriaService.refresh();
        await _contoService.refresh();
        await _transazioneService.refresh();
        await _obiettivoRisparmioService.refresh();
      },
      errorMessage: 'Errore durante il caricamento dei dati utente',
    );
  }

  /// Pulisce tutti i dati dei service
  void _clearAllData() {
    _profiloService.clear();
    _contoService.clear();
    _categoriaService.clear();
    _transazioneService.clear();
    _obiettivoRisparmioService.clear();
  }

  /// Ricarica tutti i dati dell'utente
  @override
  Future<void> refresh() async {
    if (_authService.isAuthenticated) {
      await _loadUserData();
    }
  }

  /// Indica se tutti i dati principali sono stati caricati
  bool get isDataLoaded {
    return _authService.isAuthenticated &&
           _profiloService.isInitialized &&
           _categoriaService.isInitialized &&
           _contoService.isInitialized &&
           _transazioneService.isInitialized &&
           _obiettivoRisparmioService.isInitialized;
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    super.dispose();
  }

  @override
  void clear() {
    _clearAllData();
    super.clear();
  }
}