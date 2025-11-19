import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/splash_screen.dart';
import 'package:zero/appModules/home/drawer_page.dart';
import 'package:zero/appModules/home/home_controller.dart';
import 'package:zero/appModules/wallet/wallet_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/core/subscriptionsController.dart';

class HomeNavigationPage extends StatelessWidget {
  final HomeController controller = Get.isRegistered()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  final SubscriptionsController subs = Get.isRegistered()
      ? Get.find<SubscriptionsController>()
      : Get.put(SubscriptionsController());
  HomeNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    final user = subs.user.value;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          Get.dialog(
            AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('No, Cancel'),
                ),
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Yes, Confirm'),
                ),
              ],
            ),
          );
        },
        child: Obx(() {
          if (!subs.isUserLoaded.value) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: AnimatedSplashLogo(),
              ),
            );
          }
          return Scaffold(
              drawer: controller.homePages.length > 4 ? DrawerPage() : null,
              appBar: AppBar(
                leading: controller.homePages.length > 4
                    ? Builder(builder: (context) {
                        return IconButton(
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                            icon: const Icon(Icons.menu));
                      })
                    : null,
                title: Obx(() => Text(
                    "${controller.homePages[controller.currentIndex.value]['label']}")),
                actions: [
                  Obx(() {
                    if (!subs.isUserLoaded.value) {
                      return IconButton(
                        onPressed: () => Get.offAllNamed('/splash'),
                        icon: const Icon(Icons.refresh_outlined),
                      );
                    }

                    final user = subs.user.value;
                    if (user != null && user.userRole == 'DRIVER') {
                      return IconButton(
                        onPressed: () => Get.to(() => WalletPage()),
                        icon: Icon(
                          Icons.wallet,
                          color: user.wallet < 0 ? Colors.red : Colors.white,
                        ),
                      );
                    }

                    return const SizedBox();
                  }),
                ],
              ),
              bottomNavigationBar: controller.homePages.length > 4
                  ? null
                  : Container(
                      height: 65,
                      width: w,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          // color: Get.theme.cardColor,
                          border: Border(
                              top: BorderSide(color: Colors.grey[900]!))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          controller.homePages.length,
                          (index) => Obx(
                            () => _buildBottomBarItems(
                              icon: controller.homePages[index]['icon'],
                              label: controller.homePages[index]['label'],
                              notification: controller.homePages[index]
                                  ['notification'],
                              isSelected:
                                  controller.currentIndex.value == index,
                              onTap: () {
                                // controller.currentIndex.value = index;
                                controller.changeIndex(index);
                              },
                            ),
                          ),
                        ),
                      )),
              body: Obx(() {
                return controller.homePages[controller.currentIndex.value]
                    ['page'];
              }));
        }));
  }

  Widget _buildBottomBarItems(
      {required bool isSelected,
      required IconData icon,
      required String label,
      bool? notification,
      required void Function() onTap}) {
    Color color = isSelected ? Colors.white : Colors.grey[600]!;
    return Expanded(
      child: InkWell(
        overlayColor: const WidgetStatePropertyAll(Colors.grey),
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: color,
                ),
                if (notification == true && notificationCounts > 0)
                  const Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(Icons.circle, color: Colors.red, size: 12)),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: Get.textTheme.bodySmall!.copyWith(color: color),
            )
          ],
        ),
      ),
    );
  }
}
