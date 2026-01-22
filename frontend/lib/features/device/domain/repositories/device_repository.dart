import '../entities/device.dart';

abstract class DeviceRepository {
  Stream<List<BluetoothDeviceEntity>> get scanResults;
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect(String deviceId);
}
