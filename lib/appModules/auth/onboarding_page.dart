import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/auth/onboarding_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/appModules/auth/image_upload.dart';

class OnboardingPage extends GetView<AuthController> {
  final OnboardingController onboardingController = Get.isRegistered()
      ? Get.find<OnboardingController>()
      : Get.put(OnboardingController());
  OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => onboardingController.pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: Obx(
          () => PageView(
            controller: onboardingController.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLandingPage(),
              if (onboardingController.selectedMainFlow.value == "driver")
                ..._buildDriverPages(),
              if (onboardingController.selectedMainFlow.value == "fleet")
                ..._buildFleetPages(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandingPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "What brings you here?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Are you here to start your own fleet and run a business, or to find a fleet and start driving?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              onboardingController.selectedMainFlow.value = "driver";
              onboardingController.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(w),
              padding: const EdgeInsets.all(14),
            ),
            child: const Text("I'm a Driver"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              onboardingController.selectedMainFlow.value = "fleet";
              onboardingController.pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromWidth(w),
              padding: const EdgeInsets.all(14),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text("I'm a fleet owner"),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDriverPages() {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "How do you want to start driving?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Choose whether you'll drive using your own vehicle, or join a fleet where cars are provided by the owner",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                onboardingController.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromWidth(w),
                padding: const EdgeInsets.all(14),
              ),
              child: const Text("I have my own Vehicle"),
            ),
            const SizedBox(height: 12),
            Obx(
              () => ElevatedButton(
                onPressed: onboardingController.isLoading.value
                    ? null
                    : () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser!.uid)
                            .update({'user_role': 'USER'});
                        // currentUser = currentUser!.copyWith(userRole: 'USER');
                        Get.offAllNamed('/splash');
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size.fromWidth(w),
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: onboardingController.isLoading.value
                    ? const CupertinoActivityIndicator(
                        color: Colors.black,
                      )
                    : const Text("Join a Fleet"),
              ),
            ),
          ],
        ),
      ),
      _vehicleDetails()
    ];
  }

  List<Widget> _buildFleetPages() {
    return [_fleetDetails()];
  }

  Widget _vehicleDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: onboardingController.formkey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Add Your Vehicle Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your car details to begin driving and tracking your earnings.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            CustomWidgets().textField(
                textInputType: TextInputType.text,
                hintText: 'AA00BB1111',
                maxLength: 10,
                label: 'Number plate',
                textController: onboardingController.numberPlateController,
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
              textController: onboardingController.vehicleModelController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your vehicle\'s model';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 10),
            ImageUpload(
              label: 'Vehicle Image',
              uploadLabel: 'vehicle_image',
              controller: controller,
              folderName: 'Vehicle images',
            ),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromWidth(w),
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  onPressed: onboardingController.isLoading.value
                      ? null
                      : () {
                          if (onboardingController.formkey.currentState!
                              .validate()) {
                            Get.dialog(AlertDialog(
                              content: const Text(
                                  'This feature will be available soon. Continue as a driver or start your own Fleet!',
                                  textAlign: TextAlign.center),
                              actions: [
                                TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Ok'))
                              ],
                            ));
                            //TODO: DO THIS AFTER SETTING UP FLEET AND DRIVER

                            // onboardingController.createVehicle(
                            //     vehicleImage: controller
                            //         .uploads['vehicle_image']['image_url']);
                          }
                        },
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      : const Text('Confirm')),
            )
          ],
        ),
      ),
    );
  }

  Widget _fleetDetails() {
    return SingleChildScrollView(
      child: Form(
        key: onboardingController.formkey,
        child: Column(
          children: [
            const Text(
              "Set up your Fleet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your fleet details to manage cars, drivers, and daily operations all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
            _buildSubheading(
                icon: Icons.home_work_outlined, title: 'Basic details'),
            CustomWidgets().textField(
              textInputType: TextInputType.text,
              hintText: 'Your Fleet name',
              label: 'Fleet name',
              textController: onboardingController.fleetNameController,
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
              textController: onboardingController.contactNumberController,
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
            const Divider(color: Colors.white12),
            _buildSubheading(
                title: 'Location', icon: Icons.location_on_outlined),
            CustomWidgets().textField(
              textInputType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              hintText: 'Street name, Town, District, State, Zipcode.',
              label: 'Office address',
              maxLines: 3,
              textController: onboardingController.officeAddressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Office address';
                }
                return null;
              },
            ),
            CustomWidgets().textField(
              readOnly: true,
              label: 'Parking location',
              textInputType: TextInputType.number,
              hintText: 'Latitude, Longitude',
              textController: onboardingController.latLongController,
              suffixIcon: Obx(() => TextButton(
                  onPressed: () => Get.dialog(
                      barrierDismissible: false,
                      AlertDialog(
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
                                await onboardingController.getLocation();
                                Get.back();
                              },
                              child: const Text('Yes, confirm')),
                        ],
                      )),
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator()
                      : const Text('Fetch'))),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tap on the fetch location button';
                }
                return null;
              },
            ),
            // const Divider(color: Colors.white12),
            // _buildSubheading(
            //     title: 'Banking details', icon: Icons.attach_money),
            // CustomWidgets().textField(
            //   textInputType: TextInputType.emailAddress,
            //   textCapitalization: TextCapitalization.none,
            //   hintText: 'exampleupi@bank',
            //   label: 'Merchant UPI',
            //   textController: onboardingController.upiController,
            //   validator: (value) {
            //     if (value!.isEmpty) {
            //       return null;
            //     }
            //     if (!CustomWidgets().isMerchantUpi(value)) {
            //       return 'Please enter a valid merchant UPI address';
            //     }
            //     return null;
            //   },
            // ),
            // CustomWidgets().textField(
            //   textInputType: TextInputType.name,
            //   textCapitalization: TextCapitalization.words,
            //   hintText: 'Banking name',
            //   label: 'Banking Name',
            //   textController: onboardingController.bankingNameController,
            // ),
            const Divider(color: Colors.white12),
            _buildSubheading(title: 'Fleet targets', icon: Icons.track_changes),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: w * 0.45,
                  child: CustomWidgets().textField(
                      textInputType: TextInputType.number,
                      hintText: 'per shift',
                      maxLength: 2,
                      label: 'Driver\'s trip target',
                      textController: onboardingController.driverTargetTrips),
                ),
                SizedBox(
                  width: w * 0.45,
                  child: CustomWidgets().textField(
                      textInputType: TextInputType.number,
                      hintText: 'per week',
                      maxLength: 3,
                      label: 'Vehicle\'s target',
                      textController: onboardingController.vehicleTargetTrips),
                )
              ],
            ),
            Row(
              children: [
                Obx(
                  () => Checkbox(
                    activeColor: ColorConst.primaryColor,
                    checkColor: Colors.black,
                    value: onboardingController.isFleetHiring.value,
                    onChanged: (value) {
                      onboardingController.isFleetHiring.toggle();
                    },
                  ),
                ),
                const Text("I'm looking for drivers")
              ],
            ),
            const SizedBox(height: 30),
            Obx(
              () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromWidth(w * 0.8),
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  onPressed: onboardingController.isLoading.value
                      ? null
                      : () {
                          if (onboardingController.formkey.currentState!
                              .validate()) {
                            onboardingController.createfleet();
                          }
                        },
                  child: onboardingController.isLoading.value
                      ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                      : const Text('Confirm')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSubheading({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(title,
              style: Get.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
