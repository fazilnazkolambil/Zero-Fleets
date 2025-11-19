// import 'package:expandable/expandable.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:zero/appModules/dashboard/dashboard_controller.dart';
// import 'package:zero/core/const_page.dart';
// import 'package:zero/core/global_variables.dart';

// class DutiesPage extends StatelessWidget {
//   final DashboardController controller = Get.isRegistered()
//       ? Get.find<DashboardController>()
//       : Get.put(DashboardController());
//   DutiesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xff0E0E0E),
//         body: NestedScrollView(
//           headerSliverBuilder: (context, innerBoxIsScrolled) => [
//             const SliverAppBar(
//               title: Text('Weekly Duties',
//                   style: TextStyle(fontWeight: FontWeight.w600)),
//               toolbarHeight: 48,
//               backgroundColor: Colors.transparent,
//               centerTitle: true,
//               elevation: 0,
//             ),
//             SliverAppBar(
//               automaticallyImplyLeading: false,
//               pinned: true,
//               backgroundColor: const Color(0xff121212),
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   alignment: Alignment.center,
//                   child: Obx(
//                     () => Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.chevron_left, size: 24),
//                           onPressed: controller.previousWeek,
//                         ),
//                         Text(
//                           controller.getWeekRange(),
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.chevron_right, size: 24),
//                           onPressed: DateTime.now()
//                                       .difference(controller.weekStart.value)
//                                       .inDays <
//                                   7
//                               ? null
//                               : controller.nextWeek,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//           body: Obx(() {
//             if (controller.isDutyLoading.value) {
//               return const Center(child: CupertinoActivityIndicator());
//             }
//             if (controller.duties.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'No duties found for this week',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               );
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.all(12),
//               itemCount: controller.duties.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 10),
//               itemBuilder: (context, index) {
//                 final duty = controller.duties[index];
//                 final dutyStart =
//                     DateTime.fromMillisecondsSinceEpoch(duty.startTime);
//                 final dutyEnd =
//                     DateTime.fromMillisecondsSinceEpoch(duty.endTime!);

//                 return Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white10,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.white12),
//                   ),
//                   child: ExpandablePanel(
//                     theme: const ExpandableThemeData(
//                       iconColor: Colors.white54,
//                       headerAlignment: ExpandablePanelHeaderAlignment.center,
//                       tapBodyToExpand: true,
//                       hasIcon: false,
//                       tapBodyToCollapse: true,
//                     ),
//                     header: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 4),
//                       leading: Container(
//                         width: 50,
//                         decoration: BoxDecoration(
//                           color: ColorConst.secondaryButton,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         alignment: Alignment.center,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               DateFormat('E').format(dutyStart),
//                               style: Get.textTheme.bodyMedium!.copyWith(
//                                   color: Colors.white54,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               DateFormat('dd').format(dutyStart),
//                               style: Get.textTheme.bodySmall,
//                             ),
//                           ],
//                         ),
//                       ),
//                       title: Text(
//                         duty.driverName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             duty.vehicleNumber,
//                             style: Get.textTheme.bodyMedium!.copyWith(),
//                           ),
//                           Text(
//                             "${DateFormat('jm').format(dutyStart)} - ${DateFormat('jm').format(dutyEnd)}",
//                             style: Get.textTheme.bodySmall!
//                                 .copyWith(color: Colors.white54),
//                           ),
//                         ],
//                       ),
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             '₹ ${(-duty.totaltoPay!).toStringAsFixed(2)}',
//                             // "₹ ${balance.toStringAsFixed(2)}",
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: duty.totaltoPay! > 0
//                                   ? Colors.redAccent
//                                   : Colors.greenAccent,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             duty.selectedShift > 1
//                                 ? '${duty.selectedShift} Shifts'
//                                 : '1 Shift',
//                             style: const TextStyle(
//                                 fontSize: 11, color: Colors.white54),
//                           ),
//                         ],
//                       ),
//                     ),
//                     collapsed: const SizedBox.shrink(),
//                     expanded: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                       child: Column(
//                         children: [
//                           CustomWidgets().textRow(
//                               label: 'Total earnings',
//                               value: duty.totalEarnings!.toStringAsFixed(2)),
//                           CustomWidgets().textRow(
//                               label: 'Other fees',
//                               value: "-${duty.otherFees!.toStringAsFixed(2)}"),
//                           const Divider(color: Colors.white24),
//                           CustomWidgets().textRow(
//                               label: 'Toll',
//                               value: duty.toll!.toStringAsFixed(2)),
//                           CustomWidgets().textRow(
//                               label: 'Cash collected',
//                               value:
//                                   "-${duty.cashCollected!.toStringAsFixed(2)}"),
//                           CustomWidgets().textRow(
//                               label: 'Vehicle rent',
//                               value: "-${duty.vehicleRent.toStringAsFixed(2)}"),
//                           // CustomWidgets().textRow(
//                           //     label: 'Fuel expense',
//                           //     value:
//                           //         "-${duty.fuelExpense!.toStringAsFixed(2)}"),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
