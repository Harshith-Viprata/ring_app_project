import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/device.dart';
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
}

// Bloc
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final DeviceRepository repository;

  DeviceBloc(this.repository) : super(DeviceInitial()) {
    on<ScanStarted>((event, emit) async {
      await repository.startScan();
      await emit.forEach(repository.scanResults, onData: (devices) {
        return DeviceScanning(devices);
      });
    });

    on<ScanStopped>((event, emit) async {
      await repository.stopScan();
      emit(DeviceInitial());
    });
  }
}
