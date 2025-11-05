import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/fleetPages/fleet_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class FleetListPage extends StatelessWidget {
  final controller = Get.isRegistered()
      ? Get.find<FleetController>()
      : Get.put(FleetController());

  FleetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.fleetList.isEmpty) {
          return const Center(
            child: Text('No fleets currently hiring.'),
          );
        }

        return ListView.builder(
          itemCount: controller.fleetList.length,
          itemBuilder: (context, index) {
            final fleet = controller.fleetList[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.directions_car, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fleet.fleetName,
                                  style: Get.textTheme.bodyLarge),
                              const SizedBox(height: 4),
                              Text(
                                  'Member since : ${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(fleet.addedOn))}',
                                  style: Get.textTheme.bodySmall!
                                      .copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.location_on, fleet.officeAddress),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.phone, fleet.contactNumber),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.directions_car,
                          '${fleet.vehicles == null ? 0 : fleet.vehicles!.length} vehicles',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isSendingRequest.value
                            ? null
                            : () => controller.joinRequest(fleet.ownerId),
                        label: controller.isSendingRequest.value
                            ? const CupertinoActivityIndicator()
                            : const Text('Send request'),
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size.fromWidth(w),
                            foregroundColor: Colors.black,
                            backgroundColor: ColorConst.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
