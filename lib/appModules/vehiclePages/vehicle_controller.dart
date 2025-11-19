import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/core/subscriptionsController.dart';
import 'package:zero/models/vehicle_model.dart';

class VehicleController extends GetxController {
  ScrollController scrollController = ScrollController();
  final subs = Get.find<SubscriptionsController>();

  RxBool isFabVisible = true.obs;

  @override
  void onInit() {
    listVehicles();
    scrollController.addListener(() {
      isFabVisible.value = scrollController.position.userScrollDirection ==
          ScrollDirection.forward;
    });
    super.onInit();
  }

  final formkey = GlobalKey<FormState>();
  final numberPlateController = TextEditingController();
  final vehicleModelController = TextEditingController();
  // final targetTrips = TextEditingController();
  final rentType = 'fixed'.obs;
  final fixedRentController = TextEditingController();
  final rentRules = <RuleModel>[].obs;

  // final box = Hive.box('zeroCache');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isVehiclesLoading = false.obs;
  RxList<VehicleModel> vehicles = <VehicleModel>[].obs;

  listVehicles() async {
    try {
      isVehiclesLoading.value = true;
      var data = await _firestore
          .collection('vehicles')
          .where('owner_id', isEqualTo: subs.user.value?.uid)
          .get();
      vehicles.clear();
      List<Map<String, dynamic>> vehicleData = [];
      for (var vehicle in data.docs) {
        vehicleData.add(vehicle.data());
        VehicleModel vehicleModel = VehicleModel.fromMap(vehicle.data());
        vehicles.add(vehicleModel);
      }
    } catch (e) {
      log('Error getting vehicles : $e');
    } finally {
      isVehiclesLoading.value = false;
    }
  }

  RxBool isLoading = false.obs;
  createVehicle() async {
    try {
      isLoading.value = true;
      var vehicles = await _firestore
          .collection('vehicles')
          .where('number_plate', isEqualTo: numberPlateController.text.trim())
          .get();
      if (vehicles.docs.isNotEmpty &&
          vehicles.docs.first.data()['owner_id'].isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'Vehicle has another owner. Please check the Number plate',
            backgroundColor: Colors.red);
        isLoading.value = false;
      } else {
        String vehicleId = '';
        VehicleModel vehicleModel = VehicleModel(
          vehicleId: '',
          numberPlate: numberPlateController.text.trim(),
          vehicleModel: vehicleModelController.text.trim(),
          ownerId: subs.user.value!.uid,
          status: 'ACTIVE',
          addedOn: DateTime.now().millisecondsSinceEpoch,
          updatedOn: DateTime.now().millisecondsSinceEpoch,
          fleetId: subs.user.value!.fleetId,
          vehicleRent: rentType.value == 'fixed'
              ? double.parse(fixedRentController.text)
              : rentRules.map((r) => {
                    'min_trips': int.tryParse(r.minController.text) ?? 0,
                    'rent': double.tryParse(r.rentController.text) ?? 0
                  }),
        );
        await _firestore
            .collection('vehicles')
            .add(vehicleModel.toMap())
            .then((value) {
          vehicleId = value.id;
          value.update({'vehicle_id': value.id});
        });
        await _firestore
            .collection('fleets')
            .doc(subs.user.value!.fleetId)
            .update({
          'vehicles': FieldValue.arrayUnion([vehicleId])
        });
        Fluttertoast.showToast(msg: 'Vehicle added successfully!');
        await listVehicles();
        Get.back();
        clearAll();
        isLoading.value = false;
      }
    } catch (e) {
      log('Error while creating vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  editVehicle({required String vehicleId}) async {
    try {
      isLoading.value = true;
      dynamic vehicleRent = rentType.value == 'fixed'
          ? double.parse(fixedRentController.text)
          : rentRules.map((r) => {
                'min_trips': int.tryParse(r.minController.text) ?? 0,
                'rent': double.tryParse(r.rentController.text) ?? 0
              });
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'number_plate': numberPlateController.text.trim(),
        'vehicle_model': vehicleModelController.text.trim(),
        'updated_on': DateTime.now().millisecondsSinceEpoch,
        'vehicle_rent': vehicleRent,
      });
      Fluttertoast.showToast(msg: 'Vehicle updated successfully!');
      await listVehicles();
      Get.back();
      clearAll();
      isLoading.value = false;
    } catch (e) {
      log('Error while editing vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  removeVehicle({required String vehicleId}) async {
    try {
      isLoading.value = true;
      await _firestore.collection('vehicles').doc(vehicleId).delete();
      await _firestore
          .collection('fleets')
          .doc(subs.user.value!.fleetId)
          .update({
        'vehicles': FieldValue.arrayRemove([vehicleId])
      });
      Fluttertoast.showToast(msg: 'Vehicle deleted!');
      await listVehicles();
      isLoading.value = false;
    } catch (e) {
      log('Error while removing vehicle : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
      isLoading.value = false;
    }
  }

  clearAll() {
    numberPlateController.clear();
    vehicleModelController.clear();
    fixedRentController.clear();
    rentRules.clear();
  }
}

class RuleModel {
  final minController = TextEditingController();
  final rentController = TextEditingController();
}
