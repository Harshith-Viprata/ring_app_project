import 'package:yc_product_plugin/yc_product_plugin.dart';

class YcHealthRepository {
  
  // Generic helper to query data
  Future<List<dynamic>> queryData(int dataType) async {
    try {
      final result = await YcProductPlugin().queryDeviceHealthData(dataType);
      if (result?.statusCode == PluginState.succeed) {
        return result?.data ?? [];
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Failed to query data type $dataType: $e");
    }
  }

  // Specific Data Getters
  Future<List<dynamic>> getSteps() async => queryData(HealthDataType.step);
  Future<List<dynamic>> getSleep() async => queryData(HealthDataType.sleep);
  Future<List<dynamic>> getHeartRate() async => queryData(HealthDataType.heartRate);
  Future<List<dynamic>> getBloodPressure() async => queryData(HealthDataType.bloodPressure);
  Future<List<dynamic>> getBloodOxygen() async => []; // Not directly supported in HealthDataType
  Future<List<dynamic>> getECG() async => []; // Realtime only or via getECGResult
  Future<List<dynamic>> getSportHistory() async => queryData(HealthDataType.sportHistoryData);
  Future<List<dynamic>> getBodyIndex() async => queryData(HealthDataType.bodyIndexData);

  // Commands
  Future<void> deleteData(int dataType) async {
     await YcProductPlugin().deleteDeviceHealthData(dataType);
  }
}
