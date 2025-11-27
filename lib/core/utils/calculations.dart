class Calculations {
  static double calculateBMI(double weightKg, double heightM) {
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }
}
