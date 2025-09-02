import 'package:flutter/foundation.dart';

/// Utility per migliorare l'uso di Provider nel progetto
class ProviderUtils {
  /// Helper per evitare rebuild inutili quando si usano liste
  static bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    
    return true;
  }

  /// Helper per confrontare oggetti in modo ottimizzato
  static bool shouldRebuild<T>(T oldValue, T newValue) {
    if (oldValue == newValue) return false;
    
    // Per liste, usa il confronto ottimizzato
    if (oldValue is List && newValue is List) {
      return !listEquals(oldValue, newValue);
    }
    
    return true;
  }
}

/// Mixin per service che implementano pattern ottimizzati
mixin OptimizedNotifier on ChangeNotifier {
  bool _disposed = false;
  
  /// Override per evitare notifiche dopo dispose
  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }
  
  /// Override dispose per marcare come disposed
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
  /// Helper per notificare solo se necessario
  void notifyIfNeeded<T>(T oldValue, T newValue) {
    if (ProviderUtils.shouldRebuild(oldValue, newValue)) {
      notifyListeners();
    }
  }
}

/// Configurazione per Provider ottimizzata
class ProviderConfig {
  /// Lazy loading per migliorare le performance iniziali
  static const bool enableLazyLoading = true;
  
  /// Debug mode per logging
  static const bool debugMode = kDebugMode;
  
  /// Timeout per operazioni async
  static const Duration defaultTimeout = Duration(seconds: 30);
}