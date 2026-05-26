class CalcService {
  static double parseBR(String valor) {
    if (valor.trim().isEmpty) return 0;
    return double.tryParse(valor.trim().replaceAll(',', '.')) ?? 0;
  }

  static String formatBR(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  static double calcATR(double brix) => 7.6427 * brix - 10.109;

  static String interpretarATR(double atr) {
    if (atr < 100) return 'Baixo — cana imatura';
    if (atr <= 140) return 'Normal';
    return 'Excelente';
  }

  static double calcIM(double ponta, double base) {
    if (base == 0) return 0;
    return ponta / base;
  }

  static String interpretarIM(double im) {
    if (im < 0.85) return 'Imaturo — aguardar colheita';
    if (im <= 1.0) return 'Maturação adequada — colher';
    return 'Sobre-maduro — colher urgente';
  }

  static double calcPool(double brix) => 1.0179 * brix - 3.0614;

  static double calcTCHDireto(double cm, double pc, double ml) =>
      (cm * pc * ml) / 1000;

  static double calcTCHIndireto(double d, double cm, double cc, double e) {
    if (e == 0) return 0;
    return (0.7854 * (d / 100) * (d / 100) * cc * cm * 10000) / e;
  }

  static double calcTAH(double tch, double atr) => tch * (atr / 1000);
}
