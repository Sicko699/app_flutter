import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transazione_service.dart';
import '../widgets/transazione_form_widget.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Transazione'),
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
                  ? 'Transazione ricorrente creata con successo! Puoi aggiungerne un\'altra.'
                  : 'Transazione creata con successo! Puoi aggiungerne un\'altra.'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        // Non facciamo più Navigator.pop(), rimaniamo nella pagina
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