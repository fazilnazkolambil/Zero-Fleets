import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/appModules/dashboard/dashboard_page.dart';
import 'package:zero/appModules/driverPages/driver_page.dart';
import 'package:zero/appModules/fleetPages/fleet_list.dart';
import 'package:zero/appModules/home/home_page.dart';
import 'package:zero/appModules/earningPages/earning_page.dart';
import 'package:zero/appModules/inbox/inbox_page.dart';
import 'package:zero/appModules/profile/profile_page.dart';
import 'package:zero/appModules/transactions/transactions_page.dart';
import 'package:zero/appModules/vehiclePages/vehicles_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    streamUser();
    if (currentUser != null) {
      loadFleet();
    }
    listVehicles();
    super.onInit();
  }

  RxInt currentIndex = 0.obs;
  String userRole = currentUser!.userRole ?? 'USER';
  final box = Hive.box('zeroCache');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxString searchkey = ''.obs;
  SearchController searchController = SearchController();

  RxList<Map<String, dynamic>> get homePages {
    switch (userRole) {
      case ('USER'):
        return [
          {
            'label': 'Fleets',
            'icon': Icons.home_work,
            'page': FleetListPage(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
            'notification': true
          },
          {
            'label': 'Profile',
            'icon': Icons.person,
            'page': UserProfilePage(),
          },
        ].obs;
      case ('FLEET_OWNER'):
        return [
          {
            'label': 'Duty dashboard',
            'icon': Icons.dashboard,
            'page': DashboardPage(),
          },
          {
            'label': 'Vehicles',
            'icon': Icons.directions_car,
            'page': VehiclesPage(),
          },
          {
            'label': 'Drivers',
            'icon': Icons.group,
            'page': DriversPage(),
          },
          {
            'label': 'Transactions',
            'icon': Icons.payment,
            'page': TransactionsPage(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
            'notification': true
          },
          {
            'label': 'Settings',
            'icon': Icons.settings,
            'page': UserProfilePage(),
          },
        ].obs;
      default:
        return [
          {
            'label': 'Home',
            'icon': Icons.home_filled,
            'page': HomePage(),
          },
          {
            'label': 'Earnings',
            'icon': Icons.money,
            'page': EarningPage(),
          },
          {
            'label': 'Inbox',
            'icon': Icons.email,
            'page': InboxPage(),
            'notification': true
          },
          {
            'label': 'Profile',
            'icon': Icons.person,
            'page': UserProfilePage(),
          },
        ].obs;
    }
  }

  RxBool isVehiclesLoading = false.obs;
  RxList<VehicleModel> vehicles = <VehicleModel>[].obs;
  // loadVehicles() async {
  //   vehicles.clear();
  //   final cachedData = box.get('vehicles');
  //   if (cachedData != null) {
  //     vehicles.value = (jsonDecode(cachedData) as List)
  //         .map((v) => VehicleModel.fromMap(v))
  //         .toList();
  //   }
  //   listVehicles();
  // }

  listVehicles() async {
    try {
      isVehiclesLoading.value = true;
      vehicles.clear();
      var data = await _firestore
          .collection('vehicles')
          .where('fleet_id', isEqualTo: currentUser!.fleetId)
          .where('on_duty', isNull: true)
          .get();
      if (data.docs.isNotEmpty) {
        vehicles.value =
            data.docs.map((e) => VehicleModel.fromMap(e.data())).toList();
      }
      // box.put('vehicles', jsonEncode(vehicles.toJson()));
    } catch (e) {
      log('Error getting vehicles in home controller: $e');
    } finally {
      isVehiclesLoading.value = false;
    }
  }

  void changeIndex(int index) {
    if (homePages.length > 4 && currentIndex.value != index) {
      Get.back();
    }
    currentIndex.value = index;
  }

  loadFleet() async {
    // final fleetCache = box.get('currentFleet');
    // if (fleetCache != null) {
    //   final fleet = jsonDecode(fleetCache);
    //   currentFleet = FleetModel.fromMap(fleet);
    // }
    print('-- FLEET STREAM --');
    _firestore
        .collection('fleets')
        .doc(currentUser!.fleetId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        currentFleet =
            FleetModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    });
  }

  streamUser() async {
    print('-- USER STREAM --');
    _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        currentUser =
            UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
    });
  }
}
