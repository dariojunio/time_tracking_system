import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ponto.dart';
import '../models/funcionario.dart';

class PontoService {
  static const int pontosEsperados = 4;
  static const String fixoFim = "0001";

  Future<String?> selecionarArquivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao selecionar arquivo: $e');
    }
  }

  Future<String> salvarArquivoTemporario(String conteudo) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/moviment_temp.txt');
    await file.writeAsString(conteudo);
    return file.path;
  }

  Future<List<Ponto>> processarArquivo(String caminhoArquivo) async {
    try {
      final file = File(caminhoArquivo);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado');
      }

      final conteudo = await file.readAsString();
      final linhas = conteudo.split('\n');
      final pontos = <Ponto>[];

      for (final linha in linhas) {
        final linhaLimpa = linha.trim();
        if (linhaLimpa.isEmpty) continue;
        
        if (linhaLimpa.length != 24) {
          print('Linha inválida ignorada: $linhaLimpa (${linhaLimpa.length} caracteres)');
          continue;
        }

        try {
          final ponto = Ponto.fromLinha(linhaLimpa);
          pontos.add(ponto);
        } catch (e) {
          print('Erro ao processar linha: $linhaLimpa - $e');
        }
      }

      return pontos;
    } catch (e) {
      throw Exception('Erro ao processar arquivo: $e');
    }
  }

  Map<String, List<Ponto>> agruparPontosPorCracha(List<Ponto> pontos) {
    final Map<String, List<Ponto>> pontosPorCracha = {};
    
    for (final ponto in pontos) {
      if (!pontosPorCracha.containsKey(ponto.cracha)) {
        pontosPorCracha[ponto.cracha] = [];
      }
      pontosPorCracha[ponto.cracha]!.add(ponto);
    }

    return pontosPorCracha;
  }

  List<Funcionario> criarFuncionarios(Map<String, List<Ponto>> pontosPorCracha) {
    final funcionarios = <Funcionario>[];

    for (final cracha in pontosPorCracha.keys) {
      final pontos = pontosPorCracha[cracha]!;
      final funcionario = Funcionario.fromPontos(pontos, pontosEsperados: pontosEsperados);
      funcionarios.add(funcionario);
    }

    // Ordenar por crachá
    funcionarios.sort((a, b) => a.cracha.compareTo(b.cracha));
    return funcionarios;
  }

  List<Funcionario> filtrarFuncionariosComProblemas(List<Funcionario> funcionarios) {
    return funcionarios.where((f) => f.totalProblemas > 0).toList();
  }

  String gerarLinhaPonto(String cracha, String data, String horario) {
    // Formato: CRACHA(10) + DIA(2) + MES(2) + ANO(2) + HORARIO(4) + FIXO(4)
    final partes = data.split('/');
    final dia = partes[0].padLeft(2, '0');
    final mes = partes[1].padLeft(2, '0');
    final ano = partes[2].substring(2); // Pega apenas os últimos 2 dígitos do ano
    
    return '${cracha.padLeft(10, '0')}$dia$mes$ano$horario$fixoFim';
  }

  bool validarHorario(String horario) {
    if (horario.length != 4 || !RegExp(r'^\d{4}$').hasMatch(horario)) {
      return false;
    }
    
    final hora = int.tryParse(horario.substring(0, 2));
    final minuto = int.tryParse(horario.substring(2, 4));
    
    return hora != null && minuto != null && 
           hora >= 0 && hora <= 23 && 
           minuto >= 0 && minuto <= 59;
  }

  String formatarHorario(String horario) {
    if (horario.length == 4) {
      return '${horario.substring(0, 2)}:${horario.substring(2, 4)}';
    }
    return horario;
  }
}
