import '../entities/device.dart';
import '../entities/device_data.dart';

abstract class DeviceRepository {
  Stream<List<BluetoothDeviceEntity>> get scanResults;
  
  // Scans
  Future<void> startScan();
  Future<void> stopScan();
  
  // Connection
  Future<void> connect(String deviceId);
  Future<void> disconnect(String deviceId);
  Stream<bool> get connectionState;

  // Device Info
  Future<DeviceDetailedInfo> getDeviceDetail(String deviceId);
  
  // Health History
  Future<List<HealthDataEntry>> syncHealthData(String deviceId, AppHealthDataType type);
  Future<void> deleteHealthData(String deviceId, AppHealthDataType type);

  // Real-time Control
  Future<void> toggleRealTimeData(AppRealTimeDataType type, bool isOpen);
  Stream<dynamic> get realTimeDataStream;

  // ECG
  Future<void> startECG();
  Future<void> stopECG();
  Stream<ECGDataPacket> get ecgStream;
  
  // Settings
  Future<void> setTime();
  Future<void> setAlarm(int hour, int minute, bool enabled);
  Future<void> setStepGoal(int steps);
}
