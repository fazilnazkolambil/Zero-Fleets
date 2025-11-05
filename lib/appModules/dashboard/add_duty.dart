import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dashboard/dashboard_controller.dart';
import 'package:zero/appModules/driverPages/driver_controller.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/global_variables.dart';

class AddDutyPage extends GetView<DashboardController> {
  const AddDutyPage({super.key});

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Duty"),
        centerTitle: true,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                hint: Text('Select Driver',
                    style:
                        Get.textTheme.bodyMedium!.copyWith(color: Colors.grey)),
                style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
                initialValue: controller.selectedDriver.value.isEmpty
                    ? null
                    : controller.selectedDriver.value,
                items: Get.put(DriverController()).driverList.map((driver) {
                  return DropdownMenuItem(
                    value: driver.uid,
                    child: Text(driver.fullName),
                  );
                }).toList(),
                onChanged: (value) =>
                    controller.selectedDriver.value = value ?? "",
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                hint: Text('Select Vehicle',
                    style:
                        Get.textTheme.bodyMedium!.copyWith(color: Colors.grey)),
                style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
                initialValue: controller.selectedVehicle.value.isEmpty
                    ? null
                    : controller.selectedVehicle.value,
                items: Get.put(VehicleController()).vehicles.map((vehicle) {
                  return DropdownMenuItem(
                    value: vehicle.vehicleId,
                    child: Text(vehicle.numberPlate),
                  );
                }).toList(),
                onChanged: (value) =>
                    controller.selectedVehicle.value = value ?? "",
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Start Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              InkWell(
                onTap: () async {
                  await controller.pickStartDateTime(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.startTime.value != null
                            ? DateFormat('dd MMM yyyy, hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    controller.startTime.value!))
                            : "Select start time",
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // END TIME
              const Text("End Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              InkWell(
                onTap: () async {
                  await controller.pickEndDateTime(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.endTime.value != null
                            ? DateFormat('dd MMM yyyy, hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    controller.endTime.value!))
                            : "Select end time",
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // OTHER TEXT FIELDS
              CustomTextField(
                  controller: controller.tripsController,
                  label: "Total Trips",
                  keyboard: TextInputType.number),
              CustomTextField(
                  controller: controller.earningsController,
                  label: "Total Earnings",
                  keyboard: TextInputType.number),
              CustomTextField(
                  controller: controller.cashCollectedController,
                  label: "Cash Collected",
                  keyboard: TextInputType.number),
              CustomTextField(
                  controller: controller.tollController,
                  label: "Toll",
                  keyboard: TextInputType.number),
              CustomTextField(
                  controller: controller.fuelController,
                  label: "Fuel Expense",
                  keyboard: TextInputType.number),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value
                      ? null
                      : () async => await controller.submitDuty(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Duty",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboard;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
