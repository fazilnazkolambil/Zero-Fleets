import 'package:zero/models/fleet_model.dart';
import 'package:zero/models/transaction_model.dart';
import 'package:zero/models/user_model.dart';

class NotificationModel {
  final String id;
  final FleetModel? fleet;
  final TransactionModel? transaction;
  final UserModel? user;
  final String notificationType;
  final String senderId;
  final String receiverId;
  final String status;
  final int timestamp;

  NotificationModel({
    required this.id,
    this.fleet,
    this.transaction,
    this.user,
    required this.notificationType,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      fleet: json['fleet'] == null ? null : FleetModel.fromMap(json['fleet']),
      user: json['user'] == null ? null : UserModel.fromMap(json['user']),
      transaction: json['transaction'] == null
          ? null
          : TransactionModel.fromMap(json['transaction']),
      notificationType: json['notification_type'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      status: json['status'] ?? 'PENDING',
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fleet': fleet?.toMap(),
      'user': user?.toMap(),
      'transaction': transaction?.toJson(),
      'notification_type': notificationType,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
