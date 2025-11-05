import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/fleetPages/fleet_info.dart';
import 'package:zero/appModules/profile/profile_controller.dart';
import 'package:zero/appModules/profile/user_info.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class UserProfilePage extends StatelessWidget {
  final ProfileController controller = Get.isRegistered()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());
  UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (currentUser!.userRole == 'DRIVER')
                  _buildStatsCards(context),
                if (currentUser!.fleetId != null) _fleetDetails(),
                settingsOptions(),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      'App version : $appVersion',
                      style: Get.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final percent =
              (constraints.maxHeight - kToolbarHeight) / kToolbarHeight;
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 10),
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: percent < 0.5 ? 1.0 : 0.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: currentUser!.profilePicUrl.isNotEmpty
                      ? NetworkImage(currentUser!.profilePicUrl)
                      : null,
                  child: currentUser!.profilePicUrl.isEmpty
                      ? Text(
                          currentUser!.fullName[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(
                  currentUser!.fullName,
                  style: Get.textTheme.titleLarge,
                ),
              ),
            ),
            background: Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: ColorConst.primaryColor, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: currentUser!.profilePicUrl.isNotEmpty
                            ? NetworkImage(currentUser!.profilePicUrl)
                            : null,
                        child: currentUser!.profilePicUrl.isEmpty
                            ? Text(
                                currentUser!.fullName[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentUser!.fullName,
                            style: Get.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            // currentUser!.email ?? currentUser!.phoneNumber,
                            currentUser!.phoneNumber,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: Get.textTheme.titleSmall!
                                .copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubheading(
            icon: Icons.workspace_premium_outlined, title: 'Personal progress'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Duties',
                '${currentUser!.earningDetails == null ? 0 : currentUser!.earningDetails!.totalDuties}',
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Trips',
                '${currentUser!.earningDetails == null ? 0 : currentUser!.earningDetails!.totalTrips}',
                Colors.orange,
              ),
            ),
          ],
        ),
        _buildStatCard(
          context,
          'Total balance',
          '₹ ${currentUser!.earningDetails == null ? 0.0 : currentUser!.earningDetails!.totalBalance.toStringAsFixed(2)}',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: ColorConst.secondaryButton),
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fleetDetails() {
    bool isOwner = currentUser!.uid == currentFleet!.ownerId;
    return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: ColorConst.secondaryButton),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            _buildSubheading(
                title: isOwner ? 'Your Fleet' : 'Current Fleet',
                icon: Icons.home_work_outlined),
            Card(
              child: ListTile(
                  leading: const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.directions_car, color: Colors.grey),
                  ),
                  title: Text(currentFleet!.fleetName),
                  subtitle: Text(
                    currentFleet!.officeAddress,
                    style:
                        Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: isOwner
                  ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromWidth(w),
                                foregroundColor: Colors.white),
                            onPressed: () =>
                                Get.to(() => const FleetInfoPage()),
                            label: const Text('Edit'),
                            icon: const Icon(Icons.edit),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size.fromWidth(w),
                                foregroundColor: Colors.red),
                            onPressed: () => Get.dialog(AlertDialog(
                              title: const Text('Delete fleet?'),
                              content: const Text(
                                  'Are you sure you want to permenently delete this Fleet?. This action cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('No, Cancel')),
                                TextButton(
                                    onPressed: () {
                                      if (currentFleet!.drivers!.isNotEmpty) {
                                        Fluttertoast.showToast(
                                            msg:
                                                'Remove all drivers before deleting',
                                            backgroundColor: Colors.red);
                                      } else {
                                        controller.deleteFleet();
                                      }
                                    },
                                    child: const Text('Yes, Confirm')),
                              ],
                            )),
                            label: const Text('Delete fleet'),
                            icon: const Icon(Icons.delete_forever),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromWidth(w),
                          foregroundColor: Colors.red),
                      onPressed: () {
                        if (currentUser!.onDuty != null) {
                          Fluttertoast.showToast(
                              msg:
                                  'Please end current duty before leaving this Fleet!',
                              backgroundColor: Colors.red);
                        } else if (currentUser!.wallet < 0) {
                          Fluttertoast.showToast(
                              msg:
                                  'Please clear your wallet before leaving this Fleet!',
                              backgroundColor: Colors.red);
                        } else {
                          Get.dialog(AlertDialog(
                            title: const Text('Leave fleet?'),
                            content: const Text(
                                'Are you sure you want to leave this Fleet?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('No, cancel')),
                              TextButton(
                                  onPressed: () => controller.leaveFleet(),
                                  child: const Text('Yes, confirm')),
                            ],
                          ));
                        }
                      },
                      label: const Text('Leave fleet'),
                      icon: const Icon(Icons.login_outlined),
                    ),
            ),
          ],
        ));
  }

  Widget settingsOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubheading(title: 'Legal', icon: Icons.file_copy_outlined),
        _buildOptions(label: 'Terms & conditions', onTap: () {}),
        _buildOptions(label: 'Privacy Policy', onTap: () {}),
        _buildOptions(label: 'About us', onTap: () {}),
        _buildSubheading(
            title: 'Account settings', icon: Icons.account_circle_outlined),
        _buildOptions(
            label: 'Personal info',
            onTap: () => Get.to(() => const UserInfoPage())),
        _buildOptions(
            label: 'Delete account',
            onTap: () async {
              if (currentUser!.onDuty != null) {
                Fluttertoast.showToast(
                    msg: 'Please end the current duty before deleting account',
                    backgroundColor: Colors.red);
                return;
              }
              if (currentUser!.wallet < 0) {
                Fluttertoast.showToast(
                    msg: 'Please clear your wallet before deleting account',
                    backgroundColor: Colors.red);
                return;
              }
              final confirm = await Get.dialog(AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                    'Are you sure you want to permanently delete your account?'),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('No, Cancel')),
                  TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Yes, confirm')),
                ],
              ));
              if (confirm == true) {
                controller.deleteUser();
              }
            }),
        _buildOptions(
          label: 'Logout',
          onTap: () {
            if (currentUser!.onDuty != null) {
              Fluttertoast.showToast(
                  msg: 'Please end the current duty before logging out',
                  backgroundColor: Colors.red);
              return;
            }
            Get.dialog(
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
                ));
          },
        )
      ],
    );
  }

  Widget _buildOptions(
      {required String label, required void Function() onTap}) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          title: Text(label),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: Colors.white24,
          ),
        ),
        const Divider(
          color: Colors.white12,
          indent: 20,
        )
      ],
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
              style: Get.textTheme.titleLarge!
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
