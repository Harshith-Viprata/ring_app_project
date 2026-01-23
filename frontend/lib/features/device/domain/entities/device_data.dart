import 'package:equatable/equatable.dart';

// Enums matching SDK but decoupled
enum AppHealthDataType {
  step,
  sleep,
  heartRate,
  bloodPressure,
  bloodOxygen,
  temp,
  ecg
}

enum AppRealTimeDataType {
  heartRate,
  bloodPressure,
  bloodOxygen,
  temp,
  ecg
}

class DeviceDetailedInfo extends Equatable {
  final int batteryLevel;
  final String firmwareVersion;
  final String macAddress;
  final String deviceModel;

  const DeviceDetailedInfo({
    required this.batteryLevel,
    required this.firmwareVersion,
    required this.macAddress,
    required this.deviceModel,
  });

  @override
  List<Object?> get props => [batteryLevel, firmwareVersion, macAddress, deviceModel];
}

class HealthDataEntry extends Equatable {
  final int timestamp;
  final Map<String, dynamic> data;

  const HealthDataEntry({required this.timestamp, required this.data});

  @override
  List<Object?> get props => [timestamp, data];
}

class ECGDataPacket extends Equatable {
  final List<int> data;
  final bool isEnd;

  const ECGDataPacket({required this.data, this.isEnd = false});
  
  @override
  List<Object?> get props => [data, isEnd];
}
