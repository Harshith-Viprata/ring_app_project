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
class DeviceFollowing extends DeviceState {}
class DeviceConnectedState extends DeviceState {
  final String deviceId;
  DeviceConnectedState(this.deviceId);
  @override
  List<Object> get props => [deviceId];
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
    on<ScanStarted>((event, emit) async {
      try {
        emit(DeviceScanning(const [])); // Show loading/empty list initially
        repository.startScan(); // Don't await, let it run and emit to stream
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
      try {
        await repository.stopScan();
        emit(DeviceInitial());
      } catch (e) {
        // ignore error on stop
      }
    });

    on<DeviceConnected>((event, emit) async {
      try {
        await repository.connect(event.id);
        emit(DeviceConnectedState(event.id));
      } catch (e) {
        print("Bloc: Connection Failed: $e");
        emit(DeviceFailure("Connection Failed: $e"));
      }
    });
  }
}
