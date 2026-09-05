class FinancialAllocationResult {
  final double needsAmount;      // 50% Kebutuhan Pokok
  final double wantsAmount;      // 5% Konsumtif
  final double investmentAmount; // 30% Investasi
  final double emergencyAmount;  // 15% Dana Darurat

  FinancialAllocationResult({
    required this.needsAmount,
    required this.wantsAmount,
    required this.investmentAmount,
    required this.emergencyAmount,
  });

  Map<String, double> toMap() {
    return {
      'needs': needsAmount,
      'wants': wantsAmount,
      'investment': investmentAmount,
      'emergency': emergencyAmount,
    };
  }
}

class FinancialAllocationEngine {
  // Hitung alokasi bawaan (50/5/30/15)
  static FinancialAllocationResult calculateDefaultAllocation(double totalIncome) {
    return calculateCustomAllocation(
      totalIncome: totalIncome,
      needsRatio: 0.50,
      wantsRatio: 0.05,
      investmentRatio: 0.30,
      emergencyRatio: 0.15,
    );
  }

  // Hitung alokasi kustom sesuai input persentase dari user
  static FinancialAllocationResult calculateCustomAllocation({
    required double totalIncome,
    required double needsRatio,
    required double wantsRatio,
    required double investmentRatio,
    required double emergencyRatio,
  }) {
    final totalRatio = needsRatio + wantsRatio + investmentRatio + emergencyRatio;
    if ((totalRatio - 1.0).abs() > 0.001 && totalRatio > 0) {
      // Normalisasi rasio jika total persentase tidak pas 100%
      needsRatio /= totalRatio;
      wantsRatio /= totalRatio;
      investmentRatio /= totalRatio;
      emergencyRatio /= totalRatio;
    }

    return FinancialAllocationResult(
      needsAmount: totalIncome * needsRatio,
      wantsAmount: totalIncome * wantsRatio,
      investmentAmount: totalIncome * investmentRatio,
      emergencyAmount: totalIncome * emergencyRatio,
    );
  }
}
