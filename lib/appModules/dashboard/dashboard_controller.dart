import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';
import 'package:zero/models/duty_model.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final subs = Get.find<SubscriptionsController>();
  ScrollController scrollController = ScrollController();
  RxBool isFabVisible = true.obs;
  @override
  void onInit() {
    fetchWeeklyDuties();
    scrollController.addListener(() {
      isFabVisible.value = scrollController.position.userScrollDirection ==
          ScrollDirection.forward;
      // scrollController.position.userScrollDirection == ScrollDirection.forward
      //     ? isFabVisible.value = true
      //     : isFabVisible.value = false;
    });
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  var weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;
  DateTime? weekEnd;

  void previousWeek() {
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    Get.put(TransactionController())
        .fetchTransactions(weekStart: weekStart.value);
    fetchWeeklyDuties();
  }

  void nextWeek() {
    if (DateTime.now().difference(weekStart.value).inDays < 7) {
      null;
    } else {
      weekStart.value = weekStart.value.add(const Duration(days: 7));
      fetchWeeklyDuties();
      Get.put(TransactionController())
          .fetchTransactions(weekStart: weekStart.value);
    }
  }

  String getWeekRange() {
    final DateFormat formatter = DateFormat('MMM d');
    final DateTime weekEnd = weekStart.value.add(const Duration(days: 6));
    return '${formatter.format(weekStart.value)} - ${formatter.format(weekEnd)}';
  }

  RxBool isDutyLoading = false.obs;
  RxList<DutyModel> duties = <DutyModel>[].obs;

  var totalTrips = 0.obs;
  var totalShifts = 0.obs;
  var totalEarnings = 0.0.obs;
  var totalRent = 0.0.obs;
  var totalToll = 0.0.obs;
  var fuelExpenses = 0.0.obs;
  var cashCollected = 0.0.obs;
  var otherFees = 0.0.obs;
  var toPay = 0.0.obs;

  Future<void> fetchWeeklyDuties() async {
    final start = DateTime(
        weekStart.value.year, weekStart.value.month, weekStart.value.day);
    final end = start.add(const Duration(days: 7));
    try {
      isDutyLoading.value = true;
      final snapshot = await _firestore
          .collection('duties')
          .where('fleet_id', isEqualTo: subs.user.value!.fleetId)
          .where('duty_status', isEqualTo: 'COMPLETED')
          .where('start_time',
              isGreaterThanOrEqualTo: start.millisecondsSinceEpoch)
          .where('start_time', isLessThan: end.millisecondsSinceEpoch)
          .get();
      duties.value = snapshot.docs
          .map((e) => DutyModel.fromMap(e.data()))
          .toList()
        ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
      calculateTotals();
    } catch (e) {
      log('Error fetching duties: $e');
      Fluttertoast.showToast(
          msg: 'Error loading dashboard duties', backgroundColor: Colors.red);
    } finally {
      isDutyLoading.value = false;
    }
  }

  void calculateTotals() {
    totalTrips.value =
        duties.fold(0, (value, d) => value + (d.totalTrips ?? 0));
    totalShifts.value = duties.fold(0, (value, d) => value + (d.selectedShift));
    totalEarnings.value =
        duties.fold(0.0, (value, d) => value + (d.totalEarnings ?? 0));
    totalRent.value = duties.fold(0.0, (value, d) => value + (d.vehicleRent));
    totalToll.value = duties.fold(0.0, (value, d) => value + (d.toll ?? 0));
    fuelExpenses.value =
        duties.fold(0.0, (value, d) => value + (d.fuelExpense ?? 0));
    cashCollected.value =
        duties.fold(0.0, (value, d) => value + (d.cashCollected ?? 0));
    otherFees.value =
        duties.fold(0.0, (value, d) => value + (d.otherFees ?? 0));
    toPay.value = duties.fold(0.0, (value, d) => value + (d.totaltoPay ?? 0));
  }
}
