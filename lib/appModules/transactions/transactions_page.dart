import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/appModules/transactions/transaction_controller.dart';
import 'package:zero/core/const_page.dart';

class TransactionsPage extends StatelessWidget {
  final TransactionController controller = Get.isRegistered()
      ? Get.find<TransactionController>()
      : Get.put(TransactionController());
  TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchTransactions(weekStart: controller.weekStart.value);
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: FlexibleSpaceBar(
              background: transactionStats(),
            ),
          ),
          body: RefreshIndicator(
            color: ColorConst.primaryColor,
            onRefresh: () => controller.fetchTransactions(
                weekStart: controller.weekStart.value),
            child: Column(
              children: [
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                        ),
                        onPressed: controller.previousWeek,
                      ),
                      Text(controller.getWeekRange()),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: DateTime.now()
                                    .difference(controller.weekStart.value)
                                    .inDays <
                                7
                            ? null
                            : controller.nextWeek,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    if (controller.transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No transactions yet',
                              style: Get.textTheme.titleLarge!
                                  .copyWith(color: Colors.grey[600]),
                            ),
                            TextButton.icon(
                              onPressed: () => controller.fetchTransactions(
                                  weekStart: controller.weekStart.value),
                              label: const Text('Refresh'),
                              icon: const Icon(Icons.refresh),
                            )
                          ],
                        ),
                      );
                    }
                    return _buildTransactionTab();
                  }),
                ),
              ],
            ),
          )),
    );
  }

  Widget transactionStats() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.totalPaid.toString(),
              ),
              const SizedBox(height: 5),
              const Text(
                'Total credited',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.offlinePaid.toStringAsFixed(2),
              ),
              const SizedBox(height: 5),
              const Text(
                'By cash',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.onlinePaid.toStringAsFixed(2),
              ),
              const SizedBox(height: 5),
              const Text(
                'By UPI',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildTransactionTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(5),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transactions = controller.transactions[index];
        bool isOnline = transactions.paymentMethod == 'ONLINE';
        final date = DateFormat('dd MMM, hh:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(transactions.paymentTime));
        Color statusColor(String status) {
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

        return ListTile(
          leading: Icon(
            Icons.payment,
            size: 20,
            color: statusColor(transactions.status),
          ),
          title: Text(transactions.senderName),
          subtitle: Row(
            children: [
              Text("₹ ${transactions.amount.toStringAsFixed(2)} • "),
              Text(
                isOnline ? 'By UPI' : 'By cash',
                style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey),
              ),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                date,
                style:
                    Get.textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      statusColor(transactions.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transactions.status.toLowerCase().capitalize!,
                  style: TextStyle(
                    color: statusColor(transactions.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.white12),
    );
  }
}
