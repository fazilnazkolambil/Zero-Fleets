import 'package:flutter/material.dart';
import 'package:zero/appModules/earningPages/earning_page.dart';

class DriverDashboard extends StatelessWidget {
  final String userId;
  final String driverName;
  const DriverDashboard(
      {super.key, required this.userId, required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$driverName\'s Earnings'),
      ),
      body: EarningPage(
        userId: userId,
      ),
    );
  }
}
