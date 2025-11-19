import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';
import 'package:zero/models/notification_model.dart';

class InboxController extends GetxController {
  final subs = Get.find<SubscriptionsController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchInbox();
    super.onInit();
  }

  RxList<NotificationModel> inboxList = <NotificationModel>[].obs;
  Future<void> fetchInbox() async {
    try {
      isLoading.value = true;
      print('-- INBOX STREAM --');
      _firestore
          .collection('inbox')
          .where('receiver_id', isEqualTo: subs.user.value!.uid)
          .where('status', isEqualTo: "PENDING")
          .snapshots()
          .listen((event) {
        inboxList.value = event.docs
            .map((e) => NotificationModel.fromJson(e.data()))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notificationCounts = inboxList.length;
      });
    } finally {
      isLoading.value = false;
    }
  }

  RxBool actionLoading = false.obs;
  Future<void> declineRequest({required String notificationId}) async {
    try {
      actionLoading.value = true;
      await _firestore.collection('inbox').doc(notificationId).update({
        'status': 'DECLINED',
      });
      fetchInbox();
    } catch (e) {
      log('Error declining request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> declinePayment(
      {required String notificationId, required String transactionId}) async {
    try {
      actionLoading.value = true;
      await _firestore.collection('inbox').doc(notificationId).update({
        'status': 'DECLINED',
      });
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update({'status': 'DECLINED'});
      fetchInbox();
    } catch (e) {
      log('Error declining payment : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> acceptFleetRequest(
      {required String notificationId, required String fleetId}) async {
    try {
      actionLoading.value = true;
      final inboxRef = _firestore.collection('inbox').doc(notificationId);
      final userRef = _firestore.collection('users').doc(subs.user.value!.uid);
      final fleetRef = _firestore.collection('fleets').doc(fleetId);

      _firestore.runTransaction((transaction) async {
        final inboxSnap = await transaction.get(inboxRef);
        final userSnap = await transaction.get(userRef);
        final fleetSnap = await transaction.get(fleetRef);
        if (!inboxSnap.exists || !userSnap.exists || !fleetSnap.exists) {
          throw Exception('Documents not found');
        }
        transaction.update(inboxRef, {'status': 'ACCEPTED'});
        transaction
            .update(userRef, {'fleet_id': fleetId, 'user_role': 'DRIVER'});
        transaction.update(fleetRef, {
          'drivers': FieldValue.arrayUnion([subs.user.value!.uid])
        });
      });
      fetchInbox();
      Fluttertoast.showToast(msg: 'Successfully joined fleet!');
      Get.offAllNamed('/splash');
    } catch (e) {
      log('Error accepting fleet request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> acceptDriverRequest(
      {required String notificationId, required String driverId}) async {
    try {
      actionLoading.value = true;
      final inboxRef = _firestore.collection('inbox').doc(notificationId);
      final userRef = _firestore.collection('users').doc(driverId);
      final fleetRef =
          _firestore.collection('fleets').doc(subs.user.value!.fleetId);

      _firestore.runTransaction((transaction) async {
        final inboxSnap = await transaction.get(inboxRef);
        final userSnap = await transaction.get(userRef);
        final fleetSnap = await transaction.get(fleetRef);
        if (!inboxSnap.exists || !userSnap.exists || !fleetSnap.exists) {
          transaction.delete(inboxRef);
          Fluttertoast.showToast(
              msg: 'Document doesn\'t exist', backgroundColor: Colors.red);
          return;
        }
        transaction.update(inboxRef, {'status': 'ACCEPTED'});
        transaction.update(userRef,
            {'fleet_id': subs.user.value!.fleetId, 'user_role': 'DRIVER'});
        transaction.update(fleetRef, {
          'drivers': FieldValue.arrayUnion([driverId])
        });
      });
      fetchInbox();
      Fluttertoast.showToast(msg: 'Driver request accepted!');
    } catch (e) {
      log('Error accepting driver request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> acceptPayment({required NotificationModel notification}) async {
    try {
      actionLoading.value = true;
      final inboxRef = _firestore.collection('inbox').doc(notification.id);
      final userRef = _firestore.collection('users').doc(notification.senderId);
      final transactionRef = _firestore
          .collection('transactions')
          .doc(notification.transaction!.transactionId);

      _firestore.runTransaction((transaction) async {
        final inboxSnap = await transaction.get(inboxRef);
        final userSnap = await transaction.get(userRef);
        final transactionsSnap = await transaction.get(transactionRef);
        if (!inboxSnap.exists || !userSnap.exists || !transactionsSnap.exists) {
          transaction.delete(inboxRef);
          Fluttertoast.showToast(
              msg: 'Document doesn\'t exist', backgroundColor: Colors.red);
          return;
        }
        transaction.update(inboxRef, {'status': 'ACCEPTED'});
        transaction.update(userRef, {
          'wallet': FieldValue.increment(notification.transaction!.amount),
        });
        transaction.update(transactionRef, {'status': 'ACCEPTED'});
      });
      // await fetchInbox();
      Fluttertoast.showToast(msg: 'Payment request accepted!');
    } catch (e) {
      log('Error accepting payment request : $e');
      Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again!',
          backgroundColor: Colors.red);
    } finally {
      actionLoading.value = false;
    }
  }
}
