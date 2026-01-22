import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  @override
  Stream<List<BluetoothDeviceEntity>> get scanResults {
    return FlutterBluePlus.scanResults.map((results) {
      return results.map((r) => BluetoothDeviceEntity(
        id: r.device.remoteId.str,
        name: r.device.platformName,
        rssi: r.rssi,
      )).toList();
    });
  }

  @override
  Future<void> startScan() async {
    // Check permissions first (handled by UI or Utils)
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connect(String deviceId) async {
    // In real app, find device by ID and connect
    // final device = BluetoothDevice.fromId(deviceId);
    // await device.connect();
  }
  
  @override
  Future<void> disconnect(String deviceId) async {
  }
}
