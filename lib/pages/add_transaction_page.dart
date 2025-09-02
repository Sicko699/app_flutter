import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transazione_service.dart';
import '../widgets/transazione_form_widget.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Transazione'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TransazioneFormWidget(
          onSave: _salvaTransazione,
        ),
      ),
    );
  }

  Future<void> _salvaTransazione(
    String titolo,
    String descrizione,
    double importo,
    String tipo,
    String categoriaId,
    String sottocategoriaId,
    String contoId,
    String? contoDestinazioneId,
    DateTime data,
    bool isRicorrente,
    String? frequenzaRicorrenza,
    DateTime? dataFineRicorrenza,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transazioneService = Provider.of<TransazioneService>(context, listen: false);
      
      final successo = await transazioneService.creaTransazione(
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
      );

      if (successo && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRicorrente 
                  ? 'Transazione ricorrente creata con successo!'
                  : 'Transazione creata con successo!'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${transazioneService.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 