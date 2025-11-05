import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/notification_model.dart';
import 'package:zero/models/user_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final box = Hive.box('zeroCache');

  @override
  void onInit() {
    loadDrivers();
    super.onInit();
  }

  RxBool isLoading = false.obs;
  RxList<UserModel> driverList = <UserModel>[].obs;

  loadDrivers() async {
    driverList.clear();
    final driverCache = box.get('drivers');
    if (driverCache != null) {
      // final data = jsonDecode(driverCache);
      // log(data.toString());
      // driverList.value = data;
      driverList.value = (jsonDecode(driverCache) as List)
          .map((v) => UserModel.fromMap(v))
          .toList();
    }
    listDrivers();
  }

  listDrivers() async {
    try {
      isLoading.value = true;
      var data = await _firestore
          .collection('users')
          .where('uid', isNotEqualTo: currentFleet!.ownerId)
          .where('fleet_id', isEqualTo: currentFleet!.fleetId)
          .get();
      List driver = data.docs.map((e) => e.data()).toList();
      driverList.value = driver.map((e) => UserModel.fromMap(e)).toList();
      driverList.removeWhere((dr) => dr.uid == currentFleet!.ownerId);
      box.put('drivers', jsonEncode(driver));
      isLoading.value = false;
    } catch (e) {
      log('Error listing drivers : $e');
      isLoading.value = false;
    }
  }

  final phoneController = TextEditingController();
  final foundUser = Rxn<UserModel>();

  Future<void> searchDriver() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      Fluttertoast.showToast(
          msg: 'Enter a valid phone number', backgroundColor: Colors.red);
      return;
    }

    isLoading.value = true;
    foundUser.value = null;

    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('user_role', isEqualTo: 'USER')
          .where('phone_number', isEqualTo: phone)
          .get();

      if (result.docs.isNotEmpty) {
        foundUser.value = UserModel.fromMap(result.docs.first.data());
      } else {
        foundUser.value = null;
      }
    } catch (e) {
      log('Error finding driver : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  RxBool sendingInvitation = false.obs;
  Future<void> sendInvite(String driverId) async {
    try {
      sendingInvitation.value = true;
      NotificationModel notification = NotificationModel(
        id: '',
        notificationType: NotificationTypes.fleetInvitation,
        senderId: currentUser!.uid,
        receiverId: driverId,
        status: 'PENDING',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        fleet: currentFleet,
      );
      await FirebaseFirestore.instance
          .collection('inbox')
          .add(notification.toMap())
          .then((value) {
        value.update({'id': value.id});
      });
      Fluttertoast.showToast(msg: 'Invitation sent successfully');
      Get.back();
    } catch (e) {
      log('Error sending invitation : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      sendingInvitation.value = false;
    }
  }

  Future<void> removeDriver({required String userId}) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fleet_id': null, 'user_role': 'USER'});
      await _firestore.collection('fleets').doc(currentFleet!.fleetId).update({
        'drivers': FieldValue.arrayRemove([userId])
      });
      await listDrivers();
    } catch (e) {
      log('Error removing driver : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    }
  }
}
