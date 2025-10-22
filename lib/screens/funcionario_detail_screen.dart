import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/funcionario.dart';
import '../models/ponto.dart';
import 'correcao_screen.dart';

class FuncionarioDetailScreen extends StatefulWidget {
  final Funcionario funcionario;

  const FuncionarioDetailScreen({super.key, required this.funcionario});

  @override
  State<FuncionarioDetailScreen> createState() =>
      _FuncionarioDetailScreenState();
}

class _FuncionarioDetailScreenState extends State<FuncionarioDetailScreen> {
  String _filtroData = 'todos'; // 'todos', 'com_problemas', 'sem_problemas'

  List<MapEntry<String, List<Ponto>>> get _pontosFiltrados {
    List<MapEntry<String, List<Ponto>>> pontos =
        widget.funcionario.pontosPorData.entries.toList();

    // Ordenar por data (mais recente primeiro)
    pontos.sort((a, b) => _parseData(b.key).compareTo(_parseData(a.key)));

    switch (_filtroData) {
      case 'com_problemas':
        pontos =
            pontos.where((entry) {
              final data = entry.key;
              final problema = widget.funcionario.problemas.firstWhere(
                (p) => p.data == data,
                orElse:
                    () => ProblemaPonto(
                      data: data,
                      tipo: TipoProblema.correto,
                      horarios: [],
                      quantidadeEsperada: 4,
                      quantidadeAtual: entry.value.length,
                    ),
              );
              return problema.tipo != TipoProblema.correto;
            }).toList();
        break;
      case 'sem_problemas':
        pontos =
            pontos.where((entry) {
              final data = entry.key;
              final problema = widget.funcionario.problemas.firstWhere(
                (p) => p.data == data,
                orElse:
                    () => ProblemaPonto(
                      data: data,
                      tipo: TipoProblema.correto,
                      horarios: [],
                      quantidadeEsperada: 4,
                      quantidadeAtual: entry.value.length,
                    ),
              );
              return problema.tipo == TipoProblema.correto;
            }).toList();
        break;
    }

    return pontos;
  }

  DateTime _parseData(String data) {
    final partes = data.split('/');
    return DateTime(
      int.parse('20${partes[2]}'),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  String _formatarData(String data) {
    final date = _parseData(data);
    return DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Crachá: ${widget.funcionario.cracha}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
        actions: [
          if (widget.funcionario.totalProblemas > 0)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CorrecaoScreen(funcionario: widget.funcionario),
                  ),
                );
              },
              tooltip: 'Corrigir Pontos',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildResumoCard(),
          _buildFiltrosCard(),
          Expanded(child: _buildPontosList()),
        ],
      ),
    );
  }

  Widget _buildResumoCard() {
    final totalDias = widget.funcionario.pontosPorData.length;
    final diasComProblemas = widget.funcionario.problemasComProblemas.length;
    final totalProblemas = widget.funcionario.totalProblemas;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Resumo do Funcionário',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildResumoItem(
                      'Total de Dias',
                      totalDias.toString(),
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildResumoItem(
                      'Dias com Problemas',
                      diasComProblemas.toString(),
                      Icons.warning,
                    ),
                  ),
                  Expanded(
                    child: _buildResumoItem(
                      'Total de Problemas',
                      totalProblemas.toString(),
                      Icons.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFiltrosCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Text(
              'Filtrar por:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: _filtroData,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'todos',
                    child: Text('Todos os dias'),
                  ),
                  DropdownMenuItem(
                    value: 'com_problemas',
                    child: Text('Dias com problemas'),
                  ),
                  DropdownMenuItem(
                    value: 'sem_problemas',
                    child: Text('Dias sem problemas'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _filtroData = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPontosList() {
    final pontos = _pontosFiltrados;

    if (pontos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _filtroData == 'com_problemas'
                  ? 'Nenhum dia com problemas encontrado'
                  : _filtroData == 'sem_problemas'
                  ? 'Nenhum dia sem problemas encontrado'
                  : 'Nenhum ponto registrado',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: pontos.length,
      itemBuilder: (context, index) {
        final entry = pontos[index];
        final data = entry.key;
        final pontosDoDia = entry.value;
        final problema = widget.funcionario.problemas.firstWhere(
          (p) => p.data == data,
          orElse:
              () => ProblemaPonto(
                data: data,
                tipo: TipoProblema.correto,
                horarios: pontosDoDia.map((p) => p.horaFormatada).toList(),
                quantidadeEsperada: 4,
                quantidadeAtual: pontosDoDia.length,
              ),
        );

        return _buildDiaCard(data, pontosDoDia, problema);
      },
    );
  }

  Widget _buildDiaCard(
    String data,
    List<Ponto> pontos,
    ProblemaPonto problema,
  ) {
    final temProblema = problema.tipo != TipoProblema.correto;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            temProblema
                ? BorderSide(color: Colors.red.shade300, width: 2)
                : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  temProblema ? Icons.warning : Icons.check_circle,
                  color:
                      temProblema ? Colors.red.shade600 : Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatarData(data),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pontos.length} ponto(s) registrado(s)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (temProblema)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      problema.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (temProblema) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      problema.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pontos registrados: ${problema.horarios.join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildPontosChips(pontos),
          ],
        ),
      ),
    );
  }

  Widget _buildPontosChips(List<Ponto> pontos) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          pontos.map((ponto) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ponto.horaFormatada,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
