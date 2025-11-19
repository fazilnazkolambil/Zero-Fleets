import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/user_model.dart';

double w = 0;
double h = 0;
String appVersion = '1.0.0.0';
UserModel? currentUser;
// FleetModel? currentFleet;
int notificationCounts = 0;

class CustomWidgets {
  textRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.02, vertical: w * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  Get.textTheme.bodyMedium!.copyWith(color: Colors.grey[600])),
          Text(value)
        ],
      ),
    );
  }

  Widget textField(
      {String? Function(String?)? validator,
      Widget? prefixIcon,
      Widget? suffixIcon,
      required TextInputType textInputType,
      required String hintText,
      String? label,
      required TextEditingController textController,
      int? maxLength,
      bool? readOnly,
      int? maxLines,
      TextCapitalization? textCapitalization}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label),
            const SizedBox(
              height: 10,
            ),
          ],
          TextFormField(
            controller: textController,
            style: Get.textTheme.bodyMedium!.copyWith(color: Colors.white),
            cursorColor: Colors.white,
            textCapitalization:
                textCapitalization ?? TextCapitalization.sentences,
            readOnly: readOnly ?? false,
            textInputAction: TextInputAction.next,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            validator: validator,
            maxLength: maxLength,
            maxLines: maxLines,
            decoration: InputDecoration(
              counterText: '',
              fillColor: Colors.white12,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  bool isMerchantUpi(String upiId) {
    final merchantSuffixes = [
      'okbizaxis',
      'iblbiz',
      'yblbiz',
      'paytm',
      'pty',
      'razorpay',
      'cashfree',
      'yesbiz',
      'hdfcbiz',
      'sbibiz',
      'idbibiz',
    ];

    if (!upiId.contains('@')) return false;
    final suffix = upiId.split('@').last.toLowerCase();
    return merchantSuffixes.any((m) => suffix.contains(m));
  }
}
