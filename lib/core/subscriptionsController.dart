import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/user_model.dart';

class SubscriptionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final Rx<FleetModel?> fleet = Rx<FleetModel?>(null);

  StreamSubscription? _userSub;
  StreamSubscription? _fleetSub;

  @override
  void onInit() {
    super.onInit();
    _listenToUser();
  }

  void _listenToUser() {
    print('-- USER STREAM --');
    _userSub = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = UserModel.fromMap(snapshot.data()!);
        user.value = data;
        currentUser = data;
        _listenToFleet(data.fleetId);
      }
    });
  }

  void _listenToFleet(String? fleetId) {
    if (fleetId == null) {
      fleet.value = null;
      return;
    }

    print('-- FLEET STREAM --');

    _fleetSub?.cancel();
    _fleetSub = _firestore
        .collection('fleets')
        .doc(fleetId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = FleetModel.fromMap(snapshot.data()!);
        fleet.value = data;
        currentFleet = data;
      } else {
        _firestore.collection('users').doc(currentUser!.uid).update({
          'fleet_id': null,
          'user_role': 'USER',
        });
      }
    });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _fleetSub?.cancel();
    super.onClose();
  }
}
