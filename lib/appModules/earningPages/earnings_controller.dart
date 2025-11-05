import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/models/duty_model.dart';

class EarningsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var weekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;
  var weekEnd = DateTime.now().obs;

  var duties = <DutyModel>[].obs;

  var totalTrips = 0.obs;
  var totalShifts = 0.obs;
  var totalEarnings = 0.0.obs;
  var totalRent = 0.0.obs;
  var totalToll = 0.0.obs;
  var fuelExpenses = 0.0.obs;
  var cashCollected = 0.0.obs;
  var otherFees = 0.0.obs;
  var toPay = 0.0.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchWeeklyDuties();
  // }

  void previousWeek({required String userId}) {
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    weekEnd.value = weekEnd.value.subtract(const Duration(days: 7));
    fetchWeeklyDuties(userId: userId);
  }

  void nextWeek({required String userId}) {
    if (DateTime.now().difference(weekStart.value).inDays < 7) return;
    weekStart.value = weekStart.value.add(const Duration(days: 7));
    weekEnd.value = weekEnd.value.add(const Duration(days: 7));
    fetchWeeklyDuties(userId: userId);
  }

  String getWeekRange() {
    final format = DateFormat('dd MMM');
    return '${format.format(weekStart.value)} - ${format.format(weekStart.value.add(const Duration(days: 6)))}';
  }

  RxBool isDutyLoading = false.obs;
  Future<void> fetchWeeklyDuties({required String userId}) async {
    final start = DateTime(
        weekStart.value.year, weekStart.value.month, weekStart.value.day);
    final end = start.add(const Duration(days: 7));
    try {
      isDutyLoading.value = true;
      final snapshot = await _firestore
          .collection('duties')
          .where('driver_id', isEqualTo: userId)
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
      isDutyLoading.value = false;
    } catch (e) {
      print('Error fetching duties: $e');
      Fluttertoast.showToast(
          msg: 'Error loading duties', backgroundColor: Colors.red);
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

  List<double> getDailyEarnings() {
    final List<double> dailyTotals = List.filled(7, 0);
    for (var duty in duties) {
      // if (duty.startTime) continue;
      final earning = duty.totalEarnings! - duty.otherFees!;
      double balance = earning - duty.vehicleRent - duty.fuelExpense!;
      final index =
          DateTime.fromMillisecondsSinceEpoch(duty.startTime).weekday - 1;
      dailyTotals[index] += balance;
    }
    return dailyTotals;
  }
}
