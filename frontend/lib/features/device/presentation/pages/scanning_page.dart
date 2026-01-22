import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            onPressed: () => context.read<DeviceBloc>().add(ScanStarted()),
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
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<DeviceBloc>().add(ScanStarted()),
              child: const Text('Start Scan'),
            ),
          );
        },
      ),
    );
  }
}
