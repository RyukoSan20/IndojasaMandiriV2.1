class SavingsPrediction {
  final double dailyVelocity;
  final int estimatedDaysToTarget;
  final DateTime projectedCompletionDate;
  final String insightMessage;

  SavingsPrediction({
    required this.dailyVelocity,
    required this.estimatedDaysToTarget,
    required this.projectedCompletionDate,
    required this.insightMessage,
  });
}

class TrendAnalyzerService {
  static SavingsPrediction analyzeGoal({
    required double targetAmount,
    required double currentAmount,
    required List<double> monthlySavingsHistory,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) {
      return SavingsPrediction(
        dailyVelocity: 0,
        estimatedDaysToTarget: 0,
        projectedCompletionDate: DateTime.now(),
        insightMessage: 'Target tabungan telah tercapai.',
      );
    }

    double avgMonthly = monthlySavingsHistory.isEmpty
        ? 0.0
        : monthlySavingsHistory.reduce((a, b) => a + b) / monthlySavingsHistory.length;
    double dailyVelocity = avgMonthly / 30.0;

    if (dailyVelocity <= 0) {
      return SavingsPrediction(
        dailyVelocity: 0,
        estimatedDaysToTarget: -1,
        projectedCompletionDate: DateTime.now(),
        insightMessage: 'Pola menabung belum terdeteksi. Silakan alokasikan transaksi awal.',
      );
    }

    int daysRequired = (remaining / dailyVelocity).ceil();
    DateTime completionDate = DateTime.now().add(Duration(days: daysRequired));

    return SavingsPrediction(
      dailyVelocity: dailyVelocity,
      estimatedDaysToTarget: daysRequired,
      projectedCompletionDate: completionDate,
      insightMessage: 'Berdasarkan kecepatan menabung Anda, target ini diprediksi tercapai pada ${completionDate.day}/${completionDate.month}/${completionDate.year}.',
    );
  }
}
