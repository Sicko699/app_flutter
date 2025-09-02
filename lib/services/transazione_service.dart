import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/transazione.dart';
import 'conto_service.dart';
import 'base_service.dart';
import 'app_events.dart';

class TransazioneService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppEvents _events = AppEvents();
  final Uuid _uuid = const Uuid();
  
  List<Transazione> _transazioni = [];
  ContoService? _contoService;

  List<Transazione> get transazioni => _transazioni;

  @override
  void clear() {
    _transazioni = [];
    super.clear();
  }

  @override
  Future<void> refresh() async {
    await ricaricaTransazioni();
  }

  void setContoService(ContoService contoService) {
    _contoService = contoService;
  }

  /// Ricarica le transazioni (utile dopo l'eliminazione di un conto)
  Future<void> ricaricaTransazioni() async {
    await caricaTransazioni();
  }

  /// Carica tutte le transazioni dell'utente
  Future<bool> caricaTransazioni() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setError('Utente non autenticato');
        return false;
      }

      final snapshot = await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('transazioni')
          .orderBy('data', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        _transazioni = [];
        notifyListeners();
        return true;
      }

      _transazioni = snapshot.docs
          .map((doc) {
            try {
              final data = {...doc.data(), 'id': doc.id};
              return Transazione.fromMap(data);
            } catch (parseError) {
              rethrow;
            }
          })
          .toList();

      notifyListeners();
      return true;
    } catch (e) {
      setError('Errore nel caricamento delle transazioni: $e');
      return false;
    }
  }

  /// Crea una nuova transazione
  Future<bool> creaTransazione({
    required String titolo,
    required String descrizione,
    required double importo,
    required String tipo,
    required String categoriaId,
    required String sottocategoriaId,
    required String contoId,
    String? contoDestinazioneId,
    required DateTime data,
    bool isRicorrente = false,
    String? frequenzaRicorrenza,
    DateTime? dataFineRicorrenza,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setError('Utente non autenticato');
        return false;
      }

      final now = DateTime.now();
      final transazioneId = _uuid.v4();
      final transazione = Transazione(
        id: transazioneId,
        titolo: titolo,
        descrizione: descrizione,
        importo: importo,
        tipo: tipo,
        categoriaId: categoriaId,
        sottocategoriaId: sottocategoriaId,
        contoId: contoId,
        contoDestinazioneId: contoDestinazioneId,
        data: data,
        isRicorrente: isRicorrente,
        frequenzaRicorrenza: frequenzaRicorrenza,
        dataFineRicorrenza: dataFineRicorrenza,
        dataCreazione: now,
        dataModifica: now,
        profileId: user.uid, // Aggiunto per compatibilità Kotlin
      );

      // Salva con l'ID UUID invece di generare automaticamente
      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('transazioni')
          .doc(transazioneId)
          .set(transazione.toMap());

      _transazioni.insert(0, transazione);

      // Se è ricorrente, crea le transazioni future
      if (isRicorrente && frequenzaRicorrenza != null) {
        await _creaTransazioniRicorrenti(transazione);
      }

      // Emetti evento per notificare altri service
      _events.emit(TransazioneCreatedEvent(
        transazioneId: transazioneId,
        contoId: contoId,
        importo: importo,
        tipo: tipo,
      ));

      // Aggiorna i saldi dei conti
      if (_contoService != null) {
        try {
          await _contoService!.aggiornaSaldiConti(_transazioni);
        } catch (e) {
          // Silently ignore balance update errors
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Errore nella creazione della transazione: $e');
      return false;
    }
  }

  /// Aggiorna una transazione esistente
  Future<bool> aggiornaTransazione({
    required String transazioneId,
    String? titolo,
    String? descrizione,
    double? importo,
    String? tipo,
    String? categoriaId,
    String? sottocategoriaId,
    String? contoId,
    String? contoDestinazioneId,
    DateTime? data,
    bool? isRicorrente,
    String? frequenzaRicorrenza,
    DateTime? dataFineRicorrenza,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setError('Utente non autenticato');
        return false;
      }

      final updateData = <String, dynamic>{
        'dataModifica': DateTime.now().toIso8601String(),
      };

      if (titolo != null) updateData['titolo'] = titolo;
      if (descrizione != null) updateData['descrizione'] = descrizione;
      if (importo != null) updateData['importo'] = importo;
      if (tipo != null) updateData['tipo'] = tipo;
      if (categoriaId != null) updateData['categoriaId'] = categoriaId;
      if (sottocategoriaId != null) updateData['sottocategoriaId'] = sottocategoriaId;
      if (contoId != null) updateData['contoId'] = contoId;
      if (contoDestinazioneId != null) updateData['contoDestinazioneId'] = contoDestinazioneId;
      if (data != null) updateData['data'] = data.toIso8601String();
      if (isRicorrente != null) updateData['isRicorrente'] = isRicorrente;
      if (frequenzaRicorrenza != null) updateData['frequenzaRicorrenza'] = frequenzaRicorrenza;
      if (dataFineRicorrenza != null) {
        updateData['dataFineRicorrenza'] = dataFineRicorrenza.toIso8601String();
      }

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('transazioni')
          .doc(transazioneId)
          .update(updateData);

      // Aggiorna la lista locale
      final index = _transazioni.indexWhere((t) => t.id == transazioneId);
      if (index != -1) {
        final transazione = _transazioni[index];
        _transazioni[index] = transazione.copyWith(
          titolo: titolo ?? transazione.titolo,
          descrizione: descrizione ?? transazione.descrizione,
          importo: importo ?? transazione.importo,
          tipo: tipo ?? transazione.tipo,
          categoriaId: categoriaId ?? transazione.categoriaId,
          sottocategoriaId: sottocategoriaId ?? transazione.sottocategoriaId,
          contoId: contoId ?? transazione.contoId,
          contoDestinazioneId: contoDestinazioneId ?? transazione.contoDestinazioneId,
          data: data ?? transazione.data,
          isRicorrente: isRicorrente ?? transazione.isRicorrente,
          frequenzaRicorrenza: frequenzaRicorrenza ?? transazione.frequenzaRicorrenza,
          dataFineRicorrenza: dataFineRicorrenza ?? transazione.dataFineRicorrenza,
          dataModifica: DateTime.now(),
        );
      }

      // Emetti evento per notificare altri service
      _events.emit(TransazioneUpdatedEvent(
        transazioneId: transazioneId,
        oldContoId: index != -1 ? _transazioni[index].contoId : null,
        newContoId: contoId,
        oldImporto: index != -1 ? _transazioni[index].importo : null,
        newImporto: importo,
        oldTipo: index != -1 ? _transazioni[index].tipo : null,
        newTipo: tipo,
      ));

      // Aggiorna i saldi dei conti
      if (_contoService != null) {
        try {
          await _contoService!.aggiornaSaldiConti(_transazioni);
        } catch (e) {
          // Silently ignore balance update errors
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      setError('Errore nell\'aggiornamento della transazione: $e');
      return false;
    }
  }

  /// Elimina una transazione
  Future<bool> eliminaTransazione(String transazioneId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setError('Utente non autenticato');
        return false;
      }

      // Trova la transazione prima di eliminarla per emettere l'evento
      final transazione = _transazioni.firstWhere(
        (t) => t.id == transazioneId,
        orElse: () => Transazione(
          id: transazioneId,
          titolo: '',
          descrizione: '',
          importo: 0.0,
          tipo: 'uscita',
          categoriaId: '',
          sottocategoriaId: '',
          contoId: '',
          data: DateTime.now(),
          dataCreazione: DateTime.now(),
          dataModifica: DateTime.now(),
          profileId: user.uid,
        ),
      );

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('transazioni')
          .doc(transazioneId)
          .delete();

      _transazioni.removeWhere((t) => t.id == transazioneId);
      
      // Emetti evento per notificare altri service
      _events.emit(TransazioneDeletedEvent(
        transazioneId: transazioneId,
        contoId: transazione.contoId,
        importo: transazione.importo,
        tipo: transazione.tipo,
      ));
      
      // Aggiorna i saldi dei conti
      if (_contoService != null) {
        try {
          await _contoService!.aggiornaSaldiConti(_transazioni);
        } catch (e) {
          // Silently ignore balance update errors
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      setError('Errore nell\'eliminazione della transazione: $e');
      return false;
    }
  }

  /// Crea le transazioni ricorrenti future
  Future<void> _creaTransazioniRicorrenti(Transazione transazionePadre) async {
    if (!transazionePadre.isRicorrente || transazionePadre.frequenzaRicorrenza == null) {
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dataFine = transazionePadre.dataFineRicorrenza ?? 
        DateTime(now.year + 1, now.month, now.day); // Default: 1 anno

    DateTime prossimaData = transazionePadre.data;
    
    // Crea transazioni future fino alla data di fine
    while (prossimaData.isBefore(dataFine)) {
      switch (transazionePadre.frequenzaRicorrenza!) {
        case 'giornaliera':
          prossimaData = prossimaData.add(const Duration(days: 1));
          break;
        case 'settimanale':
          prossimaData = prossimaData.add(const Duration(days: 7));
          break;
        case 'mensile':
          prossimaData = DateTime(
            prossimaData.year,
            prossimaData.month + 1,
            prossimaData.day,
          );
          break;
        case 'annuale':
          prossimaData = DateTime(
            prossimaData.year + 1,
            prossimaData.month,
            prossimaData.day,
          );
          break;
      }

      if (prossimaData.isAfter(dataFine)) break;

      // Crea la transazione ricorrente
      final transazioneRicorrenteId = _uuid.v4();
      final transazioneRicorrente = Transazione(
        id: transazioneRicorrenteId,
        titolo: transazionePadre.titolo,
        descrizione: transazionePadre.descrizione,
        importo: transazionePadre.importo,
        tipo: transazionePadre.tipo,
        categoriaId: transazionePadre.categoriaId,
        sottocategoriaId: transazionePadre.sottocategoriaId,
        contoId: transazionePadre.contoId,
        data: prossimaData,
        isRicorrente: true,
        frequenzaRicorrenza: transazionePadre.frequenzaRicorrenza,
        dataFineRicorrenza: transazionePadre.dataFineRicorrenza,
        transazionePadreId: transazionePadre.id,
        dataCreazione: DateTime.now(),
        dataModifica: DateTime.now(),
        profileId: transazionePadre.profileId,
      );

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('transazioni')
          .doc(transazioneRicorrenteId)
          .set(transazioneRicorrente.toMap());
    }
  }

  /// Ottiene le transazioni per un periodo specifico
  List<Transazione> getTransazioniPerPeriodo(DateTime inizio, DateTime fine) {
    return _transazioni.where((t) => 
        t.data.isAfter(inizio.subtract(const Duration(days: 1))) && 
        t.data.isBefore(fine.add(const Duration(days: 1)))
    ).toList();
  }

  /// Ottiene le transazioni per un conto specifico
  List<Transazione> getTransazioniPerConto(String contoId) {
    return _transazioni.where((t) => t.contoId == contoId).toList();
  }

  /// Ottiene le transazioni per una categoria specifica
  List<Transazione> getTransazioniPerCategoria(String categoriaId) {
    return _transazioni.where((t) => t.categoriaId == categoriaId).toList();
  }

  /// Ottiene le transazioni ricorrenti
  List<Transazione> getTransazioniRicorrenti() {
    return _transazioni.where((t) => t.isRicorrente).toList();
  }

  /// Calcola il saldo totale per un periodo
  /// NOTA: I trasferimenti non influenzano le statistiche di entrate/uscite,
  /// ma vengono gestiti correttamente per il calcolo del saldo
  double calcolaSaldoPerPeriodo(DateTime inizio, DateTime fine) {
    final transazioni = getTransazioniPerPeriodo(inizio, fine);
    return transazioni.fold(0.0, (sum, t) {
      if (t.tipo == 'entrata') {
        return sum + t.importo;
      } else if (t.tipo == 'uscita') {
        return sum - t.importo;
      } else if (t.tipo == 'trasferimento') {
        // I trasferimenti non influenzano il saldo totale dell'utente
        // Vengono gestiti solo per aggiornare i saldi dei singoli conti
        return sum;
      }
      return sum;
    });
  }

  /// Calcola il saldo totale per un conto
  /// NOTA: I trasferimenti vengono gestiti correttamente per aggiornare
  /// il saldo del conto specifico (sottrazione dal conto di origine, aggiunta al conto di destinazione)
  double calcolaSaldoPerConto(String contoId) {
    final transazioni = getTransazioniPerConto(contoId);
    return transazioni.fold(0.0, (sum, t) {
      if (t.tipo == 'entrata') {
        return sum + t.importo;
      } else if (t.tipo == 'uscita') {
        return sum - t.importo;
      } else if (t.tipo == 'trasferimento') {
        // Per i trasferimenti: sottrai dal conto di origine, aggiungi al conto di destinazione
        if (t.contoId == contoId) {
          return sum - t.importo; // Sottrazione dal conto di origine
        } else if (t.contoDestinazioneId == contoId) {
          return sum + t.importo; // Aggiunta al conto di destinazione
        }
        return sum;
      }
      return sum;
    });
  }


} 