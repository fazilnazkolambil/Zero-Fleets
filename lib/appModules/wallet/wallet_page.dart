import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/wallet/wallet_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class WalletPage extends StatelessWidget {
  WalletPage({super.key});
  final WalletController controller = Get.isRegistered()
      ? Get.find<WalletController>()
      : Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        color: ColorConst.primaryColor,
        onRefresh: () async => controller.fetchTransactions(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _walletHeader(context),
                const SizedBox(height: 10),
                _summaryCards(),
                const SizedBox(height: 10),
                _transactionList(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _walletHeader(BuildContext context) {
    final wallet = currentUser!.wallet;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance',
                  style: Get.textTheme.bodyMedium,
                ),
                const SizedBox(height: 5),
                Text('₹ ${wallet.toStringAsFixed(2)}',
                    style: Get.textTheme.titleLarge!.copyWith(
                        color: wallet < 0 ? Colors.red : Colors.green)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                controller.payingAmount.text = currentUser!.wallet < 0
                    ? (-currentUser!.wallet).toStringAsFixed(2)
                    : '0';

                showModalBottomSheet(
                    context: context,
                    isDismissible: false,
                    isScrollControlled: true,
                    builder: (context) => _showBottomSheet(context));
              },
              icon: const Icon(Icons.payment),
              label: Text(wallet < 0 ? 'Pay Now' : 'Top Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: wallet < 0 ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryCards() {
    final cards = [
      ('Pending', controller.pendingAmount.value, Colors.orange),
      ('Total Paid', controller.totalPaid.value, Colors.green),
      ('Online Paid', controller.onlinePaid.value, null),
      ('Cash Paid', controller.offlinePaid.value, null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisExtent: 100),
      itemCount: cards.length,
      itemBuilder: (_, i) {
        final (title, amount, color) = cards[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('₹${amount.toStringAsFixed(2)}',
                    style: Get.textTheme.titleLarge!.copyWith(color: color)),
                const SizedBox(height: 6),
                Text(title,
                    style:
                        Get.textTheme.bodyMedium!.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _transactionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (controller.transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No transactions yet.'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactions.length,
            separatorBuilder: (_, __) => const Divider(
              color: Colors.white12,
            ),
            itemBuilder: (_, i) {
              final transactions = controller.transactions[i];
              final date = DateFormat('dd MMM, hh:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      transactions.paymentTime));
              bool isOnline = transactions.paymentMethod == 'ONLINE';
              return ListTile(
                // leading: const Icon(Icons.circle, size: 10),
                leading: Icon(
                  Icons.circle,
                  size: 20,
                  color: _statusColor(transactions.status),
                ),
                title: Text('₹ ${transactions.amount.toStringAsFixed(2)}'),
                subtitle: Text(
                  isOnline ? 'By UPI' : 'By cash',
                  style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      date,
                      style: Get.textTheme.bodySmall!
                          .copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(transactions.status)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transactions.status.toLowerCase().capitalize!,
                        style: TextStyle(
                          color: _statusColor(transactions.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'DECLINED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // IconData _icon(String status) {
  //   switch (status) {
  //     case 'ACCEPTED':
  //       return Icons.done_outline_rounded;
  //     case 'PENDING':
  //       return Icons.info_outline;
  //     case 'DECLINED':
  //       return Icons.close;
  //     default:
  //       return Icons.circle;
  //   }
  // }

  Widget _showBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: 12,
          right: 12,
          left: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(vertical: h * 0.01, horizontal: w * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment', style: Get.textTheme.bodyLarge),
                IconButton(
                    onPressed: () => Get.back(), icon: const Icon(Icons.close))
              ],
            ),
          ),
          CustomWidgets().textField(
              textInputType: TextInputType.number,
              hintText: "Enter the amount",
              textController: controller.payingAmount),
          const SizedBox(height: 20),
          Obx(() {
            if (controller.isPaymentLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (double.parse(controller.payingAmount.text) > 0 &&
                            controller.payingAmount.text.isNotEmpty) {
                          if (
                              // controller.payingAmount.text ==
                              //       controller.transactions.first.amount
                              //           .toString()
                              //           .split('.')
                              //           .first &&
                              controller.transactions.isNotEmpty &&
                                  controller.transactions.first.status ==
                                      'PENDING') {
                            Fluttertoast.showToast(
                                msg:
                                    'Last transaction is on pending. Please wait until it get approved or declined',
                                backgroundColor: Colors.red);
                          } else {
                            await controller.makePayment('OFFLINE');
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Enter an amount to pay!",
                              backgroundColor: Colors.red);
                        }
                      },
                      child: const Text('Pay cash')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        if (controller.payingAmount.text.isEmpty ||
                            double.parse(controller.payingAmount.text) <= 0) {
                          Fluttertoast.showToast(
                            msg: "Enter an amount to pay!",
                            backgroundColor: Colors.red,
                          );
                          return;
                        }
                        await controller.upiPayment();
                      },
                      child: const Text('Pay online')),
                ),
              ],
            );
          }),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
