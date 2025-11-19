import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/dutyPages/duty_controller.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/customWidgets/slider_widget.dart';
import 'package:zero/models/user_model.dart';

class DutyPage extends StatelessWidget {
  final DutyController controller = Get.isRegistered()
      ? Get.find<DutyController>()
      : Get.put(DutyController());
  DutyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverOnDuty duty = currentUser!.onDuty!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: controller.formkey,
          child: Column(children: [
            Text(
              duty.vehicleNumber,
              style: Get.textTheme.titleLarge,
            ),
            Card(
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidgets().textRow(
                        label: 'Started time',
                        value: DateFormat('EEE dd/MMM, hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                duty.startTime))),
                    CustomWidgets().textRow(
                        label: 'End by',
                        value: DateFormat('EEE dd/MMM, hh:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(duty.startTime)
                                .add(
                                    Duration(hours: duty.selectedShift * 12)))),
                    CustomWidgets().textRow(
                        label: 'Selected shift',
                        value: "${duty.selectedShift * 12} hrs")
                  ],
                ),
              ),
            ),
            // OutlinedButton.icon(
            //   onPressed: () => controller.extractUberDutyData(),
            //   icon: const Icon(Icons.image_search_rounded),
            //   label: const Text('Upload screenshot'),
            // ),
            Column(
              children: [
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
                  labelText: 'Total fare',
                  hint: 'Suggested fare + Tip',
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
              ],
            ),
            _textField(
              textInputType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Fuel Expense (optional)',
              textController: controller.fuelExpenseController,
              validator: (value) {
                if (!RegExp(r'^\d*\.?\d*$').hasMatch(value!)) {
                  return 'Only numbers are allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SlideToConfirm(
              label: 'End duty',
              onConfirmed: () async {
                bool isDriverReached = await controller.isDriverinLocation();
                if (!controller.formkey.currentState!.validate()) {
                  return false;
                } else if (!isDriverReached) {
                  Fluttertoast.showToast(
                      msg:
                          'You\'re not at the location!. Go to your fleet parking location before ending duty.',
                      backgroundColor: Colors.red);
                  return false;
                } else {
                  await controller.endDuty(duty: duty);
                  if (controller.finalValues.isNotEmpty) {
                    _showSummary();
                  }
                  return true;
                }
              },
            ),
            const SizedBox(height: 20),
          ]),
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
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
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
            hintText: hint,
            counterText: '',
            fillColor: Colors.white12,
            label: Text(labelText),
            labelStyle:
                Get.textTheme.bodyMedium!.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showSummary() {
    double topay = controller.finalValues['total_to_pay'];
    double totalEarnings =
        double.parse(controller.totalEarningsController.text) -
            controller.finalValues['other_fees'];
    double balance = totalEarnings -
        controller.finalValues['vehicle_rent'] -
        double.parse(controller.fuelExpenseController.text.isEmpty
            ? '0'
            : controller.fuelExpenseController.text);
    Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: const Text('Duty summary'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomWidgets().textRow(
                    label: 'Your earnings',
                    value: controller.totalEarningsController.text),
                CustomWidgets().textRow(
                    label: 'Other fees (-14%)',
                    value:
                        "-${controller.finalValues['other_fees'].toStringAsFixed(2)}"),
                const Divider(color: Colors.grey),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02, vertical: w * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Earnings',
                          style: Get.textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        totalEarnings.toStringAsFixed(2),
                        style: Get.textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                CustomWidgets().textRow(
                    label: 'Toll', value: controller.tollController.text),
                CustomWidgets().textRow(
                    label: 'Cash collected',
                    value: '-${controller.cashCollectedController.text}'),
                CustomWidgets().textRow(
                    label: 'Vehicle rent',
                    value: "-${controller.finalValues['vehicle_rent']}"),
                if (controller.fuelExpenseController.text.isNotEmpty)
                  CustomWidgets().textRow(
                      label: 'Fuel expenses',
                      value: "-${controller.fuelExpenseController.text}"),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02, vertical: w * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('YOUR BALANCE'),
                      Text(
                        balance.toStringAsFixed(2),
                        style: Get.textTheme.bodyMedium!.copyWith(
                            color: balance < 0 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(topay < 0 ? 'To pay' : 'To get'),
                      Text(
                        topay.toStringAsFixed(2),
                        style: Get.textTheme.bodyMedium!.copyWith(
                            color: topay >= 0 ? Colors.green : Colors.red),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: OutlinedButton(
                      onPressed: () {
                        Get.offAllNamed('/splash');
                      },
                      child: const Text('Done')),
                ),
              ],
            )
          ],
        ));
  }
}
