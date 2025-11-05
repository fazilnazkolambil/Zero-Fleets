import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dutyPages/duty_controller.dart';
import 'package:zero/appModules/dutyPages/duty_page.dart';
import 'package:zero/appModules/home/home_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/vehicle_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    final HomeController homeController = Get.find<HomeController>();
    final DutyController dutyController = Get.put(DutyController());
    if (currentUser!.onDuty != null) {
      return DutyPage();
    }
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Obx(() {
          if (dutyController.selectedVehicle.value == null) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorConst.secondaryButton,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _selectShiftHours(
                    value: dutyController.dutyHours.value,
                    items: ["12 hrs", "24 hrs"],
                    onChanged: (value) =>
                        dutyController.dutyHours.value = value.toString()),
                const SizedBox(width: 20),
                _startDuty(dutyController),
                const SizedBox(width: 20),
                IconButton(
                    onPressed: () =>
                        dutyController.selectedVehicle.value = null,
                    icon: const Icon(Icons.clear))
              ],
            ),
          );
        }),
        appBar: currentUser!.userRole == 'VEHICLE_OWNER'
            ? null
            : AppBar(
                title: _searchbar(homeController),
              ),
        body: Obx(
          () {
            if (currentUser!.userRole == 'VEHICLE_OWNER') {
              return _carOwnerView(homeController);
            } else {
              return _vehicleList(homeController, dutyController);
            }
          },
        ));
  }

  _selectShiftHours(
      {required value,
      required List<String> items,
      required void Function(String?)? onChanged}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged),
    );
  }

  _startDuty(DutyController dutyController) {
    return Obx(
      () => ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        onPressed: dutyController.isLocationLoading.value
            ? null
            : () async {
                bool isDriverOnLocation =
                    await dutyController.isDriverinLocation();
                if (isDriverOnLocation) {
                  Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
                        title: const Text('Start duty?'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Vehicle : ${dutyController.selectedVehicle.value!.numberPlate}'),
                              const SizedBox(height: 10),
                              Text(
                                  'Start time : ${DateFormat.jm().format(DateTime.now())}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('No, cancel')),
                          TextButton(
                              onPressed: () async {
                                await dutyController.startDuty();
                                Get.offAllNamed('/home');
                              },
                              child: const Text('Yes, confirm')),
                        ],
                      ));
                } else {
                  Fluttertoast.showToast(
                      msg:
                          'You\'re not at the location!. Go to your fleet parking location before ending duty.',
                      backgroundColor: Colors.red);
                }
              },
        child: const Text(
          "Start Duty",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  _searchbar(HomeController controller) {
    return TextFormField(
      controller: controller.searchController,
      onChanged: (value) {
        controller.searchkey.value = value;
      },
      style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
      cursorColor: Colors.white,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: const InputDecoration(
        counterText: '',
        fillColor: Colors.white12,
        prefixIcon: Icon(Icons.search),
        hintText: 'Search vehicles',
      ),
    );
  }

  _vehicleList(HomeController controller, DutyController dutyController) {
    if (controller.isVehiclesLoading.value) {
      return const Center(child: CupertinoActivityIndicator());
    }
    List<VehicleModel> filteredAssets = controller.searchkey.value.isEmpty
        ? controller.vehicles
        : controller.vehicles.where((e) {
            var search = controller.searchkey.value.toLowerCase();
            return e.numberPlate.toLowerCase().contains(search);
          }).toList();
    if (filteredAssets.isEmpty) {
      return const Center(child: Text('No vehicles found!'));
    }

    return RefreshIndicator(
        color: ColorConst.primaryColor,
        onRefresh: () => controller.listVehicles(),
        child: ListView.builder(
          // physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: filteredAssets.length,
          itemBuilder: (context, index) {
            final vehicle = filteredAssets[index];
            return Obx(() {
              bool isSelected = dutyController.selectedVehicle.value == vehicle;
              return GestureDetector(
                onTap: () {
                  dutyController.selectedVehicle.value = vehicle;
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.1),
                        width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            size: 32,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("${vehicle.numberPlate} • "),
                                Text(vehicle.vehicleModel,
                                    style: Get.textTheme.bodySmall!
                                        .copyWith(color: Colors.grey))
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                                'Last driver : ${vehicle.lastDriver ?? '-N/A-'}'),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ));
  }

  _carOwnerView(HomeController controller) {
    VehicleModel vehicle = controller.vehicles.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 45,
                    ),
                    title: Text(vehicle.vehicleId),
                    subtitle: Text(vehicle.vehicleModel),
                  ),
                  const Divider(height: 30, color: Colors.white12),
                  if (vehicle.onDuty != null)
                    CustomWidgets().textRow(
                        label: 'Last online',
                        value: DateFormat('dd/MM-EEE hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                vehicle.onDuty!.startTime))),
                  CustomWidgets().textRow(
                      label: 'Total trips',
                      value: "${vehicle.weeklyTrips ?? 0}"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Duty Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.listVehicles();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Start Duty"),
            ),
          ),
        ],
      ),
    );
  }
}
