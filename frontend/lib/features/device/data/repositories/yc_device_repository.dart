import 'dart:async';
import 'package:yc_product_plugin/yc_product_plugin.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';

class YcDeviceRepository implements DeviceRepository {
  final _scanController = StreamController<List<BluetoothDeviceEntity>>.broadcast();
  List<BluetoothDevice> _cachedDevices = [];

  @override
  Stream<List<BluetoothDeviceEntity>> get scanResults => _scanController.stream;

  @override
  Future<void> startScan() async {
    try {
      // SDK scan returns a Future list
      final devices = await YcProductPlugin().scanDevice(time: 5); 
      _cachedDevices = devices ?? [];
      
      final entities = _cachedDevices.map((d) => BluetoothDeviceEntity(
        id: d.macAddress ?? '', 
        name: d.name ?? 'Unknown',
        rssi: d.rssiValue ?? 0,
      )).toList();
      
      _scanController.add(entities);
    } catch (e) {
      _scanController.addError(e);
    }
  }

  @override
  Future<void> stopScan() async {
    // SDK doesn't strictly have a stopScan since it's a timed one-shot, but we can reset or ignore.
    // For specific implementation, we might call YcProductPlugin().stopScan() if available 
    // but the reference showed only scanDevice logic.
    // YcProductPlugin().stopScan(); // Method not available in this SDK version
  }

  @override
  Future<void> connect(String deviceId) async {
    final device = _cachedDevices.firstWhere(
      (d) => d.macAddress == deviceId, 
      orElse: () => throw Exception("Device not found in cache"),
    );
    
    await YcProductPlugin().connectDevice(device);
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await YcProductPlugin().disconnectDevice();
  }
}
