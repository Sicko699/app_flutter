import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transazione_service.dart';
import '../models/transazione.dart';
import '../widgets/transazione_form_widget.dart';

class EditTransactionPage extends StatefulWidget {
  final Transazione transazione;

  const EditTransactionPage({
    super.key,
    required this.transazione,
  });

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Transazione'),
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
          onSave: _aggiornaTransazione,
          initialTitolo: widget.transazione.titolo,
          initialImporto: widget.transazione.importo,
          initialTipo: widget.transazione.tipo,
          initialCategoriaId: widget.transazione.categoriaId,
          initialSottocategoriaId: widget.transazione.sottocategoriaId,
          initialContoId: widget.transazione.contoId,
          initialContoDestinazioneId: widget.transazione.contoDestinazioneId,
          initialData: widget.transazione.data,
          initialIsRicorrente: widget.transazione.isRicorrente,
          initialFrequenzaRicorrenza: widget.transazione.frequenzaRicorrenza,
          initialDataFineRicorrenza: widget.transazione.dataFineRicorrenza,
        ),
      ),
    );
  }

  Future<void> _aggiornaTransazione(
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

      final successo = await transazioneService.aggiornaTransazione(
        transazioneId: widget.transazione.id,
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
          const SnackBar(
            content: Text('Transazione aggiornata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (mounted) {
          Navigator.pop(context);
        }
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
            content: Text('Errore durante l\'aggiornamento: $e'),
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