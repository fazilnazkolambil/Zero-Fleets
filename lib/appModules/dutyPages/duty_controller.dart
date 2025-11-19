import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/dashboard/dashboard_controller.dart';
import 'package:zero/appModules/driverPages/driver_controller.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/duty_model.dart';
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';

class DutyController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rxn<VehicleModel> selectedVehicle = Rxn<VehicleModel>();
  Rxn<UserModel> selectedDriver = Rxn<UserModel>();
  RxString dutyHours = '12 hrs'.obs;

  final TextEditingController totalTripsController = TextEditingController();
  final TextEditingController totalEarningsController = TextEditingController();
  final TextEditingController tollController = TextEditingController();
  final TextEditingController cashCollectedController = TextEditingController();
  final TextEditingController fuelExpenseController = TextEditingController();

  autoFillData(DutyModel dutyModel) async {
    startTime.value = dutyModel.startTime;
    endTime.value = dutyModel.endTime;
    totalTripsController.text = dutyModel.totalTrips.toString();
    totalEarningsController.text = dutyModel.totalEarnings!.toStringAsFixed(2);
    tollController.text = dutyModel.toll!.toStringAsFixed(2);
    cashCollectedController.text = dutyModel.cashCollected!.toStringAsFixed(2);
    fuelExpenseController.text = dutyModel.fuelExpense!.toStringAsFixed(2);
    selectedDriver.value = Get.put(DriverController())
        .driverList
        .where((d) => d.uid == dutyModel.driverId)
        .first;
    selectedVehicle.value = Get.put(VehicleController())
        .vehicles
        .where((v) => v.vehicleId == dutyModel.vehicleId)
        .first;
  }

  Map<String, dynamic> finalValues = {};

  final formkey = GlobalKey<FormState>();
  RxBool isLocationLoading = false.obs;
  Future<bool> isDriverinLocation() async {
    isLocationLoading.value = true;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final Map<String, dynamic> fleetLocation = currentFleet!.parkingLocation;
    double distance = Geolocator.distanceBetween(
        fleetLocation['latitude'],
        fleetLocation['longitude'],
        currentPosition.latitude,
        currentPosition.longitude);
    log(distance.toString());
    if (distance <= 1000) {
      isLocationLoading.value = false;
      return true;
    } else {
      isLocationLoading.value = false;
      return false;
    }
  }

  RxBool isDutyLoading = false.obs;
  Future<void> startDuty({required String userId}) async {
    try {
      isDutyLoading.value = true;
      final dutyRef = _firestore.collection('duties').doc();
      final driverRef = _firestore.collection('users').doc(userId);
      final vehicleRef = _firestore
          .collection('vehicles')
          .doc(selectedVehicle.value!.vehicleId);

      await _firestore.runTransaction(
        (transaction) async {
          final driverSnap = await transaction.get(driverRef);
          final vehicleSnap = await transaction.get(vehicleRef);
          if (!driverSnap.exists || !vehicleSnap.exists) {
            throw Exception('Driver or vehicle not found');
          }

          int selectedShifts = dutyHours.value == '12 hrs' ? 1 : 2;
          DutyModel newDuty = DutyModel(
              dutyId: dutyRef.id,
              driverId: currentUser!.uid,
              fleetId: currentUser!.fleetId!,
              driverName: currentUser!.fullName,
              vehicleId: selectedVehicle.value!.vehicleId,
              vehicleNumber: selectedVehicle.value!.numberPlate,
              startTime: DateTime.now().millisecondsSinceEpoch,
              vehicleRent: selectedVehicle.value!.vehicleRent,
              selectedShift: selectedShifts,
              dutyStatus: 'STARTED');
          DriverOnDuty driverOnDuty = DriverOnDuty(
              dutyId: dutyRef.id,
              startTime: DateTime.now().millisecondsSinceEpoch,
              vehicleId: selectedVehicle.value!.vehicleId,
              vehicleNumber: selectedVehicle.value!.numberPlate,
              selectedShift: selectedShifts);
          VehicleOnDuty vehicleOnDuty = VehicleOnDuty(
              startTime: DateTime.now().millisecondsSinceEpoch,
              driverId: currentUser!.uid,
              driverName: currentUser!.fullName);
          transaction.set(dutyRef, newDuty.toJson());
          transaction.update(driverRef, {'on_duty': driverOnDuty.toMap()});
          currentUser = currentUser!.copyWith(onDuty: driverOnDuty);
          transaction.update(vehicleRef, {'on_duty': vehicleOnDuty.toMap()});
        },
      );
    } catch (e) {
      log('Error starting duty : $e');
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again!');
    } finally {
      isDutyLoading.value = false;
    }
  }

  double calculateVehicleRent({
    required dynamic rentRules,
    required int totalTrips,
    required int selectedShift,
  }) {
    if (rentRules is double || rentRules is int) {
      return (rentRules as num).toDouble() * selectedShift;
    }

    final rules = List<Map<String, dynamic>>.from(rentRules);
    rules.sort(
        (a, b) => (b['min_trips'] as int).compareTo(a['min_trips'] as int));

    for (var rule in rules) {
      int scaledMinTrips = (rule['min_trips'] as int) * selectedShift;
      if (totalTrips >= scaledMinTrips) {
        return (rule['rent'] as num).toDouble() * selectedShift;
      }
    }

    return 0;
  }

  Future<void> endDuty({required DriverOnDuty duty}) async {
    try {
      isDutyLoading.value = true;
      final dutyRef = _firestore.collection('duties').doc(duty.dutyId);
      final driverRef = _firestore.collection('users').doc(currentUser!.uid);
      final vehicleRef = _firestore.collection('vehicles').doc(duty.vehicleId);

      int totalTrips = int.parse(totalTripsController.text);
      double totalEarnings = double.parse(totalEarningsController.text);
      double totalToll = double.parse(tollController.text);
      double cashCollected = double.parse(cashCollectedController.text);
      double fuelExpense = fuelExpenseController.text.isEmpty
          ? 0
          : double.parse(fuelExpenseController.text);

      await _firestore.runTransaction((transaction) async {
        final dutySnap = await transaction.get(dutyRef);
        final driverSnap = await transaction.get(driverRef);
        final vehicleSnap = await transaction.get(vehicleRef);

        if (!dutySnap.exists || !driverSnap.exists || !vehicleSnap.exists) {
          throw Exception("Duty, driver, or vehicle not found");
        }

        VehicleModel vehicleData = VehicleModel.fromMap(vehicleSnap.data()!);
        dynamic rentRules = vehicleData.vehicleRent;
        int selectedShift = duty.selectedShift;
        double vehicleRent = calculateVehicleRent(
            rentRules: rentRules,
            totalTrips: totalTrips,
            selectedShift: selectedShift);
        double otherFees = totalEarnings * 0.14;
        double totalToPay =
            ((totalEarnings - otherFees) + totalToll - cashCollected) -
                vehicleRent;
        double driverBalance =
            (totalEarnings - otherFees) - vehicleRent - fuelExpense;

        finalValues = {
          'vehicle_rent': vehicleRent,
          'other_fees': otherFees,
          'total_to_pay': totalToPay,
        };

        final dutyUpdates = {
          'duty_status': 'COMPLETED',
          'end_time': DateTime.now().millisecondsSinceEpoch,
          'total_trips': totalTrips,
          'total_earnings': totalEarnings,
          'cash_collected': cashCollected,
          'toll': totalToll,
          'fuel_expense': fuelExpense,
          'other_fees': otherFees,
          'total_to_pay': totalToPay,
          'vehicle_rent': vehicleRent,
        };
        transaction.update(dutyRef, dutyUpdates);
        transaction.update(driverRef, {
          'wallet': FieldValue.increment(totalToPay),
          'on_duty': null,
          'weekly_shift': FieldValue.increment(selectedShift),
          'weekly_trip': FieldValue.increment(totalTrips),
          'last_vehicle': vehicleData.numberPlate,
          'earning_details.total_trips': FieldValue.increment(totalTrips),
          'earning_details.total_duties': FieldValue.increment(selectedShift),
          'earning_details.total_balance': FieldValue.increment(driverBalance),
        });
        transaction.update(vehicleRef, {
          'on_duty': null,
          'total_trips': FieldValue.increment(totalTrips),
          'weekly_trips': FieldValue.increment(totalTrips),
          'last_online': DateTime.now().millisecondsSinceEpoch,
          'last_driver': currentUser!.fullName,
          'last_driver_id': currentUser!.uid,
        });
      });
    } catch (e) {
      log('Error ending duty : $e');
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again!');
    } finally {
      isDutyLoading.value = false;
    }
  }

  RxBool isValidate = true.obs;

  var startTime = Rxn<int>();
  var endTime = Rxn<int>();

  RxBool isSubmitting = false.obs;

  Future<void> addDuty({required String userId}) async {
    try {
      isSubmitting.value = true;
      final dutyRef = _firestore.collection('duties').doc();
      final driverRef = _firestore.collection('users').doc(userId);
      final vehicleRef = _firestore
          .collection('vehicles')
          .doc(selectedVehicle.value!.vehicleId);

      int totalTrips = int.parse(totalTripsController.text);
      double totalEarnings = double.parse(totalEarningsController.text);
      double totalToll = double.parse(tollController.text);
      double cashCollected = double.parse(cashCollectedController.text);
      double fuelExpense = fuelExpenseController.text.isEmpty
          ? 0
          : double.parse(fuelExpenseController.text);

      await _firestore.runTransaction(
        (transaction) async {
          final driverSnap = await transaction.get(driverRef);
          final vehicleSnap = await transaction.get(vehicleRef);
          if (!driverSnap.exists || !vehicleSnap.exists) {
            throw Exception('Driver or vehicle not found');
          }

          int selectedShifts = dutyHours.value == '12 hrs' ? 1 : 2;

          VehicleModel vehicleData = VehicleModel.fromMap(vehicleSnap.data()!);
          dynamic rentRules = vehicleData.vehicleRent;
          double vehicleRent = calculateVehicleRent(
              rentRules: rentRules,
              totalTrips: totalTrips,
              selectedShift: selectedShifts);
          double otherFees = totalEarnings * 0.14;
          double totalToPay =
              ((totalEarnings - otherFees) + totalToll - cashCollected) -
                  vehicleRent;
          double driverBalance =
              (totalEarnings - otherFees) - vehicleRent - fuelExpense;

          DutyModel newDuty = DutyModel(
              dutyId: dutyRef.id,
              driverId: selectedDriver.value!.uid,
              fleetId: currentUser!.fleetId!,
              driverName: selectedDriver.value!.fullName,
              vehicleId: selectedVehicle.value!.vehicleId,
              vehicleNumber: selectedVehicle.value!.numberPlate,
              startTime: startTime.value!,
              vehicleRent: vehicleRent,
              selectedShift: selectedShifts,
              totalTrips: totalTrips,
              totalEarnings: totalEarnings,
              toll: totalToll,
              cashCollected: cashCollected,
              fuelExpense: fuelExpense,
              otherFees: otherFees,
              totaltoPay: totalToPay,
              endTime: endTime.value,
              dutyStatus: 'COMPLETED');

          transaction.update(driverRef, {
            'wallet': FieldValue.increment(totalToPay),
            'weekly_shift': FieldValue.increment(selectedShifts),
            'weekly_trip': FieldValue.increment(totalTrips),
            'earning_details.total_trips': FieldValue.increment(totalTrips),
            'earning_details.total_duties':
                FieldValue.increment(selectedShifts),
            'earning_details.total_balance':
                FieldValue.increment(driverBalance),
          });
          transaction.update(vehicleRef, {
            'total_trips': FieldValue.increment(totalTrips),
            'weekly_trips': FieldValue.increment(totalTrips),
            'last_driver': selectedDriver.value!.fullName,
            'last_driver_id': selectedDriver.value!.uid,
          });
          transaction.set(dutyRef, newDuty.toJson());
        },
      );
      Fluttertoast.showToast(msg: 'Duty added successfully');
      Get.put(DashboardController()).fetchWeeklyDuties();
      Get.back();
    } catch (e) {
      log('Error adding duty : $e');
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again!');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> editDuty({required String dutyId}) async {
    try {
      isSubmitting.value = true;

      final dutyRef = _firestore.collection('duties').doc(dutyId);
      final dutySnap = await dutyRef.get();
      if (!dutySnap.exists) {
        throw Exception('Duty not found');
      }

      DutyModel oldDuty = DutyModel.fromMap(dutySnap.data()!);

      final driverRef = _firestore.collection('users').doc(oldDuty.driverId);
      final vehicleRef =
          _firestore.collection('vehicles').doc(oldDuty.vehicleId);

      int newTrips = int.parse(totalTripsController.text);
      double newEarnings = double.parse(totalEarningsController.text);
      double newToll = double.parse(tollController.text);
      double newCash = double.parse(cashCollectedController.text);
      double newFuel = fuelExpenseController.text.isEmpty
          ? 0
          : double.parse(fuelExpenseController.text);

      int selectedShifts = dutyHours.value == '12 hrs' ? 1 : 2;

      final vehicleSnap = await vehicleRef.get();
      if (!vehicleSnap.exists) throw Exception('Vehicle not found');
      VehicleModel vehicleData = VehicleModel.fromMap(vehicleSnap.data()!);

      double newVehicleRent = calculateVehicleRent(
        rentRules: vehicleData.vehicleRent,
        totalTrips: newTrips,
        selectedShift: selectedShifts,
      );

      double newOtherFees = newEarnings * 0.14;
      double newTotalToPay =
          ((newEarnings - newOtherFees) + newToll - newCash) - newVehicleRent;
      double newDriverBalance =
          (newEarnings - newOtherFees) - newVehicleRent - newFuel;

      await _firestore.runTransaction((transaction) async {
        final driverSnap = await transaction.get(driverRef);
        final vehicleSnap = await transaction.get(vehicleRef);

        if (!driverSnap.exists || !vehicleSnap.exists) {
          throw Exception('Driver or vehicle not found');
        }

        transaction.update(driverRef, {
          'wallet': FieldValue.increment(-oldDuty.totaltoPay!),
          'weekly_shift': FieldValue.increment(-oldDuty.selectedShift),
          'weekly_trip': FieldValue.increment(-oldDuty.totalTrips!),
          'earning_details.total_trips':
              FieldValue.increment(-oldDuty.totalTrips!),
          'earning_details.total_duties':
              FieldValue.increment(-oldDuty.selectedShift),
          'earning_details.total_balance': FieldValue.increment(
              -((oldDuty.totalEarnings! - oldDuty.otherFees!) -
                  oldDuty.vehicleRent -
                  oldDuty.fuelExpense!)),
        });

        transaction.update(vehicleRef, {
          'total_trips': FieldValue.increment(-oldDuty.totalTrips!),
          'weekly_trips': FieldValue.increment(-oldDuty.totalTrips!),
        });

        transaction.update(driverRef, {
          'wallet': FieldValue.increment(newTotalToPay),
          'weekly_shift': FieldValue.increment(selectedShifts),
          'weekly_trip': FieldValue.increment(newTrips),
          'earning_details.total_trips': FieldValue.increment(newTrips),
          'earning_details.total_duties': FieldValue.increment(selectedShifts),
          'earning_details.total_balance':
              FieldValue.increment(newDriverBalance),
        });

        transaction.update(vehicleRef, {
          'total_trips': FieldValue.increment(newTrips),
          'weekly_trips': FieldValue.increment(newTrips),
          'last_driver': oldDuty.driverName,
          'last_driver_id': oldDuty.driverId,
        });

        transaction.update(dutyRef, {
          'total_trips': newTrips,
          'total_earnings': newEarnings,
          'toll': newToll,
          'cash_collected': newCash,
          'fuel_expense': newFuel,
          'vehicle_rent': newVehicleRent,
          'other_fees': newOtherFees,
          'total_to_pay': newTotalToPay,
          'selected_shift': selectedShifts,
          'end_time': endTime.value,
          'start_time': startTime.value,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      });

      Fluttertoast.showToast(msg: 'Duty updated successfully');
      Get.put(DashboardController()).fetchWeeklyDuties();
      Get.back();
    } catch (e) {
      log('Error editing duty : $e');
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again!');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> pickStartDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: startTime.value != null
          ? DateTime.fromMillisecondsSinceEpoch(startTime.value!)
          : DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: startTime.value != null
          ? TimeOfDay.fromDateTime(
              DateTime.fromMillisecondsSinceEpoch(startTime.value!))
          : TimeOfDay.now(),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    startTime.value = dt.millisecondsSinceEpoch;
    endTime.value = null;
  }

  Future<void> pickEndDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: endTime.value != null
          ? DateTime.fromMillisecondsSinceEpoch(endTime.value!)
          : DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: endTime.value != null
          ? TimeOfDay.fromDateTime(
              DateTime.fromMillisecondsSinceEpoch(endTime.value!))
          : TimeOfDay.now(),
    );
    if (time == null) return;
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    endTime.value = dt.millisecondsSinceEpoch;

    Duration dif = DateTime.fromMillisecondsSinceEpoch(endTime.value!)
        .difference(DateTime.fromMillisecondsSinceEpoch(startTime.value!));
    dutyHours.value = dif.inHours >= 24 ? '24 hrs' : '12 hrs';
  }
}
