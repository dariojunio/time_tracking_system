import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/funcionario.dart';
import '../models/ponto.dart';
import '../services/ponto_service.dart';

class CorrecaoScreen extends StatefulWidget {
  final Funcionario funcionario;

  const CorrecaoScreen({super.key, required this.funcionario});

  @override
  State<CorrecaoScreen> createState() => _CorrecaoScreenState();
}

class _CorrecaoScreenState extends State<CorrecaoScreen> {
  final PontoService _pontoService = PontoService();
  final TextEditingController _horarioController = TextEditingController();
  String? _dataSelecionada;
  String? _tipoProblema;

  @override
  void initState() {
    super.initState();
    _dataSelecionada =
        widget.funcionario.problemasComProblemas.isNotEmpty
            ? widget.funcionario.problemasComProblemas.first.data
            : null;
  }

  @override
  void dispose() {
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Correção - Crachá: ${widget.funcionario.cracha}',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildSelecaoDataCard(),
            if (_dataSelecionada != null) ...[
              const SizedBox(height: 20),
              _buildCorrecaoCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            const Icon(Icons.edit, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Correção de Pontos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione ou remova pontos para corrigir os problemas encontrados',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelecaoDataCard() {
    final problemas = widget.funcionario.problemasComProblemas;

    if (problemas.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green.shade600),
              const SizedBox(height: 16),
              const Text(
                'Nenhum Problema Encontrado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este funcionário não possui problemas de pontos para corrigir.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecionar Data para Correção',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _dataSelecionada,
              decoration: const InputDecoration(
                labelText: 'Data com problemas',
                border: OutlineInputBorder(),
              ),
              items:
                  problemas.map((problema) {
                    return DropdownMenuItem(
                      value: problema.data,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(problema.data),
                          Text(
                            problema.descricao,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _dataSelecionada = value;
                  _tipoProblema = null;
                  _horarioController.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrecaoCard() {
    if (_dataSelecionada == null) return const SizedBox.shrink();

    final problema = widget.funcionario.problemas.firstWhere(
      (p) => p.data == _dataSelecionada,
    );
    final pontosExistentes =
        widget.funcionario.pontosPorData[_dataSelecionada] ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Corrigir Data: $_dataSelecionada',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoProblema(problema),
            const SizedBox(height: 20),
            _buildPontosExistentes(pontosExistentes),
            const SizedBox(height: 20),
            _buildAcoesCorrecao(problema),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoProblema(ProblemaPonto problema) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            problema.tipo == TipoProblema.faltando
                ? Colors.orange.shade50
                : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              problema.tipo == TipoProblema.faltando
                  ? Colors.orange.shade200
                  : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                problema.tipo == TipoProblema.faltando
                    ? Icons.remove_circle
                    : Icons.add_circle,
                color:
                    problema.tipo == TipoProblema.faltando
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                problema.descricao,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      problema.tipo == TipoProblema.faltando
                          ? Colors.orange.shade700
                          : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pontos atuais: ${problema.horarios.join(', ')}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPontosExistentes(List<Ponto> pontos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pontos Registrados:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              pontos.map((ponto) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
        ),
      ],
    );
  }

  Widget _buildAcoesCorrecao(ProblemaPonto problema) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (problema.tipo == TipoProblema.faltando) ...[
          const Text(
            'Adicionar Ponto:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _horarioController,
            decoration: const InputDecoration(
              labelText: 'Horário (HHMM)',
              hintText: 'Ex: 0830',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              if (value.length == 4) {
                if (_pontoService.validarHorario(value)) {
                  setState(() {
                    _tipoProblema = 'adicionar';
                  });
                } else {
                  setState(() {
                    _tipoProblema = null;
                  });
                }
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _tipoProblema == 'adicionar' ? _adicionarPonto : null,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Ponto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ] else if (problema.tipo == TipoProblema.excesso) ...[
          const Text(
            'Remover Ponto:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _horarioController,
            decoration: const InputDecoration(
              labelText: 'Horário a remover (HHMM)',
              hintText: 'Ex: 0830',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              if (value.length == 4) {
                final horarioFormatado = _pontoService.formatarHorario(value);
                final existe = problema.horarios.contains(horarioFormatado);
                setState(() {
                  _tipoProblema = existe ? 'remover' : null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _tipoProblema == 'remover' ? _removerPonto : null,
            icon: const Icon(Icons.remove),
            label: const Text('Remover Ponto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }

  void _adicionarPonto() {
    final horario = _horarioController.text;
    if (horario.length == 4 && _pontoService.validarHorario(horario)) {
      // Aqui você implementaria a lógica para adicionar o ponto
      // Por enquanto, apenas mostra uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ponto $horario adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _horarioController.clear();
    }
  }

  void _removerPonto() {
    final horario = _horarioController.text;
    if (horario.length == 4) {
      // Aqui você implementaria a lógica para remover o ponto
      // Por enquanto, apenas mostra uma mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ponto $horario removido com sucesso!'),
          backgroundColor: Colors.red,
        ),
      );
      _horarioController.clear();
    }
  }
}
