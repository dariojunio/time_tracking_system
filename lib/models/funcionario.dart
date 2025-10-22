import 'ponto.dart';

enum TipoProblema { faltando, excesso, correto }

class ProblemaPonto {
  final String data;
  final TipoProblema tipo;
  final List<String> horarios;
  final int quantidadeEsperada;
  final int quantidadeAtual;

  ProblemaPonto({
    required this.data,
    required this.tipo,
    required this.horarios,
    required this.quantidadeEsperada,
    required this.quantidadeAtual,
  });

  String get descricao {
    switch (tipo) {
      case TipoProblema.faltando:
        return 'Faltam ${quantidadeEsperada - quantidadeAtual} ponto(s)';
      case TipoProblema.excesso:
        return 'Excesso de ${quantidadeAtual - quantidadeEsperada} ponto(s)';
      case TipoProblema.correto:
        return 'Pontos corretos';
    }
  }

  String get status {
    switch (tipo) {
      case TipoProblema.faltando:
        return 'FALTANDO';
      case TipoProblema.excesso:
        return 'EXCESSO';
      case TipoProblema.correto:
        return 'OK';
    }
  }
}

class Funcionario {
  final String cracha;
  final Map<String, List<Ponto>> pontosPorData;
  final List<ProblemaPonto> problemas;

  Funcionario({
    required this.cracha,
    required this.pontosPorData,
    required this.problemas,
  });

  factory Funcionario.fromPontos(List<Ponto> pontos, {int pontosEsperados = 4}) {
    final Map<String, List<Ponto>> pontosPorData = {};
    
    for (final ponto in pontos) {
      if (!pontosPorData.containsKey(ponto.data)) {
        pontosPorData[ponto.data] = [];
      }
      pontosPorData[ponto.data]!.add(ponto);
    }

    // Ordenar pontos por horário em cada data
    for (final data in pontosPorData.keys) {
      pontosPorData[data]!.sort((a, b) => a.horario.compareTo(b.horario));
    }

    final problemas = <ProblemaPonto>[];
    
    for (final data in pontosPorData.keys) {
      final pontosDoDia = pontosPorData[data]!;
      final quantidade = pontosDoDia.length;
      
      TipoProblema tipo;
      if (quantidade < pontosEsperados) {
        tipo = TipoProblema.faltando;
      } else if (quantidade > pontosEsperados) {
        tipo = TipoProblema.excesso;
      } else {
        tipo = TipoProblema.correto;
      }

      problemas.add(ProblemaPonto(
        data: data,
        tipo: tipo,
        horarios: pontosDoDia.map((p) => p.horaFormatada).toList(),
        quantidadeEsperada: pontosEsperados,
        quantidadeAtual: quantidade,
      ));
    }

    return Funcionario(
      cracha: pontos.first.cracha,
      pontosPorData: pontosPorData,
      problemas: problemas,
    );
  }

  List<ProblemaPonto> get problemasComProblemas {
    return problemas.where((p) => p.tipo != TipoProblema.correto).toList();
  }

  int get totalProblemas {
    return problemasComProblemas.length;
  }

  List<String> get datasComProblemas {
    return problemasComProblemas.map((p) => p.data).toList();
  }
}
