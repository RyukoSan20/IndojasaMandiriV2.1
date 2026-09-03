enum GoalStatus { active, completed, cancelled }

class SavingsGoalModel {
  final String id;
  final String? userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final GoalStatus status;

  SavingsGoalModel({
    required this.id,
    this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    this.status = GoalStatus.active,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : DateTime.now(),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'status': status.name,
    };
  }
}
