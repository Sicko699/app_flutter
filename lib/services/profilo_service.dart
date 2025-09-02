import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profilo.dart';
import 'base_service.dart';

class ProfiloService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  ProfiloUtente? _profiloCorrente;
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Profilo dell'utente attualmente autenticato
  ProfiloUtente? get profiloCorrente => _profiloCorrente;

  ProfiloService() {
    // Ascolta i cambiamenti dello stato di autenticazione
    _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  /// Gestisce i cambiamenti dello stato di autenticazione
  void _handleAuthStateChange(User? user) {
    
    if (user != null) {
      // Utente autenticato, carica il profilo
      caricaProfiloUtente();
    } else {
      // Utente non autenticato, pulisci il profilo
      _profiloCorrente = null;
      notifyListeners();
    }
  }

  /// Crea un nuovo profilo utente nel database
  Future<bool> creaProfiloUtente({
    required String nome,
    required String cognome,
    required String dataDiNascita,
    String? avatarUri,
  }) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        

        // Crea il profilo utente
        final nuovoProfilo = ProfiloUtente(
          id: user.uid,
          nome: nome,
          cognome: cognome,
          dataDiNascita: dataDiNascita,
          email: user.email ?? '',
          avatarUri: avatarUri,
          primoAccesso: true,
          dataCreazione: DateTime.now(),
          dataUltimoAccesso: DateTime.now(),
        );

        // Salva nel database
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .set(nuovoProfilo.toMap());

        _profiloCorrente = nuovoProfilo;
        setInitialized();
        notifyListeners(); // Notifica i listener del cambio
        return true;
      },
      errorMessage: 'Errore durante la creazione del profilo',
    ) ?? false;
  }

  /// Carica il profilo dell'utente corrente
  Future<void> caricaProfiloUtente() async {
    await refresh();
  }

  @override
  Future<void> refresh() async {
    await executeOperation<void>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        final doc = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _profiloCorrente = ProfiloUtente.fromMap(data);
          
          // Aggiorna la data dell'ultimo accesso
          await _aggiornaUltimoAccesso();
          setInitialized();
          notifyListeners(); // Notifica i listener del cambio
        } else {
          throw Exception('Profilo utente non trovato');
        }
      },
      errorMessage: 'Errore durante il caricamento del profilo',
      showLoading: false,
    );
  }

  /// Aggiorna il profilo utente
  Future<bool> aggiornaProfiloUtente({
    String? nome,
    String? cognome,
    String? dataDiNascita,
    String? avatarUri,
    bool? primoAccesso,
  }) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        if (_profiloCorrente == null) {
          throw Exception('Profilo non caricato');
        }

        // Aggiorna il profilo
        final profiloAggiornato = _profiloCorrente!.copyWith(
          nome: nome,
          cognome: cognome,
          dataDiNascita: dataDiNascita,
          avatarUri: avatarUri,
          primoAccesso: primoAccesso,
        );

        // Salva nel database
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .update(profiloAggiornato.toMap());

        _profiloCorrente = profiloAggiornato;
        notifyListeners(); // Notifica i listener del cambio
        return true;
      },
      errorMessage: 'Errore durante l\'aggiornamento del profilo',
    ) ?? false;
  }

  /// Aggiorna la data dell'ultimo accesso (privato)
  Future<void> _aggiornaUltimoAccesso() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .update({
        'dataUltimoAccesso': DateTime.now().toIso8601String(),
      });

      if (_profiloCorrente != null) {
        _profiloCorrente = _profiloCorrente!.copyWith(
          dataUltimoAccesso: DateTime.now(),
        );
      }
    } catch (e) {
      // Silently ignore last access update errors
    }
  }

  /// Verifica se l'utente ha già un profilo
  Future<bool> verificaProfiloEsistente() async {
    final result = await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        final doc = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .get();

        return doc.exists;
      },
      showLoading: false,
    );
    
    return result ?? false;
  }

  /// Completa l'onboarding e imposta primoAccesso a false
  Future<bool> completaOnboarding() async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        // Se il profilo non è caricato, prova a caricarlo
        if (_profiloCorrente == null) {
          await caricaProfiloUtente();
          
          if (_profiloCorrente == null) {
            throw Exception('Impossibile caricare il profilo utente');
          }
        }

        // Aggiorna il profilo per indicare che l'onboarding è completato
        final profiloAggiornato = _profiloCorrente!.copyWith(
          primoAccesso: false,
        );

        // Salva nel database
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .update({
          'primoAccesso': false,
        });

        // Salva nelle SharedPreferences per persistenza locale
        await _setOnboardingCompleted(user.uid, true);

        _profiloCorrente = profiloAggiornato;
        notifyListeners();
        
        return true;
      },
      errorMessage: 'Errore durante il completamento dell\'onboarding',
    ) ?? false;
  }

  /// Salva lo stato di completamento onboarding nelle SharedPreferences
  Future<void> _setOnboardingCompleted(String userId, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_onboardingCompletedKey}_$userId', completed);
  }

  /// Controlla se l'onboarding è stato completato dalle SharedPreferences
  Future<bool> _isOnboardingCompletedLocally(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_onboardingCompletedKey}_$userId') ?? false;
  }

  /// Verifica se l'utente deve fare l'onboarding considerando sia lo stato locale che remoto
  Future<bool> shouldShowOnboarding() async {
    if (_profiloCorrente == null) return false;
    
    final user = _auth.currentUser;
    if (user == null) return false;

    // Se l'onboarding è stato completato localmente, non mostrarlo
    final isCompletedLocally = await _isOnboardingCompletedLocally(user.uid);
    if (isCompletedLocally) {
      return false;
    }

    // Altrimenti, controlla lo stato nel database
    return _profiloCorrente!.primoAccesso == true;
  }



  /// Elimina il profilo utente
  Future<bool> eliminaProfiloUtente() async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .delete();

        _profiloCorrente = null;
        return true;
      },
      errorMessage: 'Errore durante l\'eliminazione del profilo',
    ) ?? false;
  }

  @override
  void clear() {
    _profiloCorrente = null;
    super.clear();
  }

  /// Pulisce lo stato di onboarding locale per un utente specifico
  Future<void> _clearOnboardingState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_onboardingCompletedKey}_$userId');
  }
}
