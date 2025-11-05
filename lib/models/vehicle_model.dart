class VehicleModel {
  final String vehicleId;
  final String numberPlate;
  final String vehicleModel;
  final String ownerId;
  final String? fleetId;
  final String status;
  final int addedOn;
  final int updatedOn;
  // final String vehicleImage;
  final int? totalTrips;
  final int? weeklyTrips;
  final int? lastOnline;
  final VehicleOnDuty? onDuty;
  final String? lastDriver;
  final String? lastDriverId;
  final dynamic vehicleRent;

  VehicleModel(
      {required this.vehicleId,
      required this.numberPlate,
      required this.vehicleModel,
      required this.ownerId,
      this.fleetId,
      required this.status,
      required this.addedOn,
      required this.updatedOn,
      // required this.vehicleImage,
      this.totalTrips,
      this.weeklyTrips,
      this.lastOnline,
      this.onDuty,
      this.lastDriver,
      this.lastDriverId,
      required this.vehicleRent});

  /// CopyWith for immutability
  VehicleModel copyWith(
      {String? vehicleId,
      String? numberPlate,
      String? vehicleModel,
      String? ownerId,
      String? fleetId,
      String? status,
      int? addedOn,
      int? updatedOn,
      // String? vehicleImage,
      int? totalTrips,
      int? weeklyTrips,
      int? startTime,
      int? lastOnline,
      VehicleOnDuty? onDuty,
      String? lastDriver,
      String? lastDriverId,
      dynamic vehicleRent}) {
    return VehicleModel(
      vehicleId: vehicleId ?? this.vehicleId,
      numberPlate: numberPlate ?? this.numberPlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      ownerId: ownerId ?? this.ownerId,
      fleetId: fleetId ?? this.fleetId,
      status: status ?? this.status,
      addedOn: addedOn ?? this.addedOn,
      updatedOn: updatedOn ?? this.updatedOn,
      // vehicleImage: vehicleImage ?? this.vehicleImage,
      totalTrips: totalTrips ?? this.totalTrips,
      weeklyTrips: weeklyTrips ?? this.weeklyTrips,
      lastOnline: lastOnline ?? this.lastOnline,
      onDuty: onDuty ?? this.onDuty,
      lastDriver: lastDriver ?? this.lastDriver,
      lastDriverId: lastDriverId ?? this.lastDriverId,
      vehicleRent: vehicleRent ?? this.vehicleRent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicle_id': vehicleId,
      'number_plate': numberPlate,
      'vehicle_model': vehicleModel,
      'owner_id': ownerId,
      'fleet_id': fleetId,
      'status': status,
      'added_on': addedOn,
      'updated_on': updatedOn,
      // 'vehicle_image': vehicleImage,
      'total_trips': totalTrips,
      'weekly_trips': weeklyTrips,
      'last_online': lastOnline,
      'on_duty': onDuty,
      'last_driver': lastDriver,
      'last_driver_id': lastDriverId,
      'vehicle_rent': vehicleRent,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
        vehicleId: map['vehicle_id'] ?? '',
        numberPlate: map['number_plate'] ?? '',
        vehicleModel: map['vehicle_model'] ?? '',
        ownerId: map['owner_id'] ?? '',
        fleetId: map['fleet_id'],
        status: map['status'] ?? '',
        addedOn: map['added_on'] ?? '',
        updatedOn: map['updated_on'] ?? '',
        // vehicleImage: map['vehicle_image'] ?? '',
        totalTrips: map['total_trips'] ?? 0,
        weeklyTrips: map['weekly_trips'] ?? 0,
        lastOnline: map['last_online'] ?? DateTime.now().millisecondsSinceEpoch,
        // targetTrips: map['target_trips'] ?? 0,
        onDuty: map['on_duty'] == null
            ? null
            : VehicleOnDuty.fromMap(map['on_duty']),
        lastDriver: map['last_driver'] ?? '-N/A-',
        lastDriverId: map['last_driver_id'] ?? '',
        vehicleRent: map['vehicle_rent']);
  }
}

class VehicleOnDuty {
  final int startTime;
  final int? endTime;
  final String driverId;
  final String driverName;
  VehicleOnDuty(
      {required this.startTime,
      this.endTime,
      required this.driverId,
      required this.driverName});
  Map<String, dynamic> toMap() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'vehicle_id': driverId,
      'vehicle_number': driverName,
    };
  }

  factory VehicleOnDuty.fromMap(Map<String, dynamic> map) {
    return VehicleOnDuty(
        startTime: map['start_time'] ?? DateTime.now().millisecondsSinceEpoch,
        endTime: map['end_time'] ?? DateTime.now().millisecondsSinceEpoch,
        driverId: map['vehicle_id'] ?? '',
        driverName: map['vehicle_number'] ?? '');
  }
}
