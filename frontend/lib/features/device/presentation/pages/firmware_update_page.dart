import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';
import 'package:path_provider/path_provider.dart';

class FirmwareUpdatePage extends StatefulWidget {
  const FirmwareUpdatePage({super.key});

  @override
  State<FirmwareUpdatePage> createState() => _FirmwareUpdatePageState();
}

class _FirmwareUpdatePageState extends State<FirmwareUpdatePage> {
  String _status = "Ready to Check";
  double _progress = 0.0;
  bool _isUpdating = false;

  void _startUpdate() async {
    // In a real app, you would download the firmware file from your backend first.
    // Here we simulate the process as per the reference code structure.
    
    setState(() {
      _status = "Downloading Firmware...";
      _isUpdating = true;
      _progress = 0.1;
    });

    // Simulated delay for download
    await Future.delayed(const Duration(seconds: 2));

    final dir = await getApplicationDocumentsDirectory();
    final dummyPath = "${dir.path}/firmware.bin";
    
    // Create dummy file to satisfy SDK check (mocking download)
    await File(dummyPath).writeAsString("dummy firmware content");

    setState(() => _status = "Starting Update...");

    // Determine MCU type
    final mcu = YcProductPlugin().connectedDevice?.mcuPlatform ?? DeviceMcuPlatform.nrf52832;

    YcProductPlugin().deviceUpgrade(mcu, dummyPath, (code, progress, error) {
      if (!mounted) return;
      setState(() {
         if (code == DeviceUpdateState.upgradingFirmware) {
            _status = "Upgrading Firmware: ${(progress * 100).toInt()}%";
            _progress = progress;
         } else if (code == DeviceUpdateState.succeed) {
            _status = "Update Successful! Device Rebooting...";
            _progress = 1.0;
            _isUpdating = false;
         } else if (code == DeviceUpdateState.failed) {
            _status = "Update Failed: $error";
            _isUpdating = false;
         }
      });
    }).then((_) {
       // Callback handled above
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firmware Update (OTA)")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.system_update, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            if (_isUpdating)
              LinearProgressIndicator(value: _progress),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUpdating ? null : _startUpdate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Check & Update"),
            ),
            const SizedBox(height: 16),
            const Text(
              "Warning: Keep device close and charged above 50% during update.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
