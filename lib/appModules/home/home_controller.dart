import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero/appModules/dashboard/dashboard_page.dart';
import 'package:zero/appModules/driverPages/driver_page.dart';
import 'package:zero/appModules/fleetPages/fleet_list.dart';
import 'package:zero/appModules/home/home_page.dart';
import 'package:zero/appModules/earningPages/earning_page.dart';
import 'package:zero/appModules/inbox/inbox_page.dart';
import 'package:zero/appModules/profile/profile_page.dart';
import 'package:zero/appModules/transactions/transactions_page.dart';
import 'package:zero/appModules/vehiclePages/vehicles_page.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    // streamUser();
    // if (currentUser != null) {
    //   loadFleet();
    // }
    checkForUpdation();
    listVehicles();
    super.onInit();
  }

  RxInt currentIndex = 0.obs;
  String userRole = currentUser!.userRole ?? 'USER';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool hasUpdate = false;

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
            'label': 'Dashboard',
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

  Future<void> checkForUpdation() async {
    final newVersion = NewVersionPlus(
      androidId: "com.zerofleets.zerofleets",
      iOSId: "com.zerofleets.zerofleets",
    );

    try {
      final status = await newVersion.getVersionStatus();
      if (status != null) {
        appVersion = status.localVersion;
        hasUpdate = status.canUpdate;
        if (hasUpdate) {
          Get.bottomSheet(
            isDismissible: false,
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Get.theme.cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  )),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('New version available',
                        style: Get.textTheme.titleLarge!),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromWidth(w),
                          foregroundColor: Colors.black,
                          backgroundColor: ColorConst.primaryColor),
                      onPressed: () async {
                        final url = Uri.parse(status.appStoreLink);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      child: const Text("Update Now"),
                    ),
                    TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('Update Later'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking app version: $e");
    }
  }

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
}
