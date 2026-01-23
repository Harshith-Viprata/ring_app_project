import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/yc_health_repository.dart';

// Events
abstract class HealthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchHealthData extends HealthEvent {}

// States
abstract class HealthState extends Equatable {
  @override
  List<Object> get props => [];
}

class HealthInitial extends HealthState {}
class HealthLoading extends HealthState {}
class HealthLoaded extends HealthState {
  final int steps;
  final String sleepQuality;
  final int heartRate;
  final String bloodPressure;
  final String ecgStatus;

  HealthLoaded({
    required this.steps,
    required this.sleepQuality,
    required this.heartRate,
    required this.bloodPressure,
    required this.ecgStatus,
  });

  @override
  List<Object> get props => [steps, sleepQuality, heartRate, bloodPressure, ecgStatus];
}
class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final YcHealthRepository repository;

  HealthBloc(this.repository) : super(HealthInitial()) {
    on<FetchHealthData>((event, emit) async {
      emit(HealthLoading());
      try {
        // Fetch all data in parallel
        final results = await Future.wait([
          repository.getSteps(),
          repository.getSleep(),
          repository.getHeartRate(),
          repository.getBloodPressure(),
          repository.getECG(),
        ]);
        
        // Parse results (Simplification for now, actual parsing depends on SDK object structure)
        // SDK returns List<dynamic>, usually custom objects. 
        // We will need to inspect the object structure or just toString() for debugging first.
        
        // Parse results safely
        int steps = 0;
        if (results[0].isNotEmpty) {
           try {
             // Try accessing 'steps' property dynamically
             steps = (results[0].last as dynamic).steps ?? 0;
           } catch (e) {
             print("Error parsing steps: $e");
           }
        }
        
        int hr = 0;
        if (results[2].isNotEmpty) {
           try {
             hr = (results[2].last as dynamic).rate ?? 0;
           } catch (e) {
             // Fallback or log
           }
        }

        String bp = "No Data";
        if (results[3].isNotEmpty) {
           try {
             final item = results[3].last as dynamic;
             bp = "${item.systolic}/${item.diastolic}";
           } catch (e) {
             bp = "--/--";
           }
        }

        emit(HealthLoaded(
          steps: steps,
          sleepQuality: results[1].isNotEmpty ? "Data Available" : "No Data",
          heartRate: hr,
          bloodPressure: bp,
          ecgStatus: results[4].isNotEmpty ? "History Available" : "No Data",
        ));
      } catch (e) {
        emit(HealthError("Failed to fetch health data: $e"));
      }
    });
  }
}
