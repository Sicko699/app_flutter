import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/conto.dart';
import '../models/transazione.dart';
import 'base_service.dart';
import 'app_events.dart';

class ContoService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppEvents _events = AppEvents();
  final Uuid _uuid = const Uuid();
  
  List<Conto> _conti = [];

  /// Lista dei conti dell'utente
  List<Conto> get conti => _conti;

  ContoService() {
    // Ascolta eventi di transazioni per aggiornare i saldi
    _events.listen<TransazioneCreatedEvent>(_handleTransazioneCreated);
    _events.listen<TransazioneUpdatedEvent>(_handleTransazioneUpdated);
    _events.listen<TransazioneDeletedEvent>(_handleTransazioneDeleted);
  }

  @override
  Future<void> refresh() async {
    await caricaConti();
  }

  // Event handlers
  void _handleTransazioneCreated(TransazioneCreatedEvent event) {
    // Ricarica i conti per aggiornare i saldi
    refresh();
  }

  void _handleTransazioneUpdated(TransazioneUpdatedEvent event) {
    // Ricarica i conti per aggiornare i saldi
    refresh();
  }

  void _handleTransazioneDeleted(TransazioneDeletedEvent event) {
    // Ricarica i conti per aggiornare i saldi
    refresh();
  }

  // Crea un nuovo conto
  Future<bool> creaConto({
    required String nome,
    required String tipo,
    required double saldo,
  }) async {
    return await executeOperation<bool>(
      () async {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        String contoId = _uuid.v4();
        
        Conto nuovoConto = Conto(
          id: contoId,
          nome: nome,
          tipo: tipo,
          saldo: saldo,
          profileId: user.uid,
        );

        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('conti')
            .doc(contoId)
            .set(nuovoConto.toMap());

        _conti.add(nuovoConto);
        return true;
      },
      errorMessage: 'Errore durante la creazione del conto',
    ) ?? false;
  }

  // Carica tutti i conti dell'utente
  Future<bool> caricaConti() async {
    return await executeOperation<bool>(
      () async {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        QuerySnapshot querySnapshot = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('conti')
            .get();

        _conti = querySnapshot.docs
            .map((doc) => Conto.fromMap({...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
            .toList();


        setInitialized();
        return true;
      },
      errorMessage: 'Errore durante il caricamento dei conti',
    ) ?? false;
  }

  // Aggiorna un conto esistente
  Future<bool> aggiornaConto({
    required String contoId,
    String? nome,
    String? tipo,
  }) async {
    return await executeOperation<bool>(
      () async {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        Map<String, dynamic> updateData = {};
        if (nome != null) updateData['nome'] = nome;
        if (tipo != null) updateData['tipo'] = tipo;

        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('conti')
            .doc(contoId)
            .update(updateData);

        // Aggiorna la lista locale
        int index = _conti.indexWhere((conto) => conto.id == contoId);
        if (index != -1) {
          _conti[index] = _conti[index].copyWith(
            nome: nome,
            tipo: tipo,
          );
        }

        return true;
      },
      errorMessage: 'Errore durante l\'aggiornamento del conto',
    ) ?? false;
  }

  // Elimina un conto e tutte le transazioni associate (delete on cascade)
  Future<bool> eliminaConto(String contoId) async {
    return await executeOperation<bool>(
      () async {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }

        // 1. Elimina tutte le transazioni associate al conto
        QuerySnapshot transazioniSnapshot = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('transazioni')
            .where('contoId', isEqualTo: contoId)
            .get();

        // Elimina le transazioni in batch
        WriteBatch batch = _firestore.batch();
        for (var doc in transazioniSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // 2. Elimina anche le transazioni dove questo conto è conto di destinazione
        QuerySnapshot transazioniDestinazioneSnapshot = await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('transazioni')
            .where('contoDestinazioneId', isEqualTo: contoId)
            .get();

        for (var doc in transazioniDestinazioneSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // 3. Elimina il conto
        batch.delete(_firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('conti')
            .doc(contoId));

        // Esegui tutte le operazioni in una singola transazione
        await batch.commit();

        // Aggiorna la lista locale
        _conti.removeWhere((conto) => conto.id == contoId);
        
        // Emetti evento per notificare altri service
        _events.emit(ContoDeletedEvent(contoId: contoId));
        
        return true;
      },
      errorMessage: 'Errore durante l\'eliminazione del conto',
    ) ?? false;
  }

  // Ottiene un conto specifico
  Conto? getContoById(String contoId) {
    try {
      return _conti.firstWhere((conto) => conto.id == contoId);
    } catch (e) {
      return null;
    }
  }

  @override
  void clear() {
    _conti = [];
    super.clear();
  }

  // Calcola il saldo totale di un conto (saldo iniziale + tutte le transazioni)
  double calcolaSaldoConto(String contoId, List<Transazione> transazioni) {
    try {
      // Trova il conto per ottenere il saldo iniziale
      Conto? conto = _conti.firstWhere(
        (c) => c.id == contoId,
        orElse: () => Conto(id: '', nome: '', tipo: '', saldo: 0.0, profileId: ''),
      );
      
      // Se il conto non esiste, ritorna 0
      if (conto.id.isEmpty) {
        return 0.0;
      }
      
      // Partiamo dal saldo attuale del conto
      double saldo = conto.saldo;
      
      for (var transazione in transazioni) {
        if (transazione.contoId == contoId) {
          if (transazione.tipo == 'entrata') {
            saldo += transazione.importo;
          } else if (transazione.tipo == 'uscita') {
            saldo -= transazione.importo;
          } else if (transazione.tipo == 'trasferimento') {
            // Per i trasferimenti, sottrai dal conto di origine
            saldo -= transazione.importo;
          }
        }
        
        // Per i trasferimenti, aggiungi al conto di destinazione
        if (transazione.tipo == 'trasferimento' && 
            transazione.contoDestinazioneId == contoId) {
          saldo += transazione.importo;
        }
      }
      
      return saldo;
    } catch (e) {
      return 0.0;
    }
  }

  // Aggiorna i saldi di tutti i conti basato sulle transazioni
  Future<bool> aggiornaSaldiConti(List<Transazione> transazioni) async {
    return await executeOperation<bool>(
      () async {
        User? user = _auth.currentUser;
        if (user == null) {
          throw Exception('Utente non autenticato');
        }



        // Aggiorna ogni conto
        for (Conto conto in _conti) {
          try {
            // Ricalcola il saldo totale da zero
            double nuovoSaldo = calcolaSaldoConto(conto.id, transazioni);

            
            // Aggiorna nel database
            await _firestore
                .collection('utenti')
                .doc(user.uid)
                .collection('conti')
                .doc(conto.id)
                .update({'saldo': nuovoSaldo});
            
            // Aggiorna la lista locale
            int index = _conti.indexWhere((c) => c.id == conto.id);
            if (index != -1) {
              _conti[index] = _conti[index].copyWith(saldo: nuovoSaldo);
            }
          } catch (e) {
            // Continua con gli altri conti invece di fermarsi
          }
        }
        
        return true;
      },
      errorMessage: 'Errore durante l\'aggiornamento dei saldi',
    ) ?? false;
  }

  // Calcola statistiche mensili per un conto
  // NOTA: I trasferimenti vengono esclusi dalle statistiche di entrate/uscite
  // perché rappresentano solo movimenti interni tra conti, non entrate o uscite reali
  Map<String, double> calcolaStatisticheMensili(String contoId, List<Transazione> transazioni) {
    // Verifica che l'ID del conto sia valido
    if (contoId.isEmpty) {
      return {'entrate': 0.0, 'uscite': 0.0};
    }

    double entrate = 0.0;
    double uscite = 0.0;
    
    final now = DateTime.now();
    final inizioMese = DateTime(now.year, now.month, 1);
    final fineMese = DateTime(now.year, now.month + 1, 0);
    
    for (var transazione in transazioni) {
      if (transazione.contoId == contoId) {
        if ((transazione.data.isAfter(inizioMese) || transazione.data.isAtSameMomentAs(inizioMese)) && 
            (transazione.data.isBefore(fineMese) || transazione.data.isAtSameMomentAs(fineMese))) {
          // Escludi i trasferimenti dalle statistiche di entrate/uscite
          if (transazione.tipo == 'entrata') {
            entrate += transazione.importo;
          } else if (transazione.tipo == 'uscita') {
            uscite += transazione.importo;
          }
          // I trasferimenti non vengono conteggiati nelle statistiche
        }
      }
      
      // I trasferimenti non vengono conteggiati nelle statistiche di entrate/uscite
      // Vengono gestiti solo per il calcolo del saldo del conto
    }
    
    return {
      'entrate': entrate,
      'uscite': uscite,
    };
  }

}