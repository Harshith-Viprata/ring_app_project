import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_data.dart';
import '../../domain/repositories/device_repository.dart';

// Events
abstract class DeviceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ScanStarted extends DeviceEvent {}
class ScanStopped extends DeviceEvent {}
class DeviceConnected extends DeviceEvent {
  final String id;
  DeviceConnected(this.id);
}
class DeviceDisconnected extends DeviceEvent {
  final String id;
  DeviceDisconnected(this.id);
}

class FetchDeviceInfo extends DeviceEvent {
  final String deviceId;
  FetchDeviceInfo(this.deviceId);
}

class SyncHistoryData extends DeviceEvent {
  final String deviceId;
  final AppHealthDataType type;
  SyncHistoryData(this.deviceId, this.type);
}

class ToggleRealTime extends DeviceEvent {
  final AppRealTimeDataType type;
  final bool isOpen;
  ToggleRealTime(this.type, this.isOpen);
}

class StartECG extends DeviceEvent {}
class StopECG extends DeviceEvent {}

class SetDeviceStepGoal extends DeviceEvent {
  final int steps;
  SetDeviceStepGoal(this.steps);
}

// States
abstract class DeviceState extends Equatable {
  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}
class DeviceScanning extends DeviceState {
  final List<BluetoothDeviceEntity> devices;
  DeviceScanning(this.devices);
  @override
  List<Object> get props => [devices];
}

class DeviceConnectedState extends DeviceState {
  final String deviceId;
  DeviceConnectedState(this.deviceId);
  @override
  List<Object> get props => [deviceId];
}

class DeviceInfoLoaded extends DeviceState {
  final String deviceId;
  final DeviceDetailedInfo info;
  DeviceInfoLoaded(this.deviceId, this.info);
  @override
  List<Object> get props => [deviceId, info];
}

class DeviceHealthDataLoaded extends DeviceState {
  final String deviceId;
  final AppHealthDataType type;
  final List<HealthDataEntry> data;
  DeviceHealthDataLoaded(this.deviceId, this.type, this.data);
  @override
  List<Object> get props => [deviceId, type, data];
}

class DeviceFailure extends DeviceState {
  final String message;
  DeviceFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository repository;

  DeviceBloc(this.repository) : super(DeviceInitial()) {
    
    // Scanning
    on<ScanStarted>((event, emit) async {
      try {
        emit(DeviceScanning(const []));
        repository.startScan();
        await emit.forEach(repository.scanResults, onData: (devices) {
            return DeviceScanning(devices);
        }, onError: (e, s) {
            return DeviceFailure("Stream Error: $e");
        });
      } catch (e) {
        emit(DeviceFailure("Start Scan Failed: $e"));
      }
    });

    on<ScanStopped>((event, emit) async {
      await repository.stopScan();
      emit(DeviceInitial());
    });

    // Connection
    on<DeviceConnected>((event, emit) async {
      try {
        await repository.connect(event.id);
        emit(DeviceConnectedState(event.id));
        // Auto fetch info on connect
        add(FetchDeviceInfo(event.id));
      } catch (e) {
        emit(DeviceFailure("Connection Failed: $e"));
      }
    });

    on<DeviceDisconnected>((event, emit) async {
      try {
        await repository.disconnect(event.id);
        emit(DeviceInitial());
      } catch (e) {
        emit(DeviceFailure("Disconnect Failed: $e"));
      }
    });

    // Info
    on<FetchDeviceInfo>((event, emit) async {
      try {
        final info = await repository.getDeviceDetail(event.deviceId);
        emit(DeviceInfoLoaded(event.deviceId, info));
      } catch (e) {
        emit(DeviceFailure("Get Info Failed: $e"));
      }
    });

    // Sync
    on<SyncHistoryData>((event, emit) async {
      try {
        final data = await repository.syncHealthData(event.deviceId, event.type);
        emit(DeviceHealthDataLoaded(event.deviceId, event.type, data));
      } catch (e) {
        emit(DeviceFailure("Sync Failed: $e"));
      }
    });

    // Realtime
    on<ToggleRealTime>((event, emit) async {
      try {
        await repository.toggleRealTimeData(event.type, event.isOpen);
      } catch (e) {
        emit(DeviceFailure("Realtime Toggle Failed: $e"));
      }
    });

    on<StartECG>((event, emit) async {
      try {
        await repository.startECG();
      } catch (e) {
        emit(DeviceFailure("Start ECG Failed: $e"));
      }
    });

    on<StopECG>((event, emit) async {
      await repository.stopECG();
    });

    on<SetDeviceStepGoal>((event, emit) async {
       try {
         await repository.setStepGoal(event.steps);
       } catch (e) {
         emit(DeviceFailure("Set Goal Failed: $e"));
       }
    });
  }
}
