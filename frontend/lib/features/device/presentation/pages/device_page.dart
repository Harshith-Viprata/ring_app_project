import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/device_bloc.dart';
import 'device_settings_page.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Manager')),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceConnectedState) {
            return _buildConnectedView(context, state.deviceId);
          } else if (state is DeviceScanning) {
            return _buildScanningView(context, state.devices);
          } else if (state is DeviceFailure) {
            return _buildErrorView(context, state.message);
          }
          return _buildDisconnectedView(context);
        },
      ),
    );
  }

  Widget _buildDisconnectedView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No Device Connected', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Scan for Ring'),
            onPressed: () => _startScan(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningView(BuildContext context, List<dynamic> devices) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Scanning...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                 onPressed: () => context.read<DeviceBloc>().add(ScanStopped()), 
                 child: const Text('Stop')
              ),
            ],
          ),
        ),
        Expanded(
          child: devices.isEmpty
              ? const Center(child: Text('Searching for devices...'))
              : ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      leading: const Icon(Icons.watch),
                      title: Text(device.name.isNotEmpty ? device.name : 'Unknown Device'),
                      subtitle: Text(device.id),
                      trailing: Text('${device.rssi} dBm'),
                      onTap: () {
                        context.read<DeviceBloc>().add(DeviceConnected(device.id)); // Actually logic connect
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConnectedView(BuildContext context, String deviceId) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                 const Icon(Icons.check_circle, color: Colors.green, size: 64),
                 const SizedBox(height: 16),
                 Text('Connected', style: Theme.of(context).textTheme.headlineSmall),
                 Text(deviceId, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.vibration),
          title: const Text('Find Device'),
          onTap: () {
             // TODO: Access Repo directly or add event to Bloc
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finding device...')));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Device Settings'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSettingsPage()));
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.system_update),
          title: const Text('Firmware Update'),
          onTap: () {},
        ),
        const Divider(),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
             // Disconnect logic
             // context.read<DeviceBloc>().add(DeviceDisconnected());
          },
          child: const Text('Disconnect'),
        )
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _startScan(context), // Retry
            child: const Text('Retry Scan'),
          )
        ],
      ),
    );
  }

  Future<void> _startScan(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      if (context.mounted) {
        context.read<DeviceBloc>().add(ScanStarted());
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions required to scan')),
        );
      }
    }
  }
}
