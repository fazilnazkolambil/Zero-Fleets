import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/notification_model.dart';
import 'package:zero/models/transaction_model.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

class WalletController extends GetxController {
  @override
  void onInit() {
    fetchTransactions();
    super.onInit();
  }

  final _firestore = FirebaseFirestore.instance;

  final TextEditingController payingAmount = TextEditingController();

  RxDouble pendingAmount = 0.0.obs;
  RxDouble totalPaid = 0.0.obs;
  RxDouble onlinePaid = 0.0.obs;
  RxDouble offlinePaid = 0.0.obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  RxBool isLoading = false.obs;

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('sender_id', isEqualTo: currentUser!.uid)
          .get();

      transactions.value = snapshot.docs
          .map((e) => TransactionModel.fromMap(e.data()))
          .toList()
        ..sort((a, b) => b.paymentTime.compareTo(a.paymentTime));

      pendingAmount.value = _sumBy(transactions, 'PENDING');
      totalPaid.value = _sumBy(transactions, 'ACCEPTED');
      onlinePaid.value = _sumBy(transactions, 'ACCEPTED', filter: 'ONLINE');
      offlinePaid.value = _sumBy(transactions, 'ACCEPTED', filter: 'OFFLINE');
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  double _sumBy(List<TransactionModel> txs, String status, {String? filter}) {
    return txs
        .where((t) =>
            (t.status == status) &&
            (filter == null || t.paymentMethod == filter))
        .fold(0.0, (add, t) => add + (t.amount));
  }

  upiPayment() async {
    String upiId = currentFleet!.upiId;
    String name = currentFleet!.bankingName;
    String amount = payingAmount.text;
    String transactionNote = 'Rent payment';
    final transactionRef =
        "${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch.toString()}";
    List<ApplicationMeta> apps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all);
    if (apps.isEmpty) {
      Fluttertoast.showToast(
          msg: 'No UPI apps installed. Please install a UPI app to continue',
          backgroundColor: Colors.red);
      return;
    }

    var response = await UpiPay.initiateTransaction(
        app: apps[0].upiApplication,
        receiverUpiAddress: upiId,
        receiverName: name,
        transactionRef: transactionRef,
        amount: amount,
        transactionNote: transactionNote);

    String status = response.status!.name;
    if (status == 'failure') {
      Fluttertoast.showToast(
          msg: 'Payment failed', backgroundColor: Colors.red);
      Get.back();
    } else {
      await makePayment('ONLINE');
    }
    // Uri upiUrl = Uri.parse(
    //     'upi://pay?pa=$upiId&pn=$name&am=$amount&cu=$currency&tn=${Uri.encodeComponent(transactionNote)}');
    // try {
    //   bool result = await launchUrl(upiUrl);
    //   return result;
    // } catch (e) {
    //   print("error $e");
    //   Fluttertoast.showToast(
    //       msg: "No UPI Apps found!", backgroundColor: Colors.red);
    //   return false;
    // }
  }

  RxBool isPaymentLoading = false.obs;
  Future<void> makePayment(String type) async {
    isPaymentLoading.value = true;
    try {
      await _firestore.runTransaction((transaction) async {
        final transactionsRef = _firestore.collection('transactions').doc();
        final inboxRef = _firestore.collection('inbox').doc();

        TransactionModel transactionModel = TransactionModel(
          transactionId: transactionsRef.id,
          senderId: currentUser!.uid,
          paymentTime: DateTime.now().millisecondsSinceEpoch,
          amount: double.parse(payingAmount.text),
          status: "PENDING",
          senderName: currentUser!.fullName,
          paymentMethod: type,
          fleetId: currentFleet!.fleetId,
        );

        NotificationModel notificationModel = NotificationModel(
          id: inboxRef.id,
          notificationType: NotificationTypes.payment,
          transaction: transactionModel,
          senderId: currentUser!.uid,
          receiverId: currentFleet!.ownerId,
          status: 'PENDING',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );

        transaction.set(transactionsRef, transactionModel.toJson());
        transaction.set(inboxRef, notificationModel.toMap());
      });
      Get.offAllNamed('/splash');
    } catch (e) {
      print("Error making payment: $e");
      Fluttertoast.showToast(
          msg: "Something went wrong. Please try again!",
          backgroundColor: Colors.red);
    } finally {
      isPaymentLoading.value = false;
    }
  }
}
