import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';
import 'package:zero/models/transaction_model.dart';

class TransactionController extends GetxController {
  final subs = Get.find<SubscriptionsController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;
  var weekEnd = DateTime.now().obs;

  // @override
  // void onInit() {
  //   fetchTransactions(weekStart: weekStart.value);
  //   super.onInit();
  // }

  RxDouble pendingAmount = 0.0.obs;
  RxDouble totalPaid = 0.0.obs;
  RxDouble onlinePaid = 0.0.obs;
  RxDouble offlinePaid = 0.0.obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  RxBool isLoading = false.obs;

  void previousWeek() {
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    weekEnd.value = weekEnd.value.subtract(const Duration(days: 7));
    fetchTransactions(weekStart: weekStart.value);
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart.value).inDays < 7) return;
    weekStart.value = weekStart.value.add(const Duration(days: 7));
    weekEnd.value = weekEnd.value.add(const Duration(days: 7));
    fetchTransactions(weekStart: weekStart.value);
  }

  String getWeekRange() {
    final format = DateFormat('dd MMM');
    return '${format.format(weekStart.value)} - ${format.format(weekStart.value.add(const Duration(days: 6)))}';
  }

  Future<void> fetchTransactions({required DateTime weekStart}) async {
    isLoading.value = true;
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('fleet_id', isEqualTo: subs.user.value!.fleetId)
          .where('payment_time',
              isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
          .where('payment_time', isLessThan: end.millisecondsSinceEpoch)
          .get();
      transactions.value = snapshot.docs
          .map((e) => TransactionModel.fromMap(e.data()))
          .toList()
        ..sort((a, b) => b.paymentTime.compareTo(a.paymentTime));

      pendingAmount.value = _sumBy(transactions, 'PENDING');
      totalPaid.value = _sumBy(transactions, 'ACCEPTED');
      onlinePaid.value = _sumBy(transactions, 'ACCEPTED', filter: 'ONLINE');
      offlinePaid.value = _sumBy(transactions, 'ACCEPTED', filter: 'OFFLINE');
    } catch (e) {
      log("Error fetching transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double _sumBy(List<TransactionModel> txs, String status, {String? filter}) {
    return txs
        .where((t) =>
            (t.status == status) &&
            (filter == null || t.paymentMethod == filter))
        .fold(0.0, (add, t) => add + (t.amount));
  }
}
