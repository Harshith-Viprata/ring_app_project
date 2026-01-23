import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';
import '../widgets/ecg/ecg_charts.dart';

class ECGPage extends StatefulWidget {
  const ECGPage({super.key});

  @override
  State<ECGPage> createState() => _ECGPageState();
}

class _ECGPageState extends State<ECGPage> {
  // Data buffers
  List<double> _ecgDisplayData = []; // Data for drawing
  List<double> _rawBuffer = []; // Incoming raw data from SDK
  
  // Timer for drawing at fixed frame rate
  Timer? _drawTimer;
  
  // State
  bool _isMeasuring = false;
  String _statusMessage = "Ready to Measure";
  int _heartRate = 0;
  String _bloodPressure = "--/--";
  
  // Constants
  final int _windowSize = 250 * 3; // Keep 3 seconds of data at 250Hz approx

  @override
  void initState() {
    super.initState();
    // Setup SDK listener
    YcProductPlugin().onListening((event) {
      // 1. ECG Waveform Data
      final ecgData = event[NativeEventType.deviceRealECGFilteredData];
      if (ecgData != null && ecgData is List) {
        // Append to raw buffer
        _rawBuffer.addAll(ecgData.map((e) => (e as num).toDouble()));
      }

      // 2. Real-time Heart Rate & BP
      final bloodMap = event[NativeEventType.deviceRealBloodPressure];
      if (bloodMap != null) {
        setState(() {
          _heartRate = bloodMap["heartRate"] ?? 0;
          _bloodPressure = "${bloodMap["systolicBloodPressure"]}/${bloodMap["diastolicBloodPressure"]}";
        });
      }

      // 3. Electrode Status
       if (event.keys.contains(NativeEventType.appECGPPGStatus)) {
          Map<dynamic, dynamic>? value = event[NativeEventType.appECGPPGStatus] as Map?;
          if (value != null) {
            bool isOff = num.parse(value["EcgStatus"].toString()) != 0;
             setState(() {
               _statusMessage = isOff ? "Electrode Detached" : "Measuring...";
             });
          }
       }
       
       // 4. End of Measurement
       if (event.keys.contains(NativeEventType.deviceEndECG)) {
         _stopMeasurement();
       }
    });
  }

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
      _statusMessage = "Starting...";
      _rawBuffer.clear();
      _ecgDisplayData.clear();
    });

    YcProductPlugin().startECGMeasurement().then((value) {
      if (value?.statusCode == PluginState.succeed) {
        setState(() => _statusMessage = "Measuring...");
        _startDrawTimer();
      } else {
        setState(() {
          _isMeasuring = false;
          _statusMessage = "Failed to start";
        });
      }
    });
  }

  void _stopMeasurement() {
    _drawTimer?.cancel();
    YcProductPlugin().stopECGMeasurement();
    if (mounted) {
      setState(() {
        _isMeasuring = false;
        _statusMessage = "Measurement Ended";
      });
    }
  }

  void _startDrawTimer() {
    // 250Hz sampling means ~4ms interval.
    // Drawing at 60FPS (~16ms) is sufficient for UI.
    // We process the buffer and update displayed data.
    
    _drawTimer?.cancel();
    _drawTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_rawBuffer.isNotEmpty) {
        setState(() {
           // Move data from raw buffer to display list
           // Taking all available or chunks? Let's take all new ones.
           _ecgDisplayData.addAll(_rawBuffer);
           _rawBuffer.clear();
           
           // Trim to window size
           if (_ecgDisplayData.length > 500) {
             _ecgDisplayData = _ecgDisplayData.sublist(_ecgDisplayData.length - 500);
           }
        });
      }
    });
  }

  @override
  void dispose() {
    _stopMeasurement();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live ECG')),
      body: Column(
        children: [
          // 1. Info Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem("Heart Rate", "$_heartRate", "bpm", Colors.red),
                _buildInfoItem("BP", _bloodPressure, "mmHg", Colors.blue),
              ],
            ),
          ),
          
          const Divider(),
          
          // 2. Status
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _isMeasuring ? Colors.green : Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          // 3. Graph
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: ECGPainter(datas: _ecgDisplayData),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // 4. Controls
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isMeasuring ? _stopMeasurement : _startMeasurement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMeasuring ? Colors.red : Colors.blue,
                ),
                child: Text(
                  _isMeasuring ? "Stop Measurement" : "Start ECG",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, String unit, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text("$unit $title", style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
