class DutyModel {
  String dutyId;
  String driverId;
  String fleetId;
  String driverName;
  String vehicleId;
  String vehicleNumber;
  int startTime;
  dynamic vehicleRent;
  int selectedShift;
  int? endTime;
  int? totalTrips;
  double? totalEarnings;
  double? cashCollected;
  double? totaltoPay;
  double? toll;
  double? fuelExpense;
  String dutyStatus;
  double? otherFees;
  DutyModel(
      {required this.dutyId,
      required this.driverId,
      required this.fleetId,
      required this.driverName,
      required this.vehicleId,
      required this.vehicleNumber,
      required this.startTime,
      required this.vehicleRent,
      required this.selectedShift,
      this.endTime,
      this.totalTrips,
      this.totalEarnings,
      this.cashCollected,
      this.toll,
      this.fuelExpense,
      this.totaltoPay,
      required this.dutyStatus,
      this.otherFees});
  DutyModel copywith({
    String? dutyId,
    String? driverId,
    String? fleetId,
    String? driverName,
    String? vehicleId,
    String? vehicleNumber,
    int? startTime,
    dynamic vehicleRent,
    int? selectedShift,
    int? endTime,
    int? totalTrips,
    double? totalEarnings,
    double? cashCollected,
    double? toll,
    double? fuelExpense,
    double? totaltoPay,
    String? dutyStatus,
    double? otherFees,
  }) =>
      DutyModel(
        dutyId: dutyId ?? this.dutyId,
        driverId: driverId ?? this.driverId,
        fleetId: fleetId ?? this.fleetId,
        driverName: driverName ?? this.driverName,
        vehicleId: vehicleId ?? this.vehicleId,
        vehicleNumber: vehicleNumber ?? this.vehicleNumber,
        startTime: startTime ?? this.startTime,
        vehicleRent: vehicleRent ?? this.vehicleRent,
        selectedShift: selectedShift ?? this.selectedShift,
        endTime: endTime ?? this.endTime,
        totalTrips: totalTrips ?? this.totalTrips,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        cashCollected: cashCollected ?? this.cashCollected,
        toll: toll ?? this.toll,
        fuelExpense: fuelExpense ?? this.fuelExpense,
        totaltoPay: totaltoPay ?? this.totaltoPay,
        dutyStatus: dutyStatus ?? this.dutyStatus,
        otherFees: otherFees ?? this.otherFees,
      );
  factory DutyModel.fromMap(Map<String, dynamic> json) {
    return DutyModel(
      dutyId: json['duty_id'] ?? '',
      driverId: json['driver_id'] ?? '',
      fleetId: json['fleet_id'] ?? '',
      driverName: json['driver_name'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      startTime: json['start_time'],
      vehicleRent: json['vehicle_rent'],
      selectedShift: json['selected_shift'] ?? 0,
      endTime: json['end_time'],
      totalTrips: json['total_trips'] ?? 0,
      totalEarnings: json['total_earnings'] ?? 0,
      cashCollected: json['cash_collected'] ?? 0,
      toll: json['toll'] ?? 0,
      fuelExpense: json['fuel_expense'] ?? 0,
      totaltoPay: json['total_to_pay'] ?? 0,
      dutyStatus: json['duty_status'] ?? '',
      otherFees: json['other_fees'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() => {
        'duty_id': dutyId,
        'driver_id': driverId,
        'fleet_id': fleetId,
        'driver_name': driverName,
        'vehicle_id': vehicleId,
        'vehicle_number': vehicleNumber,
        'start_time': startTime,
        'vehicle_rent': vehicleRent,
        'selected_shift': selectedShift,
        'end_time': endTime,
        'total_trips': totalTrips,
        'total_earnings': totalEarnings,
        'cash_collected': cashCollected,
        'toll': toll,
        'fuel_expense': fuelExpense,
        'total_to_pay': totaltoPay,
        'duty_status': dutyStatus,
        'other_fees': otherFees,
      };
}
