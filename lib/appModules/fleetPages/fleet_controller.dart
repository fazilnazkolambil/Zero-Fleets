import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/notification_model.dart';

class FleetController extends GetxController {
  final subs = Get.find<SubscriptionsController>();
  @override
  void onInit() {
    listFleets();
    super.onInit();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController fleetNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController officeAddressController = TextEditingController();
  TextEditingController latLongController = TextEditingController();
  TextEditingController driverTargetTrips = TextEditingController();
  TextEditingController vehicleTargetTrips = TextEditingController();
  TextEditingController upiController = TextEditingController();
  TextEditingController bankingNameController = TextEditingController();

  Map<String, dynamic> fleetLatLong = {};
  RxBool isFleetHiring = false.obs;
  final formkey = GlobalKey<FormState>();

  loadFleetData() {
    final fleet = subs.fleet.value!;
    fleetNameController.text = fleet.fleetName;
    contactNumberController.text = fleet.contactNumber;
    officeAddressController.text = fleet.officeAddress;
    latLongController.text =
        "${fleet.parkingLocation['latitude']}, ${fleet.parkingLocation['longitude']}";
    driverTargetTrips.text = fleet.targets['driver'].toString();
    vehicleTargetTrips.text = fleet.targets['vehicle'].toString();
    upiController.text = fleet.upiId ?? '';
    bankingNameController.text = fleet.bankingName ?? '';
    fleetLatLong = fleet.parkingLocation;
    isFleetHiring.value = fleet.isHiring;
  }

  RxBool isLoading = false.obs;
  RxList<FleetModel> fleetList = <FleetModel>[].obs;
  Future<void> listFleets() async {
    try {
      isLoading.value = true;
      var data = await _firestore
          .collection('fleets')
          .where('is_hiring', isEqualTo: true)
          .get();
      List fleets = data.docs.map((e) => e.data()).toList();
      fleetList.value = fleets.map((e) => FleetModel.fromMap(e)).toList();
      isLoading.value = false;
    } catch (e) {
      log('Error listing fleets : $e');
      isLoading.value = false;
    }
  }

  RxBool isSendingRequest = false.obs;
  Future<void> joinRequest(String ownerId) async {
    try {
      isSendingRequest.value = true;
      NotificationModel notification = NotificationModel(
        id: '',
        notificationType: NotificationTypes.joinRequest,
        senderId: subs.user.value!.uid,
        receiverId: ownerId,
        status: 'PENDING',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        user: subs.user.value!,
      );
      await _firestore
          .collection('inbox')
          .add(notification.toMap())
          .then((value) {
        value.update({'id': value.id});
      });
      fleetList.removeWhere((element) => element.ownerId == ownerId);
      Fluttertoast.showToast(msg: 'Request sent successfully');
    } catch (e) {
      log('Error sending joinRequest: $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isSendingRequest.value = false;
    }
  }

  Future<void> getLocation() async {
    try {
      isLoading.value = true;
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: 'Location permission denied!', backgroundColor: Colors.red);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      latLongController.text = "${position.latitude}, ${position.longitude}";
      fleetLatLong = {
        'latitude': position.latitude,
        'longitude': position.longitude
      };
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error fetching location', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  updateFleet() async {
    try {
      isLoading.value = true;
      FleetModel fleetModel = subs.fleet.value!.copyWith(
          fleetName: fleetNameController.text.trim(),
          contactNumber: contactNumberController.text.trim(),
          officeAddress: officeAddressController.text.trim(),
          parkingLocation: fleetLatLong,
          updatedOn: DateTime.now().millisecondsSinceEpoch,
          upiId: upiController.text.isEmpty ? null : upiController.text,
          bankingName: bankingNameController.text.isEmpty
              ? null
              : bankingNameController.text.trim(),
          targets: {
            'driver': int.tryParse(driverTargetTrips.text.trim()) ?? 0,
            'vehicle': int.tryParse(vehicleTargetTrips.text.trim()) ?? 0,
          },
          isHiring: isFleetHiring.value);
      await _firestore
          .collection('fleets')
          .doc(subs.user.value!.fleetId)
          .update(fleetModel.toMap());
      Get.back();
      Fluttertoast.showToast(msg: 'Updation successfull.');
    } catch (e) {
      log('Error updating fleet: $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
