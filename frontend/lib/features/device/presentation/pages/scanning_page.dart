import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/device_bloc.dart';

class ScanningPage extends StatelessWidget {
  const ScanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Request Permissions
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
            },
          ),
        ],
      ),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceScanning) {
            return ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                return ListTile(
                  title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
                  subtitle: Text(device.id),
                  trailing: Text('${device.rssi} dBm'),
                  onTap: () {
                    // Logic to connect
                    context.read<DeviceBloc>().add(DeviceConnected(device.id));
                    context.pop(); // Return to dashboard
                  },
                );
              },
            );
          } else if (state is DeviceConnectedState) {
             return Center(child: Text("Connected to ${state.deviceId}"));
          } else if (state is DeviceFailure) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.error, color: Colors.red, size: 48),
                   const SizedBox(height: 16),
                   Text("Error: ${state.message}", textAlign: TextAlign.center),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => context.read<DeviceBloc>().add(ScanStarted()),
                     child: const Text('Retry Scan'),
                   ),
                 ],
               ),
             );
          }
          return Center(
            child: ElevatedButton(
               onPressed: () async {
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
              },
              child: const Text('Start Scan'),
            ),
          );
        },
      ),
    );
  }
}
