import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/driverPages/driver_controller.dart';
import 'package:zero/appModules/dutyPages/duty_controller.dart';
import 'package:zero/appModules/vehiclePages/vehicle_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/duty_model.dart';
import 'package:zero/models/user_model.dart';
import 'package:zero/models/vehicle_model.dart';

class AddDutyPage extends StatelessWidget {
  final DutyController controller = Get.put(DutyController());
  final DutyModel? dutymodel;
  AddDutyPage({super.key, this.dutymodel}) {
    if (dutymodel != null) {
      controller.autoFillData(dutymodel!);
    }
  }

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;
    bool isEdit = dutymodel != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? "Edit ${dutymodel!.driverName}'s Duty" : "Add New Duty"),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: controller.formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                      "Select duty time - (${controller.endTime.value == null ? 0 : controller.dutyHours.value == '12 hrs' ? 1 : 2} shift)",
                      style: Get.textTheme.bodyMedium),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: controller.isValidate.value
                                ? Colors.white24
                                : Colors.red)),
                    height: 55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            await controller.pickStartDateTime(context);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.date_range_rounded,
                                  color: !controller.isValidate.value &&
                                          controller.startTime.value == null
                                      ? Colors.red
                                      : null),
                              const SizedBox(width: 5),
                              Text(
                                controller.startTime.value != null
                                    ? DateFormat('dd/MM - hh:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            controller.startTime.value!))
                                    : "Start time",
                                style: Get.textTheme.bodyMedium!.copyWith(
                                    color: controller.startTime.value == null
                                        ? Colors.grey
                                        : null),
                              ),
                            ],
                          ),
                        ),
                        const Text('-'),
                        InkWell(
                          onTap: () async {
                            await controller.pickEndDateTime(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range_rounded,
                                color: !controller.isValidate.value &&
                                        controller.endTime.value == null
                                    ? Colors.red
                                    : null,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                controller.endTime.value != null
                                    ? DateFormat('dd/MM - hh:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            controller.endTime.value!))
                                    : "End time",
                                style: Get.textTheme.bodyMedium!.copyWith(
                                    color: controller.endTime.value == null
                                        ? Colors.grey
                                        : null),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!isEdit) ...[
                  DropdownButtonFormField<UserModel>(
                    borderRadius: BorderRadius.circular(12),
                    hint: Text('Select Driver',
                        style: Get.textTheme.bodyMedium!
                            .copyWith(color: Colors.grey)),
                    style:
                        Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
                    value: controller.selectedDriver.value,
                    items: Get.put(DriverController()).driverList.map((driver) {
                      return DropdownMenuItem(
                        value: driver,
                        child: Text(driver.fullName),
                      );
                    }).toList(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a vehicle';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) =>
                        controller.selectedDriver.value = value,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<VehicleModel>(
                    hint: Text('Select Vehicle',
                        style: Get.textTheme.bodyMedium!
                            .copyWith(color: Colors.grey)),
                    style:
                        Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
                    value: controller.selectedVehicle.value,
                    items: Get.put(VehicleController()).vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle.numberPlate),
                      );
                    }).toList(),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a vehicle';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      controller.selectedVehicle.value = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                _textField(
                  textInputType: TextInputType.number,
                  labelText: 'Total trips',
                  textController: controller.totalTripsController,
                  maxLength: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total trips';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Only numbers are allowed';
                    }
                    return null;
                  },
                ),
                _textField(
                  textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Total fair',
                  textController: controller.totalEarningsController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your total fair';
                    } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return 'Only numbers are allowed';
                    }
                    return null;
                  },
                ),
                _textField(
                  textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Toll',
                  textController: controller.tollController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the toll';
                    } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return 'Only numbers are allowed';
                    }
                    return null;
                  },
                ),
                _textField(
                  textInputType:
                      const TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Cash collected',
                  textController: controller.cashCollectedController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the cash collected';
                    } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return 'Only numbers are allowed';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // SUBMIT BUTTON
                Center(
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            if (controller.formkey.currentState!.validate() &&
                                controller.startTime.value != null &&
                                controller.endTime.value != null) {
                              isEdit
                                  ? await controller.editDuty(
                                      dutyId: dutymodel!.dutyId)
                                  : await controller.addDuty(
                                      userId:
                                          controller.selectedDriver.value!.uid);
                            } else {
                              controller.isValidate.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryColor,
                        foregroundColor: Colors.black,
                        fixedSize: Size.fromWidth(w * 0.8)),
                    child: Text(isEdit ? "Update duty" : "Add Duty"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    String? Function(String?)? validator,
    required TextInputType textInputType,
    required String labelText,
    required TextEditingController textController,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: textController,
        style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
        cursorColor: Colors.white,
        textInputAction: TextInputAction.next,
        keyboardType: textInputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        validator: validator,
        maxLength: maxLength,
        decoration: InputDecoration(
            counterText: '',
            fillColor: Colors.white12,
            label: Text(labelText),
            labelStyle: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey)),
      ),
    );
  }
}
