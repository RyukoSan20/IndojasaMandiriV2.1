class SavingsContribution {
  final String id;
  final double amount;
  final DateTime date;
  final String? note;

  SavingsContribution({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory SavingsContribution.fromJson(Map<String, dynamic> json) {
    return SavingsContribution(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) ?? DateTime.now() : DateTime.now(),
      note: json['note'] as String?,
    );
  }
}

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final List<SavingsContribution> contributions;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    List<SavingsContribution>? contributions,
  }) : contributions = contributions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'contributions': contributions.map((c) => c.toJson()).toList(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    var rawList = json['contributions'] as List?;
    List<SavingsContribution> parsedContributions = [];
    if (rawList != null) {
      parsedContributions = rawList
          .map((item) => SavingsContribution.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return SavingsGoal(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      contributions: parsedContributions,
    );
  }
}
