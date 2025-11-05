import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/driverPages/driver_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class AddDriverPage extends StatelessWidget {
  const AddDriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invite Driver"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Enter the driver's phone number to send an invitation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            CustomWidgets().textField(
                textInputType: TextInputType.number,
                hintText: 'Enter driver\'s phone number',
                label: 'Driver\'s phone number',
                textController: controller.phoneController,
                maxLength: 10,
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text('+91'),
                )),

            const SizedBox(height: 16),
            // Search button
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.searchDriver,
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(200),
                      backgroundColor: ColorConst.primaryColor,
                      foregroundColor: Colors.black),
                  child: controller.isLoading.value
                      ? const CupertinoActivityIndicator(color: Colors.black)
                      : const Text("Search Driver"),
                )),

            const SizedBox(height: 24),

            // Search result
            Obx(() {
              if (controller.isLoading.value ||
                  controller.phoneController.text.isEmpty) {
                return const SizedBox();
              }
              if (controller.foundUser.value == null) {
                return const Column(
                  children: [
                    Icon(Icons.person_search, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "No driver found with this number.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
//                     OutlinedButton.icon(
//                       onPressed: () async {
//                         String message = '''Hey 👋,

// You're invited to join our fleet on the Zero Fleet app!

// Use the link below to register and get started:
// 👉 https://play.google.com/store/apps/details?id=com.ubercab.driver

// - ${currentUser!.fullName}
// Fleet Owner | ${currentFleet!.fleetName}''';
//                         final url = Uri.parse(
//                             "https://wa.me/${controller.phoneController.text}?text=${Uri.encodeComponent(message)}");
//                         if (await canLaunchUrl(url)) {
//                           await launchUrl(url,
//                               mode: LaunchMode.externalApplication);
//                         } else {
//                           Fluttertoast.showToast(
//                               msg: 'Could not open WhatsApp');
//                         }
//                       },
//                       icon: const Icon(Icons.share),
//                       label: const Text("Invite via WhatsApp"),
//                     )
                  ],
                );
              } else {
                final user = controller.foundUser.value!;
                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: InkWell(
                          onTap: () {
                            Get.dialog(AlertDialog(
                              content: Image(
                                  image: NetworkImage(user.profilePicUrl)),
                            ));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white10,
                            backgroundImage: NetworkImage(user.profilePicUrl),
                          ),
                        ),
                        title: Text(user.fullName,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text("+91${user.phoneNumber}",
                            style: const TextStyle(color: Colors.grey)),
                      ),
                      const Divider(color: Colors.white10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                Get.dialog(AlertDialog(
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const Text('Driving licence'),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 150,
                                          width: double.maxFinite,
                                          child: Image(
                                              image:
                                                  NetworkImage(user.licenceUrl),
                                              fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text('Aadhaar'),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          height: 150,
                                          width: double.maxFinite,
                                          child: Image(
                                              image:
                                                  NetworkImage(user.aadhaarUrl),
                                              fit: BoxFit.cover),
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                              },
                              child: const Text('View Documents')),
                          Obx(
                            () => controller.sendingInvitation.value
                                ? const SizedBox(
                                    width: 150,
                                    child: CupertinoActivityIndicator())
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size.fromWidth(150)),
                                    onPressed: () =>
                                        controller.sendInvite(user.uid),
                                    child: const Text('Send invite')),
                          )
                        ],
                      )
                    ],
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
