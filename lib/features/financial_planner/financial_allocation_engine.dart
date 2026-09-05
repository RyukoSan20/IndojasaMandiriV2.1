class AllocationResult {
  final double needs;      // 50% Kebutuhan Pokok
  final double wants;      // 5% Konsumtif
  final double investment; // 30% Investasi
  final double emergency;  // 15% Dana Darurat

  AllocationResult({
    required this.needs,
    required this.wants,
    required this.investment,
    required this.emergency,
  });

  factory AllocationResult.calculateStandard(double initialAmount) {
    return AllocationResult(
      needs: initialAmount * 0.50,
      wants: initialAmount * 0.05,
      investment: initialAmount * 0.30,
      emergency: initialAmount * 0.15,
    );
  }

  factory AllocationResult.calculateCustom(
    double initialAmount, {
    required double needsRatio,
    required double wantsRatio,
    required double investRatio,
    required double emergencyRatio,
  }) {
    return AllocationResult(
      needs: initialAmount * needsRatio,
      wants: initialAmount * wantsRatio,
      investment: initialAmount * investRatio,
      emergency: initialAmount * emergencyRatio,
    );
  }
}
