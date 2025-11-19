import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/earningPages/earnings_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zero/appModules/earningPages/weekly_duties.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';

class EarningPage extends StatelessWidget {
  final EarningsController controller = Get.isRegistered()
      ? Get.find<EarningsController>()
      : Get.put(EarningsController());
  final subs = Get.find<SubscriptionsController>();
  final String? userId;
  EarningPage({super.key, this.userId}) {
    controller.fetchWeeklyDuties(userId: userId ?? subs.user.value!.uid);
  }

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _appbar(),
      body: Obx(() {
        if (controller.isDutyLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (controller.duties.isEmpty) {
          return const Center(child: Text('No duties available'));
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              if (subs.user.value?.fleetId != null) tripCompletiontracking(),
              const SizedBox(height: 10),
              _chartView(),
              const SizedBox(height: 20),
              _weeklyStats(),
              const SizedBox(height: 10),
              stateBreakdown(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(w, 45),
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black),
                    onPressed: () => Get.to(() =>
                        WeeklyDuties(userId: userId ?? subs.user.value!.uid)),
                    child: const Text('See weekly activities')),
              )
            ],
          ),
        );
      }),
    );
  }

  AppBar _appbar() {
    return AppBar(
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
          background: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 18,
              ),
              onPressed: () => controller.previousWeek(
                  userId: userId ?? subs.user.value!.uid),
            ),
            Text(controller.getWeekRange()),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 18),
              onPressed:
                  DateTime.now().difference(controller.weekStart.value).inDays <
                          7
                      ? null
                      : () => controller.nextWeek(
                          userId: userId ?? subs.user.value!.uid),
              color: Colors.white,
            ),
          ],
        ),
      )),
    );
  }

  Widget tripCompletiontracking() {
    int targetTrips =
        subs.fleet.value!.targets['driver'] * controller.totalShifts.value;
    final tripCompletion =
        controller.totalTrips.value / (targetTrips > 0 ? targetTrips : 1);
    Color color;
    switch (tripCompletion) {
      case (< 0.2):
        color = Colors.red;
      case (< 0.4):
        color = Colors.deepOrange;
      case (< 0.6):
        color = Colors.orange;
      case (< 0.9):
        color = Colors.amber;
      case (< 1):
        color = Colors.lightGreen;
      default:
        color = Colors.green;
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart),
              SizedBox(width: w * 0.03),
              Text('Trip completion',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: tripCompletion > 1 ? 1 : tripCompletion,
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color
                      // tripCompletion >= 1 ? Colors.green : Colors.red,
                      ),
                ),
              ),
              SizedBox(height: h * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.totalTrips.value.toString()} / ${targetTrips.toString()} trips',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartView() {
    return SizedBox(
      height: h * 0.3,
      width: w,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          gridData: const FlGridData(
            show: false,
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (event is FlTapUpEvent && barTouchResponse?.spot != null) {
                final index = barTouchResponse!.spot!.touchedBarGroupIndex;
                final date =
                    controller.weekStart.value.add(Duration(days: index));
                print('AAAAAAAAAAAAAAAA ==== $date');
              }
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  textAlign: TextAlign.center,
                  '₹ ${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 45,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index > 6) {
                    return const SizedBox.shrink();
                  }
                  final date =
                      controller.weekStart.value.add(Duration(days: index));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('E').format(date),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: controller.getDailyEarnings()[index],
                  color: ColorConst.primaryColor,
                  width: 30,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _weeklyStats() {
    double totalEarnings =
        controller.totalEarnings.value - controller.otherFees.value;
    double balance = totalEarnings -
        controller.totalRent.value -
        controller.fuelExpenses.value;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly stats',
              style: Get.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStaticValues(
                    value: controller.totalShifts.value.toString(),
                    label: 'Total duties'),
                _buildStaticValues(
                    value: controller.totalTrips.value.toString(),
                    label: 'Total trips'),
                _buildStaticValues(
                    value: totalEarnings.toStringAsFixed(2),
                    label: 'Total Earnings'),
              ],
            ),
            const SizedBox(
              height: 45,
              child: Divider(color: Colors.white24),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStaticValues(
                    value: "-${controller.totalRent.value.toStringAsFixed(2)}",
                    label: 'Total rent'),
                _buildStaticValues(
                    value:
                        "-${controller.fuelExpenses.value.toStringAsFixed(2)}",
                    label: 'Fuel expenses'),
                _buildStaticValues(
                    value: balance.toStringAsFixed(2),
                    label: 'Total balance',
                    color: balance <= 0 ? Colors.red : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildStaticValues(
      {required String value, required String label, Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: Get.textTheme.bodyLarge!.copyWith(color: color),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget stateBreakdown() {
    double totalEarnings =
        controller.totalEarnings.value - controller.otherFees.value;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rent details',
              style: Get.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          CustomWidgets().textRow(
              label: 'Your earnings',
              value: '₹ ${controller.totalEarnings.value.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
              label: 'Others fees',
              value: '-${controller.otherFees.value.toStringAsFixed(2)}'),
          const Divider(color: Colors.white24),
          Padding(
            padding: EdgeInsets.all(w * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total earnings',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹ ${totalEarnings.toStringAsFixed(2)}',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          CustomWidgets().textRow(
              label: 'Toll',
              value: '₹ ${controller.totalToll.value.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
              label: 'Cash collected',
              value: '₹ -${controller.cashCollected.value.toStringAsFixed(2)}'),
          CustomWidgets().textRow(
              label: 'Vehicle rent',
              value: '-${controller.totalRent.value.toStringAsFixed(2)}'),
          const Divider(color: Colors.grey),
          Padding(
            padding: EdgeInsets.all(w * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.toPay.value < 0 ? 'TO PAY' : 'TO GET',
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹ ${controller.toPay.value.toStringAsFixed(2)}',
                  style: Get.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: controller.toPay.value < 0
                          ? Colors.red
                          : Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
