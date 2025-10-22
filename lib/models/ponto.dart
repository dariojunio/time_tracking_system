class Ponto {
  final String cracha;
  final String data;
  final String horario;
  final String linhaOriginal;

  Ponto({
    required this.cracha,
    required this.data,
    required this.horario,
    required this.linhaOriginal,
  });

  factory Ponto.fromLinha(String linha) {
    if (linha.length != 24) {
      throw Exception('Linha inválida: deve ter 24 caracteres');
    }

    final cracha = linha.substring(0, 10);
    final dia = linha.substring(10, 12);
    final mes = linha.substring(12, 14);
    final ano = linha.substring(14, 16);
    final horario = linha.substring(16, 20);
    final data = '$dia/$mes/20$ano';

    return Ponto(
      cracha: cracha,
      data: data,
      horario: horario,
      linhaOriginal: linha,
    );
  }

  String get horaFormatada {
    final hora = horario.substring(0, 2);
    final minuto = horario.substring(2, 4);
    return '$hora:$minuto';
  }

  @override
  String toString() {
    return 'Ponto(cracha: $cracha, data: $data, horario: $horaFormatada)';
  }
}
