import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/device_bloc.dart';
import '../../domain/entities/device_data.dart';
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
            return _buildConnectedView(context, state, state.deviceId);
          } else if (state is DeviceInfoLoaded) {
            return _buildConnectedView(context, state, state.deviceId);
          } else if (state is DeviceHealthDataLoaded) {
            return _buildConnectedView(context, state, state.deviceId);
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

  // ... (Disconnected and Scanning views remain same)

  Widget _buildConnectedView(BuildContext context, DeviceState state, String deviceId) {
    DeviceDetailedInfo? info;
    if (state is DeviceInfoLoaded) info = state.info;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDeviceInfoCard(context, deviceId, info),
        const SizedBox(height: 20),
        
        _buildSectionTitle(context, "Health Sync"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSyncButton(context, deviceId, "Steps", AppHealthDataType.step),
            _buildSyncButton(context, deviceId, "Sleep", AppHealthDataType.sleep),
            _buildSyncButton(context, deviceId, "Heart Rate", AppHealthDataType.heartRate),
            _buildSyncButton(context, deviceId, "Blood Pressure", AppHealthDataType.bloodPressure),
            _buildSyncButton(context, deviceId, "Oxygen", AppHealthDataType.bloodOxygen),
          ],
        ),
        
        const SizedBox(height: 20),
        _buildSectionTitle(context, "Real-Time Control"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildRealTimeToggle(context, "Monitor HR", AppRealTimeDataType.heartRate),
            _buildRealTimeToggle(context, "Monitor SPO2", AppRealTimeDataType.bloodOxygen),
          ],
        ),

        const SizedBox(height: 20),
        _buildSectionTitle(context, "ECG"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => context.read<DeviceBloc>().add(StartECG()), 
              child: const Text("Start ECG"),
            ),
             OutlinedButton(
              onPressed: () => context.read<DeviceBloc>().add(StopECG()), 
              child: const Text("Stop ECG"),
            ),
          ],
        ),

        const Divider(height: 40),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Device Settings'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSettingsPage()));
          },
        ),
        
        if (state is DeviceHealthDataLoaded) ...[
          const Divider(),
          _buildDataPreview(context, state),
        ],

        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
             context.read<DeviceBloc>().add(DeviceDisconnected(deviceId));
          },
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Disconnect'),
        )
      ],
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context, String id, DeviceDetailedInfo? info) {
     return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 8),
              Text(info?.deviceModel ?? 'Ring Device', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(id, style: const TextStyle(color: Colors.grey)),
              if (info != null) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [const Icon(Icons.battery_std), Text('${info.batteryLevel}%')]),
                    Column(children: [const Icon(Icons.info), Text('v${info.firmwareVersion}')]),
                  ],
                )
              ] else 
                 TextButton(
                    onPressed: () => context.read<DeviceBloc>().add(FetchDeviceInfo(id)), 
                    child: const Text("Load Details")
                 )
            ],
          ),
        ),
     );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSyncButton(BuildContext context, String deviceId, String label, AppHealthDataType type) {
    return ActionChip(
      avatar: const Icon(Icons.sync, size: 16),
      label: Text(label),
      onPressed: () {
        context.read<DeviceBloc>().add(SyncHistoryData(deviceId, type));
      },
    );
  }

  Widget _buildRealTimeToggle(BuildContext context, String label, AppRealTimeDataType type) {
    // Ideally this would be state-aware, simplifying to toggle buttons for "Command Send"
    return Column(
      children: [
        Text(label),
        Switch(
          value: false, // TODO: Store local state or Bloc state for UI feedback
          onChanged: (val) {
             context.read<DeviceBloc>().add(ToggleRealTime(type, val));
          }
        )
      ],
    );
  }

  Widget _buildDataPreview(BuildContext context, DeviceHealthDataLoaded state) {
     return Container(
       height: 200,
       color: Colors.grey.shade100,
       padding: const EdgeInsets.all(8),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text("Latest Data: ${state.type.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: state.data.length,
                itemBuilder: (ctx, i) => Text(state.data[i].data.toString()),
              ),
            )
         ],
       ),
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
