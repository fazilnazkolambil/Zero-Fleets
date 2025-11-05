import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/duty_model.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    fetchWeeklyDuties();
    super.onInit();
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
          .where('fleet_id', isEqualTo: currentUser!.fleetId)
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

  // Dropdown lists (fetch these from Firestore or API)
  var drivers = <Map<String, String>>[
    {'id': 'driver1', 'name': 'Driver 1'},
    {'id': 'driver2', 'name': 'Driver 2'},
  ].obs;

  var vehicles = <Map<String, String>>[
    {'id': 'vehicle1', 'number': 'AA11AA1111'},
    {'id': 'vehicle2', 'number': 'BB22BB2222'},
  ].obs;

  var selectedDriver = "".obs;
  var selectedVehicle = "".obs;

  var startTime = Rxn<int>();
  var endTime = Rxn<int>();

  TextEditingController tripsController = TextEditingController();
  TextEditingController earningsController = TextEditingController();
  TextEditingController cashCollectedController = TextEditingController();
  TextEditingController tollController = TextEditingController();
  TextEditingController fuelController = TextEditingController();

  RxBool isSubmitting = false.obs;

  Future<void> pickStartDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    startTime.value = dt.millisecondsSinceEpoch;
  }

  Future<void> pickEndDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    endTime.value = dt.millisecondsSinceEpoch;
  }

  Future<void> submitDuty() async {
    if (selectedDriver.isEmpty || selectedVehicle.isEmpty) {
      Get.snackbar("Missing Info", "Please select driver and vehicle");
      return;
    }

    isSubmitting.value = true;
    try {
      await _firestore.collection('duties').add({
        'driver_id': selectedDriver.value,
        'vehicle_id': selectedVehicle.value,
        'start_time': startTime.value,
        'end_time': endTime.value,
        'total_trips': int.tryParse(tripsController.text) ?? 0,
        'total_earnings': double.tryParse(earningsController.text) ?? 0.0,
        'cash_collected': double.tryParse(cashCollectedController.text) ?? 0.0,
        'toll': double.tryParse(tollController.text) ?? 0.0,
        'fuel_expense': double.tryParse(fuelController.text) ?? 0.0,
        'fleet_id': currentFleet!.fleetId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      Get.snackbar("Success", "Duty added successfully",
          snackPosition: SnackPosition.BOTTOM);
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
