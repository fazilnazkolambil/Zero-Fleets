import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/vehicle_model.dart';

class AddVehiclePage extends StatelessWidget {
  final VehicleModel? vehicle;
  const AddVehiclePage({super.key, this.vehicle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VehicleController());
    bool isEdit = vehicle != null;
    if (isEdit) {
      controller.numberPlateController.text = vehicle!.numberPlate;
      controller.vehicleModelController.text = vehicle!.vehicleModel;
      // controller.targetTrips.text = vehicle!.targetTrips.toString();
      print(vehicle!.vehicleRent);
      if (vehicle!.vehicleRent is List) {
        controller.rentType.value = 'perTrip';
        for (int i = 0; i < vehicle!.vehicleRent.length; i++) {
          Map<String, dynamic> rentList = vehicle!.vehicleRent[i];
          controller.rentRules.addIf(
              controller.rentRules.length < vehicle!.vehicleRent.length,
              RuleModel());
          controller.rentRules[i].minController.text =
              rentList['min_trips'].toString();
          controller.rentRules[i].rentController.text =
              rentList['rent'].toString();
        }
      } else {
        controller.fixedRentController.text = vehicle!.vehicleRent.toString();
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? vehicle!.numberPlate : "Add Vehicle"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConst.primaryColor,
                    foregroundColor: Colors.black),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (controller.formkey.currentState!.validate()) {
                          isEdit
                              ? controller.editVehicle(
                                  vehicleId: vehicle!.vehicleId)
                              : controller.createVehicle();
                        }
                      },
                child: controller.isLoading.value
                    ? const CupertinoActivityIndicator(
                        color: Colors.black,
                      )
                    : Text(isEdit ? "Update" : "Add"),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidgets().textField(
                  textInputType: TextInputType.text,
                  hintText: 'AA00BB1111',
                  maxLength: 10,
                  label: 'Number plate',
                  textController: controller.numberPlateController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter vehicle number';
                    }

                    final input = value.toUpperCase().replaceAll(' ', '');
                    final RegExp pattern =
                        RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{1,4}$');

                    if (!pattern.hasMatch(input)) {
                      return 'Enter a valid vehicle number';
                    }

                    return null;
                  }),
              CustomWidgets().textField(
                textInputType: TextInputType.text,
                hintText: 'Maruti Suzuki WagonR',
                label: 'Vehicle model',
                textController: controller.vehicleModelController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your vehicle\'s model';
                  } else {
                    return null;
                  }
                },
              ),
              // CustomWidgets().textField(
              //   textInputType: TextInputType.number,
              //   maxLength: 3,
              //   hintText: 'Target trips per week',
              //   label: 'Target trips',
              //   textController: controller.targetTrips,
              //   validator: (value) {
              //     if (value!.isEmpty) {
              //       return 'Please enter vehicle\'s target trips';
              //     } else {
              //       return null;
              //     }
              //   },
              // ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Rent Type",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Obx(() => Row(
                          children: [
                            Radio(
                              value: "fixed",
                              activeColor: ColorConst.primaryColor,
                              groupValue: controller.rentType.value,
                              onChanged: (v) => controller.rentType.value = v!,
                            ),
                            const Text("Fixed Rent"),
                            Radio(
                              value: "perTrip",
                              activeColor: ColorConst.primaryColor,
                              groupValue: controller.rentType.value,
                              onChanged: (v) => controller.rentType.value = v!,
                            ),
                            const Text("Per Trip Rent"),
                          ],
                        )),
                    Obx(() {
                      if (controller.rentType.value == "fixed") {
                        return _textField(
                            textController: controller.fixedRentController,
                            hintText: 'Rent per shift');
                      } else {
                        return _buildRentRuleBuilder(controller);
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentRuleBuilder(VehicleController controller) {
    return Obx(() => Column(
          children: [
            for (int i = 0; i < controller.rentRules.length; i++)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                          child: _textField(
                              textController:
                                  controller.rentRules[i].minController,
                              hintText: "Min Trips")),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _textField(
                              textController:
                                  controller.rentRules[i].rentController,
                              hintText: 'Rent')),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => controller.rentRules.removeAt(i),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => controller.rentRules.add(RuleModel()),
                icon: const Icon(Icons.add),
                label: const Text("Add Rent Rule"),
              ),
            ),
          ],
        ));
  }

  Widget _textField(
      {required TextEditingController textController,
      required String hintText}) {
    return TextFormField(
      controller: textController,
      style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
      cursorColor: Colors.white,
      keyboardType: TextInputType.number,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: TextInputAction.next,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: (value) {
        if (value!.isEmpty) {
          return '';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        fillColor: Colors.white12,
        hintText: hintText,
      ),
    );
  }
}
