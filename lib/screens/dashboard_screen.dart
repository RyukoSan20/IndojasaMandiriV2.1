import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, dynamic> _dashboardData = {
    'totalBalance': 28000000,
    'monthlyIncome': 10000000,
    'monthlyExpense': 3500000,
  };
  
  int _selectedPeriodIndex = 0;

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('No new notifications at this time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('App settings and preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _buildPortfolioSummary();
      case 1:
        return _buildSavingsGoals();
      case 2:
        return _buildFinancialInsights();
      default:
        return const Center(child: Text('Tab content unavailable'));
    }
  }

  Widget _buildPortfolioSummary() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Portfolio Summary Overview'),
        ),
      ),
    );
  }

  Widget _buildSavingsGoals() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Savings Goals Progress'),
        ),
      ),
    );
  }

  Widget _buildFinancialInsights() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Financial Insights & Analytics'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotificationsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Balance: Rp ${_dashboardData['totalBalance']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                bool isSelected = _selectedPeriodIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text('Period $index'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodIndex = index;
                      });
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            _buildTabContent(_selectedPeriodIndex),
          ],
        ),
      ),
    );
  }
}
