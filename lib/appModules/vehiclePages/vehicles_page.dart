import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/vehiclePages/add_vehicle.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:timeago/timeago.dart' as timeago;

class VehiclesPage extends StatelessWidget {
  final VehicleController controller = Get.isRegistered()
      ? Get.find<VehicleController>()
      : Get.put(VehicleController());
  VehiclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearAll();
          Get.to(() => const AddVehiclePage());
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          background: vehicleStats(),
        ),
      ),
      body: RefreshIndicator(
          color: ColorConst.primaryColor,
          onRefresh: () => controller.listVehicles(),
          child: Obx(() {
            if (controller.isVehiclesLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (controller.vehicles.isEmpty) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No vehicles added yet',
                    style: Get.textTheme.titleLarge!
                        .copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tap the + button to add new',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton.icon(
                    onPressed: () => controller.listVehicles(),
                    label: const Text('Refresh'),
                    icon: const Icon(Icons.refresh),
                  )
                ],
              ));
            }
            return _buildVehiclesTab();
          })),
    ));
  }

  Widget vehicleStats() {
    return Obx(() {
      int inUseVehicles =
          controller.vehicles.where((element) => element.onDuty != null).length;
      int availableVehicles = controller.vehicles.length - inUseVehicles;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.vehicles.length.toString()),
              const SizedBox(height: 5),
              const Text(
                'Vehicles',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(inUseVehicles.toString()),
              const SizedBox(height: 5),
              const Text(
                'In use',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                availableVehicles.toString(),
              ),
              const SizedBox(height: 5),
              const Text(
                'On rest',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildVehiclesTab() {
    return ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: controller.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = controller.vehicles[index];
          int vehicleTargetTrips = currentFleet!.targets['vehicle'];
          final tripCompletion = vehicle.weeklyTrips! /
              (vehicleTargetTrips > 0 ? vehicleTargetTrips : 1);
          Color progressColor;
          switch (vehicle.weeklyTrips!) {
            case (<= 59):
              progressColor = Colors.red;
            case (<= 74):
              progressColor = Colors.deepOrange;
            case (<= 89):
              progressColor = Colors.orange;
            case (<= 104):
              progressColor = Colors.yellow;
            case (< 120):
              progressColor = Colors.lightGreenAccent;
            default:
              progressColor = Colors.green;
          }
          return Card(
              child: ExpandablePanel(
            theme: const ExpandableThemeData(hasIcon: false, useInkWell: false),
            collapsed: const SizedBox(),
            expanded: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.03),
              child: Column(
                children: [
                  vehicle.onDuty == null
                      ? CustomWidgets().textRow(
                          label: 'Last driver', value: vehicle.lastDriver!)
                      : CustomWidgets().textRow(
                          label: 'Current driver',
                          value: vehicle.onDuty!.driverName),
                  vehicle.onDuty == null
                      ? CustomWidgets().textRow(
                          label: 'Last online',
                          value: timeago.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  vehicle.lastOnline!)))
                      : CustomWidgets().textRow(
                          label: 'Start time',
                          value: timeago.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  vehicle.onDuty!.startTime))),
                  vehicle.vehicleRent is double
                      ? CustomWidgets().textRow(
                          label: 'Vehicle Rent',
                          value:
                              "${vehicle.vehicleRent.toStringAsFixed(0)}/- per shift")
                      : Column(
                          children: [
                            const Divider(
                              color: Colors.white12,
                            ),
                            const Text('Rent per shift'),
                            Column(
                                children: List.generate(
                              vehicle.vehicleRent.length,
                              (index) {
                                return index == vehicle.vehicleRent.length - 1
                                    ? CustomWidgets().textRow(
                                        label:
                                            "${vehicle.vehicleRent[index]['min_trips']}+ trips",
                                        value:
                                            "${vehicle.vehicleRent[index]['rent']}")
                                    : CustomWidgets().textRow(
                                        label:
                                            "${vehicle.vehicleRent[index]['min_trips']} - ${vehicle.vehicleRent[index + 1]['min_trips'] - 1} trips",
                                        value:
                                            "${vehicle.vehicleRent[index]['rent']}");
                              },
                            )),
                          ],
                        )
                ],
              ),
            ),
            header: ListTile(
                leading: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: w * 0.04,
                        color:
                            vehicle.onDuty == null ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        vehicle.onDuty != null ? 'On duty' : 'On rest',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                title: Text(vehicle.numberPlate),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: h * 0.01),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: tripCompletion > 1 ? 1 : tripCompletion,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                      SizedBox(height: h * 0.01),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${vehicle.weeklyTrips.toString()} / $vehicleTargetTrips trips',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: PopupMenuButton(
                  child: const Icon(
                    Icons.more_vert_rounded,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                          onTap: () {
                            controller.clearAll();
                            Get.to(() => AddVehiclePage(
                                  vehicle: vehicle,
                                ));
                          },
                          child: const Text('Edit')),
                      PopupMenuItem(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Remove vehicle?'),
                                      content: const Text(
                                        'Are you sure you want to remove this vehicle?',
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('No')),
                                        TextButton(
                                            onPressed: () async {
                                              await controller.removeVehicle(
                                                  vehicleId: vehicle.vehicleId);
                                              Get.back();
                                            },
                                            child: Obx(() => controller
                                                    .isLoading.value
                                                ? const CupertinoActivityIndicator()
                                                : const Text('Yes'))),
                                      ],
                                    ));
                          },
                          child: const Text('Delete')),
                    ];
                  },
                )),
          ));
        });
  }
}
