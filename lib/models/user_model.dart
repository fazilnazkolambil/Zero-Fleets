class UserModel {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String licenceUrl;
  final String aadhaarUrl;
  final String profilePicUrl;
  final int createdAt;
  final int updatedAt;
  final EarningsModel? earningDetails;
  String? userRole;
  final String status;
  final double wallet;
  // final FleetModel? fleet;
  final String? fleetId;
  final int? weeklyTrip;
  final int? weeklyShift;
  final Map<String, dynamic>? blocked;
  DriverOnDuty? onDuty;
  final String lastVehicle;
  final List? fleetRequests;
  UserModel(
      {required this.uid,
      required this.fullName,
      required this.phoneNumber,
      this.email,
      required this.licenceUrl,
      required this.profilePicUrl,
      required this.aadhaarUrl,
      required this.createdAt,
      required this.updatedAt,
      this.earningDetails,
      this.userRole,
      required this.status,
      required this.wallet,
      // this.fleet,
      this.fleetId,
      this.weeklyTrip,
      this.weeklyShift,
      this.blocked,
      this.onDuty,
      required this.lastVehicle,
      this.fleetRequests});

  /// CopyWith for immutability
  UserModel copyWith(
      {String? uid,
      String? fullName,
      String? phoneNumber,
      String? email,
      String? licenceUrl,
      String? aadhaarUrl,
      String? profilePicUrl,
      int? createdAt,
      int? updatedAt,
      EarningsModel? earningDetails,
      String? userRole,
      String? status,
      double? wallet,
      // FleetModel? fleet,
      String? fleetId,
      int? weeklyTrip,
      int? weeklyShift,
      int? targetTrips,
      Map<String, dynamic>? blocked,
      DriverOnDuty? onDuty,
      String? lastVehicle,
      List? fleetRequests}) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licenceUrl: licenceUrl ?? this.licenceUrl,
      aadhaarUrl: aadhaarUrl ?? this.aadhaarUrl,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      earningDetails: earningDetails ?? this.earningDetails,
      userRole: userRole ?? this.userRole,
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      // fleet: fleet ?? this.fleet,
      fleetId: fleetId ?? this.fleetId,
      weeklyTrip: weeklyTrip ?? this.weeklyTrip,
      weeklyShift: weeklyShift ?? this.weeklyShift,
      blocked: blocked ?? this.blocked,
      onDuty: onDuty ?? this.onDuty,
      lastVehicle: lastVehicle ?? this.lastVehicle,
      fleetRequests: fleetRequests ?? this.fleetRequests,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'license_url': licenceUrl,
      'aadhaar_url': aadhaarUrl,
      'profile_pic_url': profilePicUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'earning_details': earningDetails,
      'user_role': userRole,
      'status': status,
      'wallet': wallet,
      // 'fleet': fleet,
      'fleet_id': fleetId,
      'weekly_trip': weeklyTrip,
      'weekly_shift': weeklyShift,
      'blocked': blocked,
      'on_duty': onDuty,
      'last_vehicle': lastVehicle,
      'fleet_requests': fleetRequests,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map['uid'] ?? '',
        fullName: map['full_name'] ?? '',
        phoneNumber: map['phone_number'] ?? '',
        email: map['email'],
        licenceUrl: map['license_url'] ?? '',
        aadhaarUrl: map['aadhaar_url'] ?? '',
        profilePicUrl: map['profile_pic_url'] ?? '',
        createdAt: map['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: map['updated_at'] ?? DateTime.now().millisecondsSinceEpoch,
        userRole: map['user_role'],
        status: map['status'] ?? 'ACTIVE',
        wallet: map['wallet'].toDouble() ?? 0,
        // fleet: map['fleet'] == null ? null : FleetModel.fromMap(map['fleet']),
        fleetId: map['fleet_id'],
        weeklyTrip: map['weekly_trip'] ?? 0,
        weeklyShift: map['weekly_shift'] ?? 0,
        blocked: map['blocked'],
        lastVehicle: map['last_vehicle'] ?? '',
        fleetRequests: map['fleet_requests'] ?? [],
        onDuty: map['on_duty'] == null
            ? null
            : DriverOnDuty.fromMap(map['on_duty']),
        earningDetails: map['earning_details'] == null
            ? null
            : EarningsModel.fromMap(map['earning_details']));
  }
}

class DriverOnDuty {
  final String dutyId;
  final int startTime;
  final int? endTime;
  final String vehicleId;
  final String vehicleNumber;
  final int selectedShift;
  DriverOnDuty(
      {required this.dutyId,
      required this.startTime,
      this.endTime,
      required this.vehicleId,
      required this.vehicleNumber,
      required this.selectedShift});
  Map<String, dynamic> toMap() {
    return {
      'duty_id': dutyId,
      'start_time': startTime,
      'end_time': endTime,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'selected_shift': selectedShift,
    };
  }

  factory DriverOnDuty.fromMap(Map<String, dynamic> map) {
    return DriverOnDuty(
      dutyId: map['duty_id'] ?? '',
      startTime: map['start_time'] ?? DateTime.now().millisecondsSinceEpoch,
      endTime: map['end_time'] ?? DateTime.now().millisecondsSinceEpoch,
      vehicleId: map['vehicle_id'] ?? '',
      vehicleNumber: map['vehicle_number'] ?? '',
      selectedShift: map['selected_shift'] ?? '1',
    );
  }
}

class EarningsModel {
  final int totalTrips;
  final int totalDuties;
  final double totalBalance;
  EarningsModel(
      {required this.totalTrips,
      required this.totalDuties,
      required this.totalBalance});

  factory EarningsModel.fromMap(Map<String, dynamic> json) {
    return EarningsModel(
      totalTrips: json['total_trips'] ?? 0,
      totalDuties: json['total_duties'] ?? 0,
      totalBalance: json['total_balance'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'total_trips': totalTrips,
      'total_duties': totalDuties,
      'total_balance': totalBalance,
    };
  }
}
