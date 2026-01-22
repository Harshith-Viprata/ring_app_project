import 'package:equatable/equatable.dart';

class BluetoothDeviceEntity extends Equatable {
  final String id;
  final String name;
  final int rssi;

  const BluetoothDeviceEntity({
    required this.id,
    required this.name,
    required this.rssi,
  });

  @override
  List<Object?> get props => [id, name, rssi];
}
