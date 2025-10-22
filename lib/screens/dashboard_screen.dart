import 'package:flutter/material.dart';
import '../models/funcionario.dart';
import 'funcionario_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Funcionario> funcionarios;

  const DashboardScreen({super.key, required this.funcionarios});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _filtro = 'todos'; // 'todos', 'com_problemas', 'sem_problemas'
  String _busca = '';

  List<Funcionario> get _funcionariosFiltrados {
    List<Funcionario> funcionarios = widget.funcionarios;

    // Aplicar filtro de problemas
    switch (_filtro) {
      case 'com_problemas':
        funcionarios = funcionarios.where((f) => f.totalProblemas > 0).toList();
        break;
      case 'sem_problemas':
        funcionarios =
            funcionarios.where((f) => f.totalProblemas == 0).toList();
        break;
    }

    // Aplicar busca por crachá
    if (_busca.isNotEmpty) {
      funcionarios =
          funcionarios.where((f) => f.cracha.contains(_busca)).toList();
    }

    return funcionarios;
  }

  @override
  Widget build(BuildContext context) {
    final funcionariosComProblemas =
        widget.funcionarios.where((f) => f.totalProblemas > 0).length;
    final totalFuncionarios = widget.funcionarios.length;
    final totalProblemas = widget.funcionarios.fold(
      0,
      (sum, f) => sum + f.totalProblemas,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Dashboard de Pontos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            tooltip: 'Novo Upload',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _filtro = 'todos';
                _busca = '';
              });
            },
            tooltip: 'Limpar Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCards(
            totalFuncionarios,
            funcionariosComProblemas,
            totalProblemas,
          ),
          _buildFiltersCard(),
          Expanded(child: _buildFuncionariosList()),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
    int totalFuncionarios,
    int funcionariosComProblemas,
    int totalProblemas,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total de Funcionários',
              totalFuncionarios.toString(),
              Icons.people,
              const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Com Problemas',
              funcionariosComProblemas.toString(),
              Icons.warning,
              const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total de Problemas',
              totalProblemas.toString(),
              Icons.error,
              const Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                const Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por crachá...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _busca = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filtro,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(
                      value: 'com_problemas',
                      child: Text('Com Problemas'),
                    ),
                    DropdownMenuItem(
                      value: 'sem_problemas',
                      child: Text('Sem Problemas'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtro = value!;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuncionariosList() {
    final funcionarios = _funcionariosFiltrados;

    if (funcionarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _busca.isNotEmpty ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _busca.isNotEmpty
                  ? 'Nenhum funcionário encontrado para "$_busca"'
                  : 'Nenhum funcionário encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: funcionarios.length,
      itemBuilder: (context, index) {
        final funcionario = funcionarios[index];
        return _buildFuncionarioCard(funcionario);
      },
    );
  }

  Widget _buildFuncionarioCard(Funcionario funcionario) {
    final temProblemas = funcionario.totalProblemas > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      FuncionarioDetailScreen(funcionario: funcionario),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      temProblemas
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  temProblemas ? Icons.warning : Icons.check_circle,
                  color:
                      temProblemas
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crachá: ${funcionario.cracha}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${funcionario.pontosPorData.length} dia(s) registrado(s)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (temProblemas) ...[
                      const SizedBox(height: 4),
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
                          '${funcionario.totalProblemas} problema(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
