import 'dart:async';
import 'dart:math';

class MockHealthService {
  final _heartRateController = StreamController<int>.broadcast();
  final _stepsController = StreamController<int>.broadcast();
  Timer? _timer;

  Stream<int> get heartRate => _heartRateController.stream;
  Stream<int> get steps => _stepsController.stream;

  void startEmitting() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // HR between 60-100
      _heartRateController.add(60 + Random().nextInt(40));
      // Random steps increment
      _stepsController.add(Random().nextInt(10)); 
    });
  }

  void dispose() {
    _timer?.cancel();
    _heartRateController.close();
    _stepsController.close();
  }
}
