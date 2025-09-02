import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/obiettivo_risparmio.dart';
import 'base_service.dart';

class ObiettivoRisparmioService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<ObiettivoRisparmio> _obiettivi = [];

  /// Lista degli obiettivi di risparmio dell'utente
  List<ObiettivoRisparmio> get obiettivi => _obiettivi;

  /// Carica tutti gli obiettivi di risparmio dell'utente
  Future<bool> caricaObiettivi() async {
    
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        
        final snapshot = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('obiettivi_risparmio')
            .get(); // Rimosso orderBy per test


        if (snapshot.docs.isEmpty) {
          _obiettivi = [];
          setInitialized();
          notifyListeners();
          return true;
        }

        // Log del primo documento per debug
        if (snapshot.docs.isNotEmpty) {
          final firstDoc = snapshot.docs.first;
        }

        _obiettivi = snapshot.docs
            .map((doc) {
              try {
                // Usa doc.id invece del campo id dal documento
                final data = {...doc.data(), 'id': doc.id};
                return ObiettivoRisparmio.fromMap(data);
              } catch (parseError) {
                rethrow;
              }
            })
            .toList();

        setInitialized();
        notifyListeners();
        return true;
      },
      errorMessage: 'Errore durante il caricamento degli obiettivi',
    ) ?? false;
  }

  /// Crea un nuovo obiettivo di risparmio
  Future<bool> creaObiettivo({
    required String nome,
    required String icona,
    required String coloreIcona,
    required double importoTarget,
    required String dataScadenza,
  }) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }



        final nuovoObiettivo = ObiettivoRisparmio(
          id: '', // Sarà generato da Firestore
          nome: nome,
          icona: icona,
          coloreIcona: coloreIcona,
          importoTarget: importoTarget,
          importoAttuale: 0.0,
          dataScadenza: dataScadenza,
          profileId: user.uid,
          dataCreazione: DateTime.now(),
          dataModifica: DateTime.now(),
        );

        final docRef = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('obiettivi_risparmio')
            .add(nuovoObiettivo.toMap());

        final obiettivoConId = nuovoObiettivo.copyWith(id: docRef.id);
        _obiettivi.insert(0, obiettivoConId);

        notifyListeners();
        return true;
      },
      errorMessage: 'Errore durante la creazione dell\'obiettivo',
    ) ?? false;
  }

  /// Aggiorna un obiettivo di risparmio esistente
  Future<bool> aggiornaObiettivo({
    required String obiettivoId,
    String? nome,
    String? icona,
    String? coloreIcona,
    double? importoTarget,
    double? importoAttuale,
    String? dataScadenza,
  }) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }


        final updateData = <String, dynamic>{
          'dataModifica': DateTime.now().toIso8601String(),
        };

        if (nome != null) updateData['nome'] = nome;
        if (icona != null) updateData['icona'] = icona;
        if (coloreIcona != null) updateData['coloreIcona'] = coloreIcona;
        if (importoTarget != null) updateData['importoTarget'] = importoTarget;
        if (importoAttuale != null) updateData['importoAttuale'] = importoAttuale;
        if (dataScadenza != null) updateData['dataScadenza'] = dataScadenza;

        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('obiettivi_risparmio')
            .doc(obiettivoId)
            .update(updateData);

        // Aggiorna la lista locale
        final index = _obiettivi.indexWhere((o) => o.id == obiettivoId);
        if (index != -1) {
          _obiettivi[index] = _obiettivi[index].copyWith(
            nome: nome,
            icona: icona,
            coloreIcona: coloreIcona,
            importoTarget: importoTarget,
            importoAttuale: importoAttuale,
            dataScadenza: dataScadenza,
          );
        }

        notifyListeners();
        return true;
      },
      errorMessage: 'Errore durante l\'aggiornamento dell\'obiettivo',
    ) ?? false;
  }

  /// Aggiunge un importo all'obiettivo di risparmio
  Future<bool> aggiungiImporto({
    required String obiettivoId,
    required double importo,
    String? contoId,
  }) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        final obiettivo = _obiettivi.firstWhere((o) => o.id == obiettivoId);
        final nuovoImporto = obiettivo.importoAttuale + importo;


        // Aggiorna l'obiettivo
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('obiettivi_risparmio')
            .doc(obiettivoId)
            .update({
          'importoAttuale': nuovoImporto,
          'dataModifica': DateTime.now().toIso8601String(),
        });

        // Se è specificato un conto, aggiorna anche il saldo del conto
        if (contoId != null) {
          // Nota: L'aggiornamento del saldo del conto dovrebbe essere gestito dal ContoService
          // o tramite una transazione per mantenere la consistenza dei dati
        }

        // Aggiorna la lista locale
        final index = _obiettivi.indexWhere((o) => o.id == obiettivoId);
        if (index != -1) {
          _obiettivi[index] = _obiettivi[index].copyWith(
            importoAttuale: nuovoImporto,
          );
        }

        notifyListeners();
        return true;
      },
      errorMessage: 'Errore durante l\'aggiunta dell\'importo',
    ) ?? false;
  }

  /// Elimina un obiettivo di risparmio
  Future<bool> eliminaObiettivo(String obiettivoId) async {
    return await executeOperation<bool>(
      () async {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }


        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('obiettivi_risparmio')
            .doc(obiettivoId)
            .delete();

        _obiettivi.removeWhere((o) => o.id == obiettivoId);

        notifyListeners();
        return true;
      },
      errorMessage: 'Errore durante l\'eliminazione dell\'obiettivo',
    ) ?? false;
  }

  /// Ottiene un obiettivo specifico
  ObiettivoRisparmio? getObiettivoById(String obiettivoId) {
    try {
      return _obiettivi.firstWhere((o) => o.id == obiettivoId);
    } catch (e) {
      return null;
    }
  }

  /// Ottiene gli obiettivi completati
  List<ObiettivoRisparmio> get obiettiviCompletati {
    return _obiettivi.where((o) => o.isCompletato).toList();
  }

  /// Ottiene gli obiettivi in corso
  List<ObiettivoRisparmio> get obiettiviInCorso {
    return _obiettivi.where((o) => !o.isCompletato).toList();
  }

  /// Ottiene gli obiettivi in scadenza
  List<ObiettivoRisparmio> get obiettiviInScadenza {
    return _obiettivi.where((o) => o.isInScadenza).toList();
  }

  /// Calcola il totale risparmiato
  double get totaleRisparmiato {
    return _obiettivi.fold(0.0, (sum, obiettivo) => sum + obiettivo.importoAttuale);
  }

  /// Calcola il totale target
  double get totaleTarget {
    return _obiettivi.fold(0.0, (sum, obiettivo) => sum + obiettivo.importoTarget);
  }

  /// Calcola la percentuale totale di completamento
  double get percentualeTotaleCompletamento {
    if (totaleTarget <= 0) return 0.0;
    return (totaleRisparmiato / totaleTarget * 100).clamp(0.0, 100.0);
  }

  @override
  void clear() {
    _obiettivi = [];
    super.clear();
  }

  @override
  Future<void> refresh() async {
    await caricaObiettivi();
  }
} 