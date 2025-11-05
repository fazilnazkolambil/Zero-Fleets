import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/fleetPages/fleet_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class FleetInfoPage extends StatelessWidget {
  const FleetInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FleetController controller = Get.isRegistered()
        ? Get.find<FleetController>()
        : Get.put(FleetController());
    controller.loadFleetData();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet info'),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (controller.formkey.currentState!.validate()) {
                            controller.updateFleet();
                          }
                        },
                  child: controller.isLoading.value
                      ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      : const Text('Update')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Form(
          key: controller.formkey,
          child: Column(
            children: [
              CustomWidgets().textField(
                textInputType: TextInputType.text,
                hintText: 'Your Fleet name',
                label: 'Fleet name',
                textController: controller.fleetNameController,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your Fleet name';
                  } else {
                    return null;
                  }
                },
              ),
              CustomWidgets().textField(
                textInputType: TextInputType.number,
                hintText: 'Contact number',
                label: 'Contact number',
                textController: controller.contactNumberController,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('+91'),
                ),
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Mobile number';
                  }
                  if (value.length != 10) {
                    return 'Enter a valid Mobile number';
                  }
                  return null;
                },
              ),
              CustomWidgets().textField(
                textInputType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                hintText:
                    'Apartment, street name, Town, District, State, Zipcode.',
                label: 'Office address',
                maxLines: 3,
                textController: controller.officeAddressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Office address';
                  }
                  return null;
                },
              ),
              const Divider(color: Colors.white12),
              CustomWidgets().textField(
                textInputType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                hintText: 'exampleupi@bank',
                label: 'UPI address',
                textController: controller.upiController,
                validator: (value) {
                  if (!RegExp(r'^[\w.\-_]{2,256}@[a-zA-Z]{2,64}$')
                      .hasMatch(value!)) {
                    return 'Please enter a valid UPI address';
                  }
                  return null;
                },
              ),
              CustomWidgets().textField(
                textInputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                hintText: 'Banking name',
                label: 'Banking Name',
                textController: controller.bankingNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Banking name';
                  }
                  return null;
                },
              ),
              const Divider(color: Colors.white12),
              CustomWidgets().textField(
                readOnly: true,
                label: 'Parking location',
                textInputType: TextInputType.number,
                hintText: 'Latitude, Longitude',
                textController: controller.latLongController,
                suffixIcon: TextButton(
                    onPressed: () => Get.dialog(
                        barrierDismissible: false,
                        Obx(
                          () => AlertDialog(
                            title: const Text('Fetch current location?'),
                            content: const Text(
                              'This location will be saved as the vehicle parking location. Drivers can only Start or End duty within 1km from this location.',
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('No, cancel')),
                              TextButton(
                                  onPressed: () async {
                                    await controller.getLocation();
                                    Get.back();
                                  },
                                  child: controller.isLoading.value
                                      ? const CupertinoActivityIndicator()
                                      : const Text('Yes, confirm')),
                            ],
                          ),
                        )),
                    child: const Text('Re fetch')),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tap on the fetch location button';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('TARGET TRIPS'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: w * 0.45,
                    child: CustomWidgets().textField(
                        textInputType: TextInputType.number,
                        hintText: 'per shift',
                        maxLength: 2,
                        label: 'Driver\'s target',
                        textController: controller.driverTargetTrips),
                  ),
                  SizedBox(
                    width: w * 0.45,
                    child: CustomWidgets().textField(
                        textInputType: TextInputType.number,
                        hintText: 'per week',
                        maxLength: 3,
                        label: 'Vehicle\'s target',
                        textController: controller.vehicleTargetTrips),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
