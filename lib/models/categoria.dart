import 'sottocategoria.dart';
import '../utils/icon_utils.dart';
import '../utils/color_utils.dart';

class Categoria {
    final String id;
    String nome;
    String icona;
    String coloreIcona;
    String profileId;
    final List<Sottocategoria> sottocategorie;

    Categoria({
        required this.id,
        required this.nome,
        required this.icona,
        required this.coloreIcona,
        required this.profileId,
        required this.sottocategorie,
    });

    // Converte la categoria in una Map per Firestore (formato Kotlin)
    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'nome': nome,
            'icona': _isNumericIcon(icona) ? IconUtils.codePointToIconName(icona) : icona,
            'coloreIcona': _isNumericColor(coloreIcona) ? ColorUtils.colorValueToHex(coloreIcona) : coloreIcona,
            'profileId': profileId,
            'sottocategorie': sottocategorie.map((s) => s.toMap()).toList(),
        };
    }

    // Helper per determinare se l'icona è nel formato numerico
    static bool _isNumericIcon(String icona) {
        return RegExp(r'^\d+$').hasMatch(icona);
    }

    // Helper per determinare se il colore è nel formato numerico
    static bool _isNumericColor(String colore) {
        return RegExp(r'^\d+$').hasMatch(colore);
    }

    // Crea una Categoria da una Map di Firestore (supporta entrambi i formati)
    factory Categoria.fromMap(Map<String, dynamic> map) {
        String iconaValue = _parseString(map['icona']);
        String coloreValue = _parseString(map['coloreIcona']);
        
        // Se i valori sono in formato Kotlin (nome/hex), convertire per uso interno Flutter
        if (!_isNumericIcon(iconaValue)) {
            // È già nel formato nome, mantenere così
        }
        if (!_isNumericColor(coloreValue)) {
            // È già nel formato hex, mantenere così
        }
        
        return Categoria(
            id: map['id'] ?? '',
            nome: map['nome'] ?? '',
            icona: iconaValue,
            coloreIcona: coloreValue,
            profileId: map['profileId'] ?? '',
            sottocategorie: (map['sottocategorie'] as List<dynamic>?)
                ?.map((s) => Sottocategoria.fromMap(s))
                .toList() ?? [],
        );
    }

    // Metodo helper per convertire valori in string
    static String _parseString(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        return value.toString();
    }

    // Copia la categoria con nuovi valori
    Categoria copyWith({
        String? id,
        String? nome,
        String? icona,
        String? coloreIcona,
        String? profileId,
        List<Sottocategoria>? sottocategorie,
    }) {
        return Categoria(
            id: id ?? this.id,
            nome: nome ?? this.nome,
            icona: icona ?? this.icona,
            coloreIcona: coloreIcona ?? this.coloreIcona,
            profileId: profileId ?? this.profileId,
            sottocategorie: sottocategorie ?? this.sottocategorie,
        );
    }
}