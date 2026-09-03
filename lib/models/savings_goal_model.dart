enum GoalStatus { active, completed, cancelled }

class SavingsGoalModel {
  final String id;
  final String? userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final GoalStatus status;
  final String? icon;

  SavingsGoalModel({
    required this.id,
    this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    DateTime? targetDate,
    DateTime? deadline,
    this.status = GoalStatus.active,
    this.icon,
  }) : targetDate = targetDate ?? deadline ?? DateTime.now();

  DateTime get deadline => targetDate;

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : (json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now()),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      icon: json['icon'],
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
      'deadline': targetDate.toIso8601String(),
      'status': status.name,
      'icon': icon,
    };
  }
}
