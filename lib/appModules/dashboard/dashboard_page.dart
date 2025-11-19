import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dutyPages/add_duty.dart';
import 'package:zero/appModules/dashboard/dashboard_controller.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController dashboardController = Get.isRegistered()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());
  final TransactionController transactionController = Get.isRegistered()
      ? Get.find<TransactionController>()
      : Get.put(TransactionController());

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    transactionController.fetchTransactions(
        weekStart: dashboardController.weekStart.value);
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: Obx(
        () {
          if (DateTime.now()
                  .difference(dashboardController.weekStart.value)
                  .inDays >
              7) {
            return const SizedBox.shrink();
          }
          return AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: dashboardController.isFabVisible.value
                ? Offset.zero
                : const Offset(0, 2),
            child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: dashboardController.isFabVisible.value ? 1 : 0,
                child: FloatingActionButton(
                  onPressed: () => Get.to(() => AddDutyPage()),
                  child: const Icon(Icons.add),
                )),
          );
        },
      ),
      appBar: AppBar(
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
                    onPressed: dashboardController.previousWeek),
                Text(dashboardController.getWeekRange()),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  onPressed: dashboardController.nextWeek,
                  color: DateTime.now()
                              .difference(dashboardController.weekStart.value)
                              .inDays <
                          7
                      ? Colors.grey
                      : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        double totalCashReceived = transactionController.totalPaid.value;
        double pendingCash = transactionController.totalPaid.value +
            dashboardController.toPay.value;
        if (dashboardController.isDutyLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return RefreshIndicator(
          onRefresh: () async => await dashboardController.fetchWeeklyDuties(),
          color: ColorConst.primaryColor,
          child: SingleChildScrollView(
            controller: dashboardController.scrollController,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                          value: totalCashReceived.toStringAsFixed(2),
                          title: 'Cash received',
                          subtitle: 'Total cash received',
                          color: Colors.green),
                    ),
                    Expanded(
                      child: _statCard(
                          value: pendingCash.toStringAsFixed(2),
                          title:
                              pendingCash > 0 ? 'Drivers\' online' : 'Pending',
                          subtitle: pendingCash > 0
                              ? 'Cash in drivers\' online'
                              : 'Drivers to pay',
                          color: pendingCash < 0 ? Colors.red : Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _incomeBreakdown(),
                const SizedBox(height: 10),
                _rentBreakdown(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _statCard(
      {required String title,
      required String value,
      required Color color,
      required String subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(value,
                style: Get.textTheme.headlineSmall!.copyWith(color: color)),
            const SizedBox(height: 5),
            Text(title, style: Get.textTheme.bodyLarge!),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomeBreakdown() {
    double onlineAmount = (dashboardController.totalEarnings.value -
            dashboardController.otherFees.value) +
        dashboardController.totalToll.value -
        dashboardController.cashCollected.value;
    double totalCashReceived = transactionController.totalPaid.value;
    double totalRevenue = dashboardController.totalRent.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart_sharp),
                    SizedBox(width: 10),
                    Text('Income breakdown'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetails(value: totalCashReceived, label: 'Cash received'),
                _buildDetails(
                    value: onlineAmount,
                    label:
                        onlineAmount >= 0 ? 'Online balance' : 'Cash balance'),
                _buildDetails(value: totalRevenue, label: 'Total revenue'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rentBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up_outlined),
                SizedBox(width: 10),
                Text('Rent Details'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetails(
                    value: (dashboardController.totalEarnings.value -
                        dashboardController.otherFees.value),
                    label: 'Earnings'),
                _buildDetails(
                    value: dashboardController.totalToll.value, label: 'Tolls'),
                _buildDetails(
                    value: dashboardController.cashCollected.value,
                    label: 'Cash collected'),
              ],
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12),
              itemCount: dashboardController.duties.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final duty = dashboardController.duties[index];
                final dutyStart =
                    DateTime.fromMillisecondsSinceEpoch(duty.startTime);
                final dutyEnd =
                    DateTime.fromMillisecondsSinceEpoch(duty.endTime!);

                return ExpandablePanel(
                  theme: const ExpandableThemeData(
                    iconColor: Colors.white54,
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    tapBodyToExpand: true,
                    hasIcon: false,
                    tapBodyToCollapse: true,
                  ),
                  header: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: ColorConst.secondaryButton,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('E').format(dutyStart),
                            style: Get.textTheme.bodyMedium!.copyWith(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('dd').format(dutyStart),
                            style: Get.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      duty.driverName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duty.vehicleNumber,
                          style: Get.textTheme.bodyMedium!.copyWith(),
                        ),
                        Text(
                          "${DateFormat('jm').format(dutyStart)} - ${DateFormat('jm').format(dutyEnd)} • ${duty.selectedShift > 1 ? '${duty.selectedShift} Shifts' : '1 Shift'}",
                          style: Get.textTheme.bodySmall!
                              .copyWith(color: Colors.white54),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹ ${(-duty.totaltoPay!).toStringAsFixed(2)}',
                          // "₹ ${balance.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: duty.totaltoPay! > 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (DateTime.now()
                                .difference(dashboardController.weekStart.value)
                                .inDays <
                            7)
                          GestureDetector(
                            onTap: () =>
                                Get.to(() => AddDutyPage(dutymodel: duty)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.white12)),
                              child: Text(
                                'Edit',
                                style: Get.textTheme.bodySmall!
                                    .copyWith(color: Colors.blue),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      children: [
                        CustomWidgets().textRow(
                            label: 'Total earnings',
                            value: duty.totalEarnings!.toStringAsFixed(2)),
                        CustomWidgets().textRow(
                            label: 'Other fees',
                            value: "-${duty.otherFees!.toStringAsFixed(2)}"),
                        const Divider(color: Colors.white24),
                        CustomWidgets().textRow(
                            label: 'Toll',
                            value: duty.toll!.toStringAsFixed(2)),
                        CustomWidgets().textRow(
                            label: 'Cash collected',
                            value:
                                "-${duty.cashCollected!.toStringAsFixed(2)}"),
                        CustomWidgets().textRow(
                            label: 'Vehicle rent',
                            value: "-${duty.vehicleRent.toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetails({required num value, required String label}) {
    return Column(
      children: [
        Text(value.toStringAsFixed(2)),
        const SizedBox(height: 10),
        Text(
          label,
          style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
