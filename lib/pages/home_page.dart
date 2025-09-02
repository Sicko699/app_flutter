import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profilo_service.dart';
import '../services/conto_service.dart';
import '../services/categoria_service.dart';
import '../services/transazione_service.dart';
import '../services/obiettivo_risparmio_service.dart';
import '../models/conto.dart';
import '../models/transazione.dart';
import '../models/categoria.dart';

import '../models/obiettivo_risparmio.dart';
import 'transactions_list_page.dart';
import 'transactions_page.dart';
import 'accounts_page.dart';
import 'categories_management_page.dart';
import 'savings_goals_page.dart';
import '../utils/color_utils.dart';
import '../utils/icon_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _caricaDati();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Deferred call per evitare problemi durante il build
      Future.microtask(() => _caricaDati());
    }
  }

  /// Trova il conto principale (quello con il saldo più alto)
  /// 
  /// Logica di selezione:
  /// 1. Trova il conto con il saldo più alto
  /// 2. Se ci sono più conti con lo stesso saldo massimo, 
  ///    seleziona il primo in ordine alfabetico
  /// 3. Se non ci sono conti, restituisce null
  Conto? _trovaContoPrincipale(List<Conto> conti) {
    if (conti.isEmpty) return null;
    
    // Trova il saldo massimo
    final saldoMassimo = conti.map((c) => c.saldo ?? 0.0).reduce((a, b) => a > b ? a : b);
    
    // Trova tutti i conti con il saldo massimo
    final contiConSaldoMassimo = conti.where((c) => (c.saldo ?? 0.0) == saldoMassimo).toList();
    
    // Se ci sono più conti con lo stesso saldo massimo, prendi il primo in ordine alfabetico
    if (contiConSaldoMassimo.length > 1) {
      contiConSaldoMassimo.sort((a, b) => a.nome.compareTo(b.nome));
    }
    
    return contiConSaldoMassimo.isNotEmpty ? contiConSaldoMassimo.first : null;
  }

  Future<void> _caricaDati() async {
    // Evita di chiamare i servizi durante il build per prevenire loop infiniti
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      final contoService = Provider.of<ContoService>(context, listen: false);
      final categoriaService = Provider.of<CategoriaService>(context, listen: false);
      final transazioneService = Provider.of<TransazioneService>(context, listen: false);
      final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
      
      // Carica i dati in parallelo per migliorare le performance
      await Future.wait([
        contoService.caricaConti(),
        categoriaService.caricaCategorie(),
        transazioneService.caricaTransazioni(),
        obiettivoService.caricaObiettivi(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track That')
      ),
      body: RefreshIndicator(
        onRefresh: _caricaDati,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saluto - usa Selector per ottimizzare
              Selector<ProfiloService, String?>(
                selector: (context, profiloService) => 
                    profiloService.profiloCorrente?.nome,
                builder: (context, nome, _) => _buildWelcomeHeader(nome),
              ),
              const SizedBox(height: 24),
              
              // Riepilogo conti - usa Selector per lista conti
              Selector<ContoService, List<Conto>>(
                selector: (context, contoService) => contoService.conti,
                builder: (context, conti, _) => _buildAccountsSummary(conti),
              ),
              const SizedBox(height: 24),
              
              // Azioni rapide - statiche, non servono provider
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Statistiche recenti - usa Selector per transazioni
              Selector<TransazioneService, List<Transazione>>(
                selector: (context, transazioneService) => 
                    transazioneService.transazioni,
                builder: (context, transazioni, _) => 
                    _buildRecentStats(transazioni),
              ),
              const SizedBox(height: 24),
              
              // Categorie più usate - usa Selector per categorie
              Selector<CategoriaService, List<Categoria>>(
                selector: (context, categoriaService) => 
                    categoriaService.categorie,
                builder: (context, categorie, _) => 
                    _buildTopCategories(categorie),
              ),
              const SizedBox(height: 24),
              
              // Obiettivi di risparmio - usa Selector per obiettivi
              Selector<ObiettivoRisparmioService, List<ObiettivoRisparmio>>(
                selector: (context, obiettivoService) => 
                    obiettivoService.obiettivi,
                builder: (context, obiettivi, _) => 
                    _buildSavingsGoals(obiettivi),
              ),
              const SizedBox(height: 24),
              
              // Ultime transazioni - usa Consumer3 per questo caso complesso
              Consumer3<TransazioneService, ContoService, CategoriaService>(
                builder: (context, transazioneService, contoService, categoriaService, _) =>
                    _buildRecentTransactions(transazioneService, contoService, categoriaService),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String? nome) {
    final ora = DateTime.now().hour;
    String saluto;
    
    if (ora < 12) {
      saluto = 'Buongiorno';
    } else if (ora < 18) {
      saluto = 'Buon pomeriggio';
    } else {
      saluto = 'Buonasera';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              child: Text(
                nome?.isNotEmpty == true 
                    ? nome![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$saluto, ${nome ?? 'Utente'}!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Benvenuto nel tuo dashboard finanziario',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsSummary(List<Conto> conti) {
    final saldoTotale = conti.fold<double>(0.0, (double sum, Conto conto) => sum + (conto.saldo ?? 0.0));
    
    // Trova il conto principale (quello con il saldo più alto)
    final contoPrincipale = _trovaContoPrincipale(conti);
    


    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riepilogo Conti',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${conti.length} conti',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Totale',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€ ${saldoTotale.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: saldoTotale >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                if (conti.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Conto Principale',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contoPrincipale?.nome ?? 'Nessun conto',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (contoPrincipale != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '€ ${contoPrincipale!.saldo.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: (contoPrincipale!.saldo ?? 0.0) >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (saldoTotale > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${((contoPrincipale!.saldo ?? 0.0) / saldoTotale * 100).toStringAsFixed(1)}%)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              const SizedBox(width: 4),
                              Tooltip(
                                message: 'Conto con saldo più alto (selezionato automaticamente)',
                                child: Icon(
                                  Icons.info_outline,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Azioni Rapide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.add,
                    label: 'Nuova\nTransazione',
                    color: Colors.green,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.account_balance_wallet,
                    label: 'Aggiungi\nConto',
                    color: Colors.blue,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountsPage(),
                        ),
                      );
                      // Ricarica i dati dopo il ritorno dalla pagina conti
                      _caricaDati();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.category,
                    label: 'Gestisci\nCategorie',
                    color: Colors.purple,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesManagementPage(),
                        ),
                      );
                      // Ricarica i dati dopo il ritorno dalla pagina categorie
                      _caricaDati();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'Vedi Tutte\nTransazioni',
                    color: Colors.orange,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsListPage(),
                        ),
                      );
                      // Ricarica i dati dopo il ritorno dalla lista transazioni
                      _caricaDati();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStats(List<Transazione> transazioni) {
    final now = DateTime.now();
    final inizioMese = DateTime(now.year, now.month, 1);
    final fineMese = DateTime(now.year, now.month + 1, 0);
    
    double entrateMensili = 0.0;
    double usciteMensili = 0.0;
    
    // Filtra le transazioni per escludere i trasferimenti dalle statistiche
    final transazioniPerStatistiche = transazioni.where((t) => t.tipo != 'trasferimento').toList();
    
    // NOTA: I trasferimenti vengono esclusi dalle statistiche di entrate/uscite
    // perché rappresentano solo movimenti interni tra conti, non entrate o uscite reali
    for (var transazione in transazioniPerStatistiche) {
      if ((transazione.data.isAfter(inizioMese) || transazione.data.isAtSameMomentAs(inizioMese)) && 
          (transazione.data.isBefore(fineMese) || transazione.data.isAtSameMomentAs(fineMese))) {
        if (transazione.tipo == 'entrata') {
          entrateMensili += transazione.importo;
        } else if (transazione.tipo == 'uscita') {
          usciteMensili += transazione.importo;
        }
      }
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiche Mensili',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Spese Mensili',
                    value: '€ ${usciteMensili.toStringAsFixed(2)}',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Entrate Mensili',
                    value: '€ ${entrateMensili.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(transazioneService, contoService, categoriaService) {
    final transazioni = transazioneService.transazioni.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ultime Transazioni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsListPage(),
                      ),
                    );
                  },
                  child: const Text('Vedi tutte'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (transazioni.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nessuna transazione',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TransactionsPage(),
                          ),
                        );
                      },
                      child: const Text('Aggiungi Transazione'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: transazioni.map<Widget>((transazione) {
                  return _buildTransazioneItem(transazione, contoService, categoriaService);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransazioneItem(
    Transazione transazione,
    ContoService contoService,
    CategoriaService categoriaService,
  ) {
    final conto = contoService.conti.firstWhere(
      (c) => c.id == transazione.contoId,
      orElse: () => Conto(id: '', nome: 'Conto non trovato', tipo: '', saldo: 0.0, profileId: ''),
    );

    final categoria = transazione.tipo == 'trasferimento' 
        ? Categoria(
            id: '',
            nome: 'Trasf.',
            icona: '0xe5d4',
            coloreIcona: '0xFF2196F3',
            profileId: '',
            sottocategorie: [],
          )
        : categoriaService.categorie.firstWhere(
            (c) => c.id == transazione.categoriaId,
            orElse: () => Categoria(
              id: '',
              nome: 'Categoria non trovata',
              icona: '0xe0b0',
              coloreIcona: '0xFF000000',
              profileId: '',
              sottocategorie: [],
            ),
          );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: ColorUtils.hexToColor(categoria.coloreIcona),
        child: Icon(
                                IconUtils.getIconFromName(categoria.icona),
          color: Colors.white,
          size: 16,
        ),
      ),
      title: Text(
        transazione.titolo,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        transazione.tipo == 'trasferimento' 
            ? '${conto.nome} → ${_getContoDestinazione(transazione, contoService)?.nome ?? 'Conto non trovato'}'
            : conto.nome,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '€ ${transazione.importo.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: transazione.tipo == 'entrata' ? Colors.green : 
                     transazione.tipo == 'trasferimento' ? Colors.blue : Colors.red,
            ),
          ),
          Text(
            '${transazione.data.day.toString().padLeft(2, '0')}/${transazione.data.month.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Conto? _getContoDestinazione(Transazione transazione, ContoService contoService) {
    if (transazione.contoDestinazioneId == null) return null;
    return contoService.conti.firstWhere(
      (c) => c.id == transazione.contoDestinazioneId,
      orElse: () => Conto(id: '', nome: 'Conto non trovato', tipo: '', saldo: 0.0, profileId: ''),
    );
  }

  Widget _buildTopCategories(List<Categoria> categorie) {
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categorie',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${categorie.length} categorie',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categorie.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nessuna categoria',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoriesManagementPage(),
                          ),
                        );
                        // Ricarica i dati dopo il ritorno dalla pagina categorie
                        _caricaDati();
                      },
                      child: const Text('Aggiungi una categoria'),
                    ),
                  ],
                ),
              )
            else
              ...categorie.take(3).map<Widget>((categoria) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ColorUtils.hexToColor(categoria.coloreIcona),
                    child: Icon(
                      IconUtils.getIconFromName(categoria.icona),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(categoria.nome),
                  subtitle: Text('${categoria.sottocategorie.length} sottocategorie'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesManagementPage(),
                      ),
                    );
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoals(List<ObiettivoRisparmio> obiettivi) {
    final obiettiviInCorso = obiettivi.where((o) => !o.isCompletato).take(3).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Obiettivi di Risparmio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavingsGoalsPage(),
                      ),
                    );
                  },
                  child: const Text('Vedi tutti'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (obiettiviInCorso.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nessun obiettivo attivo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavingsGoalsPage(),
                          ),
                        );
                      },
                      child: const Text('Crea Obiettivo'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: obiettiviInCorso.map<Widget>((obiettivo) {
                  return _buildObiettivoItem(obiettivo);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObiettivoItem(ObiettivoRisparmio obiettivo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorUtils.hexToColor(obiettivo.coloreIcona),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              ObiettivoRisparmio.getIconData(obiettivo.icona),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obiettivo.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: obiettivo.percentualeCompletamento / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  '€ ${obiettivo.importoAttuale.toStringAsFixed(2)} di € ${obiettivo.importoTarget.toStringAsFixed(2)} (${obiettivo.percentualeCompletamento.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showAllocationDialog(context, obiettivo),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: 'Alloca budget',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  void _showAllocationDialog(BuildContext context, ObiettivoRisparmio obiettivo) {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alloca Budget - ${obiettivo.nome}'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Obiettivo: €${obiettivo.importoAttuale.toStringAsFixed(2)} di €${obiettivo.importoTarget.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Importo da allocare',
                      prefixText: '€',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un importo';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Inserisci un importo valido';
                      }
                      if (amount > obiettivo.importoTarget - obiettivo.importoAttuale) {
                        return 'Importo supera il target rimanente';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  
                  try {
                    // Accedi al servizio degli obiettivi
                    final obiettivoService = Provider.of<ObiettivoRisparmioService>(context, listen: false);
                    
                    // Alloca il budget all'obiettivo
                    final success = await obiettivoService.aggiungiImporto(
                      obiettivoId: obiettivo.id,
                      importo: amount,
                    );
                    
                    Navigator.of(context).pop();
                    
                    if (success) {
                      // Mostra conferma
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Budget di €${amount.toStringAsFixed(2)} allocato a ${obiettivo.nome}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Ricarica i dati per aggiornare l'UI
                      _caricaDati();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Errore durante l\'allocazione: ${obiettivoService.error}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore durante l\'allocazione: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Alloca'),
            ),
          ],
        );
      },
    );
  }
}
