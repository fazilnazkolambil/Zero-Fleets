import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zero/appModules/inbox/inbox_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/notification_model.dart';

class InboxPage extends StatelessWidget {
  InboxPage({super.key});
  final InboxController controller = Get.isRegistered()
      ? Get.find<InboxController>()
      : Get.put(InboxController());
  @override
  Widget build(BuildContext context) {
    // controller.fetchInbox();
    return Scaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (controller.inboxList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No new messages'),
                  // TextButton.icon(
                  //   onPressed: () => controller.fetchInbox(),
                  //   label: const Text('Refresh'),
                  //   icon: const Icon(Icons.refresh),
                  // )
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.inboxList.length,
            itemBuilder: (context, index) {
              final invitation = controller.inboxList[index];
              switch (invitation.notificationType) {
                case (NotificationTypes.fleetInvitation):
                  return fleetInvitations(invitation);
                case (NotificationTypes.joinRequest):
                  return joinRequest(invitation);
                case (NotificationTypes.payment):
                  return paymentRequest(invitation);
                default:
                  return const Center(
                      child: Text('Failed to load the message'));
              }
              //
            },
          );
        },
      ),
    );
  }

  Widget fleetInvitations(NotificationModel invitation) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.directions_car, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(invitation.fleet!.fleetName,
                          style: Get.textTheme.bodyLarge),
                      const SizedBox(height: 4),
                      Text('Fleet invitation',
                          style: Get.textTheme.bodySmall!
                              .copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  CustomWidgets().formatTimestamp(invitation.timestamp),
                  style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    Icons.location_on, invitation.fleet!.officeAddress),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, invitation.fleet!.contactNumber),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.directions_car,
                  '${invitation.fleet!.vehicles == null ? 0 : invitation.fleet!.vehicles!.length} vehicles',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.actionLoading.value
                          ? null
                          : () => controller.declineRequest(
                              notificationId: invitation.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green),
                      onPressed: controller.actionLoading.value
                          ? null
                          : () => controller.acceptFleetRequest(
                              notificationId: invitation.id,
                              fleetId: invitation.fleet!.fleetId),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget joinRequest(NotificationModel invitation) {
    final user = invitation.user!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: NetworkImage(user.profilePicUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Join request',
                          style: Get.textTheme.bodySmall!
                              .copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  CustomWidgets().formatTimestamp(invitation.timestamp),
                  style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            CustomWidgets()
                .textRow(label: 'Contact number', value: user.phoneNumber),
            CustomWidgets()
                .textRow(label: 'Email', value: user.email ?? '-Not provided-'),
            const Divider(color: Colors.white12),
            CustomWidgets().textRow(
                label: 'Duties taken',
                value: user.earningDetails != null
                    ? user.earningDetails!.totalDuties.toString()
                    : '0'),
            CustomWidgets().textRow(
                label: 'Trips completed',
                value: user.earningDetails != null
                    ? user.earningDetails!.totalTrips.toString()
                    : '0'),
            const Divider(color: Colors.white12),
            ListTile(
              onTap: () async {
                await launchUrl(Uri.parse(user.licenceUrl));
              },
              title: Text(
                'Diving licence',
                style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey, size: 20),
            ),
            ListTile(
              onTap: () async {
                await launchUrl(Uri.parse(user.aadhaarUrl));
              },
              title: Text(
                'Aadhaar',
                style: Get.textTheme.bodyMedium!.copyWith(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey, size: 20),
            ),
            const Divider(color: Colors.white12),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.actionLoading.value
                          ? null
                          : () => controller.declineRequest(
                              notificationId: invitation.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green),
                      onPressed: controller.actionLoading.value
                          ? null
                          : () => controller.acceptDriverRequest(
                              notificationId: invitation.id,
                              driverId: invitation.senderId),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentRequest(NotificationModel notification) {
    final payment = notification.transaction!;
    bool isOnline = payment.paymentMethod == 'ONLINE';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  child: const Center(
                      child: Icon(Icons.payment, color: Colors.orange)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.senderName,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("₹ ${payment.amount.toStringAsFixed(2)}",
                          style: Get.textTheme.bodyMedium!.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      isOnline ? 'By UPI' : 'By cash',
                      style: Get.textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      CustomWidgets().formatTimestamp(notification.timestamp),
                      style:
                          Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.actionLoading.value
                          ? null
                          : () => controller.declinePayment(
                              notificationId: notification.id,
                              transactionId: payment.transactionId),
                      icon: const Icon(Icons.close),
                      label: const Text('Decline'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green),
                      onPressed: controller.actionLoading.value
                          ? null
                          : () async {
                              await controller.acceptPayment(
                                  notification: notification);
                            },
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: Get.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
