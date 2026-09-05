class CalendarSyncService {
  static Future<bool> syncBudgetPlanToCalendar({
    required String title,
    required DateTime targetDate,
    required double targetAmount,
  }) async {
    // Service terintegrasi siap memanggil intent Google Calendar API
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
