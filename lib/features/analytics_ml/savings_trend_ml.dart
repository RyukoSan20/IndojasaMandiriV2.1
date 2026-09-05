import 'dart:math';

class SavingsTrendAnalysis {
  final double averageDailySavings;
  final int estimatedDaysToGoal;
  final DateTime projectedCompletionDate;
  final String trendStatus; // 'Accelerating', 'Steady', 'Slow'
  final String recommendation;

  SavingsTrendAnalysis({
    required this.averageDailySavings,
    required this.estimatedDaysToGoal,
    required this.projectedCompletionDate,
    required this.trendStatus,
    required this.recommendation,
  });
}

class SavingsTrendML {
  // Analisis Tren dan Prediksi Waktu Pencapaian Target Tabungan
  static SavingsTrendAnalysis analyzeTrend({
    required double targetAmount,
    required double currentAmount,
    required List<Map<String, dynamic>> savingsHistory,
  }) {
    final double remainingAmount = max(0.0, targetAmount - currentAmount);

    if (savingsHistory.isEmpty || remainingAmount <= 0) {
      return SavingsTrendAnalysis(
        averageDailySavings: 0,
        estimatedDaysToGoal: 0,
        projectedCompletionDate: DateTime.now(),
        trendStatus: remainingAmount <= 0 ? 'Completed' : 'No Data',
        recommendation: remainingAmount <= 0
            ? 'Selamat! Target tabungan Anda sudah tercapai.'
            : 'Belum ada riwayat simpanan untuk dianalisis.',
      );
    }

    // Urutkan histori berdasarkan tanggal
    savingsHistory.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    double totalSavedInWindow = 0.0;
    for (var entry in savingsHistory) {
      totalSavedInWindow += (entry['amount'] as num).toDouble();
    }

    final DateTime startDate = DateTime.parse(savingsHistory.first['date']);
    final DateTime endDate = DateTime.parse(savingsHistory.last['date']);
    int daysDiff = endDate.difference(startDate).inDays;
    if (daysDiff < 1) daysDiff = 1;

    final double avgDaily = totalSavedInWindow / daysDiff;

    if (avgDaily <= 0) {
      return SavingsTrendAnalysis(
        averageDailySavings: 0,
        estimatedDaysToGoal: -1,
        projectedCompletionDate: DateTime.now(),
        trendStatus: 'Slow',
        recommendation: 'Tingkatkan frekuensi simpanan Anda agar target terkejar.',
      );
    }

    final int daysNeeded = (remainingAmount / avgDaily).ceil();
    final DateTime targetDate = DateTime.now().add(Duration(days: daysNeeded));

    String status = 'Steady';
    String advise = 'Pola konsisten! Pertahankan laju simpanan saat ini.';

    if (avgDaily > (targetAmount / 90)) {
      status = 'Accelerating';
      advise = 'Luar biasa! Laju simpanan Anda sangat cepat melampaui estimasi.';
    } else if (daysNeeded > 365) {
      status = 'Slow';
      advise = 'Coba alokasikan 5% ekstra dari kebutuhan konsumtif ke tabungan ini.';
    }

    return SavingsTrendAnalysis(
      averageDailySavings: avgDaily,
      estimatedDaysToGoal: daysNeeded,
      projectedCompletionDate: targetDate,
      trendStatus: status,
      recommendation: advise,
    );
  }
}
