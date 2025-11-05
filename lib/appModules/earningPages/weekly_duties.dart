import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/earningPages/earnings_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class WeeklyDuties extends GetView<EarningsController> {
  final String userId;
  const WeeklyDuties({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xff0E0E0E),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverAppBar(
              title: Text('Weekly Duties',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
            ),
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              backgroundColor: const Color(0xff121212),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 24),
                          onPressed: () =>
                              controller.previousWeek(userId: userId),
                        ),
                        Text(
                          controller.getWeekRange(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, size: 24),
                          onPressed: DateTime.now()
                                      .difference(controller.weekStart.value)
                                      .inDays <
                                  7
                              ? null
                              : () => controller.nextWeek(userId: userId),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: Obx(() {
            if (controller.isDutyLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (controller.duties.isEmpty) {
              return const Center(
                child: Text(
                  'No duties found for this week',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: controller.duties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final duty = controller.duties[index];
                double balance = ((duty.totalEarnings! - duty.otherFees!)) -
                    duty.vehicleRent! -
                    duty.fuelExpense!;
                final dutyDate =
                    DateTime.fromMillisecondsSinceEpoch(duty.endTime!);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                      iconColor: Colors.white54,
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      tapBodyToExpand: true,
                      hasIcon: false,
                      tapBodyToCollapse: true,
                    ),
                    header: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 55,
                        decoration: BoxDecoration(
                          color: ColorConst.secondaryButton,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('E').format(dutyDate),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            Text(
                              DateFormat('d').format(dutyDate),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        duty.vehicleNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(duty.startTime))} → ${DateFormat.jm().format(dutyDate)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹ ${balance.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: balance < 0
                                  ? Colors.redAccent
                                  : Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            duty.selectedShift > 1
                                ? '${duty.selectedShift} Shifts'
                                : '1 Shift',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54),
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
                              label: 'Total fair',
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
                          CustomWidgets().textRow(
                              label: 'Fuel expense',
                              value:
                                  "-${duty.fuelExpense!.toStringAsFixed(2)}"),
                          const Divider(color: Colors.white24),
                          _infoRow(
                            duty.totaltoPay! < 0 ? 'TO PAY' : 'TO GET',
                            '₹ ${duty.totaltoPay!.toStringAsFixed(2)}',
                            valueColor: duty.totaltoPay! < 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white60)),
          Text(value,
              style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.white)),
        ],
      ),
    );
  }
}
