import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  /// Utente attualmente autenticato
  User? get user => _user;

  AuthService() {
    // Ascolta i cambiamenti dello stato di autenticazione
    _auth.authStateChanges().listen(_handleAuthStateChange);
    // Imposta l'utente corrente se già autenticato
    _user = _auth.currentUser;
    setInitialized();
  }

  /// Gestisce i cambiamenti dello stato di autenticazione
  void _handleAuthStateChange(User? user) {
    
    _user = user;
    notifyListeners();
  }

  /// Indica se l'utente è autenticato
  bool get isAuthenticated => _user != null;


  /// Registra un nuovo utente
  Future<bool> register(String email, String password) async {
    return await executeOperation<bool>(
      () async {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return true;
      },
      errorMessage: 'Errore durante la registrazione',
    ) ?? false;
  }

  /// Effettua il login dell'utente
  Future<bool> login(String email, String password) async {
    return await executeOperation<bool>(
      () async {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return true;
      },
      errorMessage: 'Errore durante il login',
    ) ?? false;
  }

  /// Effettua il logout dell'utente
  Future<bool> logout() async {
    return await executeOperation<bool>(
      () async {
        await _auth.signOut();
        return true;
      },
      errorMessage: 'Errore durante il logout',
    ) ?? false;
  }

  /// Invia un'email per il reset della password
  Future<bool> resetPassword(String email) async {
    return await executeOperation<bool>(
      () async {
        await _auth.sendPasswordResetEmail(email: email);
        return true;
      },
      errorMessage: 'Errore durante l\'invio dell\'email di reset',
    ) ?? false;
  }

  @override
  Future<void> refresh() async {
    // Per AuthService non c'è bisogno di refresh esplicito
    // Lo stato viene gestito automaticamente da Firebase
  }

  @override
  void clear() {
    _user = null;
    super.clear();
  }
}
