import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/home/home_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';

class DrawerPage extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();
  final SubscriptionsController subs = Get.isRegistered()
      ? Get.find<SubscriptionsController>()
      : Get.put(SubscriptionsController());
  DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = subs.user.value!;
    final fleet = subs.fleet.value!;
    return Drawer(
      backgroundColor: Get.theme.cardColor,
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Get.theme.primaryColor,
                      radius: 30,
                      child: Center(
                          child: Text(
                        user.fullName[0].toUpperCase(),
                        style: Get.textTheme.headlineSmall,
                      )),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: Get.textTheme.bodyLarge!,
                          ),
                          Text(
                            fleet.fleetName,
                            style: Get.textTheme.bodySmall!,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: ListView.builder(
              itemCount: controller.homePages.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool isSelected = controller.currentIndex.value == index;
                return ListTile(
                  onTap: () => controller.changeIndex(index),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(controller.homePages[index]['label']),
                      const SizedBox(width: 5),
                      if (controller.homePages[index]['notification'] == true &&
                          notificationCounts > 0)
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text("$notificationCounts",
                              style: Get.textTheme.bodySmall!),
                        )
                      // const Icon(Icons.circle, color: Colors.red, size: 12)
                    ],
                  ),
                  titleTextStyle: Get.textTheme.bodyLarge!.copyWith(
                      color: isSelected ? ColorConst.primaryColor : null,
                      fontWeight: isSelected ? FontWeight.bold : null),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => Get.dialog(
                barrierDismissible: false,
                AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('No, cancel')),
                    TextButton(
                        onPressed: () async =>
                            Get.put(AuthController()).logoutUser(),
                        child: const Text('Yes, confirm')),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
