import 'dart:async';
import 'package:flutter/foundation.dart';

/// Sistema di eventi per la comunicazione tra service
/// Evita dipendenze circolari utilizzando un pattern event-driven
class AppEvents {
  static final AppEvents _instance = AppEvents._internal();
  factory AppEvents() => _instance;
  AppEvents._internal();

  final Map<Type, StreamController<dynamic>> _controllers = {};
  final Map<Type, List<StreamSubscription<dynamic>>> _subscriptions = {};

  /// Emette un evento di un tipo specifico
  void emit<T>(T event) {
    final controller = _controllers[T];
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  /// Ascolta eventi di un tipo specifico
  StreamSubscription<T> listen<T>(void Function(T event) onEvent) {
    _controllers[T] ??= StreamController<T>.broadcast();
    
    final subscription = (_controllers[T] as StreamController<T>)
        .stream
        .listen(onEvent);
    
    _subscriptions[T] ??= [];
    _subscriptions[T]!.add(subscription);
    
    return subscription;
  }

  /// Pulisce tutti gli eventi e subscription
  void dispose() {
    for (final subscriptions in _subscriptions.values) {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    }
    _subscriptions.clear();

    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Eventi dell'app
class TransazioneCreatedEvent {
  final String transazioneId;
  final String contoId;
  final double importo;
  final String tipo;

  TransazioneCreatedEvent({
    required this.transazioneId,
    required this.contoId,
    required this.importo,
    required this.tipo,
  });
}

class TransazioneUpdatedEvent {
  final String transazioneId;
  final String? oldContoId;
  final String? newContoId;
  final double? oldImporto;
  final double? newImporto;
  final String? oldTipo;
  final String? newTipo;

  TransazioneUpdatedEvent({
    required this.transazioneId,
    this.oldContoId,
    this.newContoId,
    this.oldImporto,
    this.newImporto,
    this.oldTipo,
    this.newTipo,
  });
}

class TransazioneDeletedEvent {
  final String transazioneId;
  final String contoId;
  final double importo;
  final String tipo;

  TransazioneDeletedEvent({
    required this.transazioneId,
    required this.contoId,
    required this.importo,
    required this.tipo,
  });
}

class ContoDeletedEvent {
  final String contoId;

  ContoDeletedEvent({required this.contoId});
}