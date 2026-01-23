import 'dart:async';
import 'package:yc_product_plugin/yc_product_plugin.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_data.dart';
import '../../domain/repositories/device_repository.dart';

class YcDeviceRepository implements DeviceRepository {
  final _scanController = StreamController<List<BluetoothDeviceEntity>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();
  final _realTimeDataController = StreamController<dynamic>.broadcast();
  final _ecgDataController = StreamController<ECGDataPacket>.broadcast();
  
  List<BluetoothDevice> _cachedDevices = [];
  YcDeviceRepository();

  @override
  Stream<List<BluetoothDeviceEntity>> get scanResults => _scanController.stream;

  @override
  Stream<bool> get connectionState => _connectionStateController.stream;

  @override
  Stream<dynamic> get realTimeDataStream => _realTimeDataController.stream;

  @override
  Stream<ECGDataPacket> get ecgStream => _ecgDataController.stream;

  @override
  Future<void> startScan() async {
    try {
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
     // No explicit stop in basic SDK usage shown, usually timeout based.
  }

  @override
  Future<void> connect(String deviceId) async {
    try {
      final device = _cachedDevices.firstWhere(
        (d) => d.macAddress == deviceId, 
        orElse: () => throw Exception("Device not found in cache"),
      );
      
      final result = await YcProductPlugin().connectDevice(device); // Returns bool?
      if (result == true) {
         _connectionStateController.add(true);
      } else {
         throw Exception("Connection failed");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await YcProductPlugin().disconnectDevice();
    _connectionStateController.add(false);
  }

  @override
  Future<DeviceDetailedInfo> getDeviceDetail(String deviceId) async {
     final basicInfo = await YcProductPlugin().queryDeviceBasicInfo(); // PluginResponse<DeviceBasicInfo>
     final mac = await YcProductPlugin().getMacAdress();
     final model = await YcProductPlugin().getDeviceModel();
     
     if (basicInfo?.data == null) throw Exception("Failed to get device info");
     
     return DeviceDetailedInfo(
       batteryLevel: basicInfo!.data!.power ?? 0,
       firmwareVersion: basicInfo.data!.firmwareVersion ?? 'Unknown',
       macAddress: mac ?? deviceId,
       deviceModel: model ?? 'Unknown',
     );
  }

  @override
  Future<List<HealthDataEntry>> syncHealthData(String deviceId, AppHealthDataType type) async {
    int sdkType;
    switch (type) {
      case AppHealthDataType.step: sdkType = HealthDataType.step; break;
      case AppHealthDataType.sleep: sdkType = HealthDataType.sleep; break;
      case AppHealthDataType.heartRate: sdkType = HealthDataType.heartRate; break;
      case AppHealthDataType.bloodPressure: sdkType = HealthDataType.bloodPressure; break;
      case AppHealthDataType.bloodOxygen: sdkType = HealthDataType.combinedData; break; // Check docs mapping
      default: sdkType = HealthDataType.step;
    }
    
    final response = await YcProductPlugin().queryDeviceHealthData(sdkType);
    
    // Parse response.data which is List<dynamic>
    if (response?.code == PluginState.succeed && response?.data != null) {
       return (response!.data as List).map((e) {
          // Generic mapping, would need specific parsing based on type
          // Assuming 'startTime' field exists for timestamp
          // This part requires seeing actual JSON/Object structure to be precise
          return HealthDataEntry(timestamp: 0, data: {'raw': e.toString()}); 
       }).toList();
    }
    return [];
  }

  @override
  Future<void> deleteHealthData(String deviceId, AppHealthDataType type) async {
     // Check headers for delete method, usually deletion happens after sync or specific CMD
     // Returning empty for now as SDK docs mainly focus on query
  }

  @override
  Future<void> toggleRealTimeData(AppRealTimeDataType type, bool isOpen) async {
      int sdkType;
      switch (type) {
        case AppRealTimeDataType.heartRate: sdkType = RealTimeDataType.heartRate; break;
        case AppRealTimeDataType.bloodPressure: sdkType = RealTimeDataType.bloodPressure; break;
        case AppRealTimeDataType.bloodOxygen: sdkType = RealTimeDataType.bloodOxygen; break;
        case AppRealTimeDataType.temp: sdkType = RealTimeDataType.bodyTemperature; break;
        default: return;
      }
      
      await YcProductPlugin().appControlRealTimeData(sdkType, isOpen);
  }

  @override
  Future<void> startECG() async {
     await YcProductPlugin().startECGMeasurement();
     // Set up listening to native ecg events
  }

  @override
  Future<void> stopECG() async {
     await YcProductPlugin().stopECGMeasurement();
  }

  @override
  Future<void> setTime() async {
    await YcProductPlugin().setDeviceSyncPhoneTime();
  }

  @override
  Future<void> setAlarm(int hour, int minute, bool enabled) async {
    // SDK might have list of alarms or single
    // await YcProductPlugin().setDeviceAlarm...
  }

  @override
  Future<void> setStepGoal(int steps) async {
    await YcProductPlugin().setDeviceStepGoal(steps);
  }
}
