import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/categoria.dart';
import '../models/sottocategoria.dart';
import 'base_service.dart';

class CategoriaService extends BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  
  List<Categoria> _categorie = [];

  List<Categoria> get categorie => _categorie;

  @override
  void clear() {
    _categorie = [];
    super.clear();
  }

  @override
  Future<void> refresh() async {
    await caricaCategorie();
  }

  // Crea una nuova categoria
  Future<bool> creaCategoria({
    required String nome,
    required String icona,
    required String coloreIcona,
    List<Sottocategoria> sottocategorie = const [],
  }) async {
    try {
      clearError();
      
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      String categoriaId = _uuid.v4();
      
      Categoria nuovaCategoria = Categoria(
        id: categoriaId,
        nome: nome,
        icona: icona,
        coloreIcona: coloreIcona,
        profileId: user.uid,
        sottocategorie: sottocategorie,
      );

      print('💾 Salvando categoria: ${nuovaCategoria.nome} (${nuovaCategoria.id})');
      print('💾 Dati da salvare: ${nuovaCategoria.toMap()}');

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('categorie')
          .doc(categoriaId)
          .set(nuovaCategoria.toMap());

      _categorie.add(nuovaCategoria);
      print('💾 Categoria aggiunta alla lista locale. Totale: ${_categorie.length}');
      
      notifyListeners();
      return true;

    } catch (e) {
      setError("Errore durante la creazione della categoria: $e");
      notifyListeners();
      return false;
    }
  }

  // Carica tutte le categorie dell'utente
  Future<bool> caricaCategorie() async {
    try {
      clearError();
      
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('categorie')
          .get();

      _categorie = querySnapshot.docs
          .map((doc) => Categoria.fromMap({...(doc.data() as Map<String, dynamic>), 'id': doc.id}))
          .toList();

      print('📂 Categorie caricate: ${_categorie.length}');
      for (var categoria in _categorie) {
        print('  - ${categoria.nome} (${categoria.id})');
      }

      notifyListeners();
      return true;

    } catch (e) {
      setError("Errore durante il caricamento delle categorie: $e");
      notifyListeners();
      return false;
    }
  }

  // Aggiorna una categoria esistente
  Future<bool> aggiornaCategoria({
    required String categoriaId,
    String? nome,
    String? icona,
    String? coloreIcona,
    List<Sottocategoria>? sottocategorie,
  }) async {
    try {
      clearError();
            
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      Map<String, dynamic> updateData = {};
      if (nome != null) updateData['nome'] = nome;
      if (icona != null) updateData['icona'] = icona;
      if (coloreIcona != null) updateData['coloreIcona'] = coloreIcona;
      if (sottocategorie != null) updateData['sottocategorie'] = sottocategorie.map((s) => s.toMap()).toList();

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('categorie')
          .doc(categoriaId)
          .update(updateData);

      // Aggiorna la lista locale
      int index = _categorie.indexWhere((categoria) => categoria.id == categoriaId);
      if (index != -1) {
        _categorie[index] = _categorie[index].copyWith(
          nome: nome,
          icona: icona,
          coloreIcona: coloreIcona,
          sottocategorie: sottocategorie,
        );
      }

      notifyListeners();
      return true;

    } catch (e) {
      setError("Errore durante l'aggiornamento della categoria: $e");
      notifyListeners();
      return false;
    }
  }

  // Elimina una categoria
  Future<bool> eliminaCategoria(String categoriaId) async {
    try {
      clearError();
      
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .collection('categorie')
          .doc(categoriaId)
          .delete();

      _categorie.removeWhere((categoria) => categoria.id == categoriaId);
      notifyListeners();
      return true;

    } catch (e) {
      setError("Errore durante l'eliminazione della categoria: $e");
      notifyListeners();
      return false;
    }
  }

  // Aggiunge una sottocategoria a una categoria
  Future<bool> aggiungiSottocategoria({
    required String categoriaId,
    required String nomeSottocategoria,
  }) async {
    try {
      clearError();
      
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      // Trova la categoria e aggiungi la sottocategoria
      int index = _categorie.indexWhere((categoria) => categoria.id == categoriaId);
      
      // Genera ID semplice incrementale per le sottocategorie (formato Kotlin)
      int nextId = _categorie.isNotEmpty && index != -1 
          ? _categorie[index].sottocategorie.length 
          : 0;
      String sottocategoriaId = nextId.toString();
      
      Sottocategoria nuovaSottocategoria = Sottocategoria(
        id: sottocategoriaId,
        nome: nomeSottocategoria,
      );
      if (index != -1) {
        List<Sottocategoria> nuoveSottocategorie = List.from(_categorie[index].sottocategorie);
        nuoveSottocategorie.add(nuovaSottocategoria);
        
        _categorie[index] = _categorie[index].copyWith(
          sottocategorie: nuoveSottocategorie,
        );

        // Aggiorna nel database
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('categorie')
            .doc(categoriaId)
            .update({
          'sottocategorie': nuoveSottocategorie.map((s) => s.toMap()).toList(),
        });

        notifyListeners();
        return true;
      }

      return false;

    } catch (e) {
      setError("Errore durante l'aggiunta della sottocategoria: $e");
      notifyListeners();
      return false;
    }
  }

  // Rimuove una sottocategoria da una categoria
  Future<bool> rimuoviSottocategoria({
    required String categoriaId,
    required String sottocategoriaId,
  }) async {
    try {
      clearError();
      
      User? user = _auth.currentUser;
      if (user == null) {
        setError("Utente non autenticato");
        notifyListeners();
        return false;
      }

      int index = _categorie.indexWhere((categoria) => categoria.id == categoriaId);
      if (index != -1) {
        List<Sottocategoria> nuoveSottocategorie = _categorie[index].sottocategorie
            .where((s) => s.id != sottocategoriaId)
            .toList();
        
        _categorie[index] = _categorie[index].copyWith(
          sottocategorie: nuoveSottocategorie,
        );

        // Aggiorna nel database
        await _firestore
            .collection('utenti')
            .doc(user.uid)
            .collection('categorie')
            .doc(categoriaId)
            .update({
          'sottocategorie': nuoveSottocategorie.map((s) => s.toMap()).toList(),
        });

        notifyListeners();
        return true;
      }

      return false;

    } catch (e) {
      setError("Errore durante la rimozione della sottocategoria: $e");
      notifyListeners();
      return false;
    }
  }

  // Ottiene una categoria specifica
  Categoria? getCategoriaById(String categoriaId) {
    try {
      return _categorie.firstWhere((categoria) => categoria.id == categoriaId);
    } catch (e) {
      return null;
    }
  }


} 