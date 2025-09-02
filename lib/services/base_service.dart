import 'package:flutter/foundation.dart';
import '../utils/provider_utils.dart';

/// Classe base per tutti i service dell'app
/// Fornisce funzionalità comuni come gestione errori e stati di caricamento
abstract class BaseService extends ChangeNotifier with OptimizedNotifier {
  String? _error;
  bool _isLoading = false;
  bool _isInitialized = false;

  /// Ultimo errore verificatosi nel service
  String? get error => _error;

  /// Indica se il service sta eseguendo un'operazione
  bool get isLoading => _isLoading;

  /// Indica se il service è stato inizializzato
  bool get isInitialized => _isInitialized;

  /// Imposta lo stato di caricamento
  @protected
  void setLoading(bool loading) {
    final oldValue = _isLoading;
    _isLoading = loading;
    // Usa microtask per evitare notifiche durante il build
    Future.microtask(() => notifyIfNeeded(oldValue, loading));
  }

  /// Imposta un errore e notifica i listener
  @protected
  void setError(String? error) {
    notifyIfNeeded(_error, error);
    _error = error;
  }

  /// Pulisce l'errore corrente
  @protected
  void clearError() {
    if (_error != null) {
      notifyIfNeeded(_error, null);
      _error = null;
    }
  }

  /// Esegue un'operazione gestendo automaticamente loading e errori
  @protected
  Future<T?> executeOperation<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
  }) async {
    if (showLoading) setLoading(true);
    clearError();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      final message = errorMessage ?? 'Errore durante l\'operazione: $e';
      setError(message);
      return null;
    } finally {
      if (showLoading) setLoading(false);
    }
  }

  /// Marca il service come inizializzato
  @protected
  void setInitialized() {
    _isInitialized = true;
  }

  /// Pulisce tutti i dati del service
  @mustCallSuper
  void clear() {
    final hadChanges = _error != null || _isLoading || _isInitialized;
    _error = null;
    _isLoading = false;
    _isInitialized = false;
    
    if (hadChanges) {
      notifyListeners();
    }
  }

  /// Ricarica i dati del service
  Future<void> refresh();
}