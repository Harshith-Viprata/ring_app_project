import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/device_bloc.dart';
import 'firmware_update_page.dart';
import 'watch_face_page.dart';
import 'remote_control_page.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  // Mock settings state
  bool _callNotifications = false;
  bool _smsNotifications = false;
  bool _appNotifications = false;
  bool _raiseToWake = false;
  bool _dndMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Settings')),
      body: ListView(
        children: [
          _buildSectionHeader("Features"),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("Sync Device Time"),
            onTap: () {
               // Use repo directly or bloc if event exists. 
               // For now, let's assume we can trigger it via a simple method or event
               // Since SetTime isn't an event, I'll access repo via read or just add the event.
               // Actually, it's safer to use direct plugin for simple commands if Bloc event missing,
               // BUT I implemented setTime in Repo. I should ideally add 'SyncTime' event to Bloc.
               // Let's use direct plugin for speed as requested, or add event. 
               // I'll stick to 'SetStepGoal' which HAS an event.
               // For Time, I'll just use the plugin reference as in existing code, 
               // OR better, create the event efficiently. 
               // Existing code uses YcProductPlugin()... I will follow that pattern for now for consistency 
               // unless I want to be strict. I'll use YcProductPlugin().setDeviceSyncPhoneTime() directly here
               // matching the style of the file.
               YcProductPlugin().setDeviceSyncPhoneTime();
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Time Sync Command Sent')));
            },
          ),
           ListTile(
            leading: const Icon(Icons.directions_walk),
            title: const Text("Set Step Goal"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _setStepGoal, // New Method
          ),
          ListTile(
            leading: const Icon(Icons.watch),
            title: const Text("Watch Faces"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WatchFacePage())),
          ),
          ListTile(
            leading: const Icon(Icons.gamepad),
            title: const Text("Remote Control (Camera/Find)"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemoteControlPage())),
          ),

          _buildSectionHeader("Notifications"),
          SwitchListTile(
            title: const Text("Call Alerts"),
            value: _callNotifications,
            onChanged: (val) {
              setState(() => _callNotifications = val);
              YcProductPlugin().updateCallAlerts(val);
            },
          ),
          SwitchListTile(
            title: const Text("SMS Alerts"),
            value: _smsNotifications,
            onChanged: (val) {
              setState(() => _smsNotifications = val);
              // YcProductPlugin().setDeviceInfoPush...
            },
          ),
           SwitchListTile(
            title: const Text("App Notifications"),
            value: _appNotifications,
            onChanged: (val) {
              setState(() => _appNotifications = val);
            },
          ),

          _buildSectionHeader("Display & Gestures"),
          SwitchListTile(
            title: const Text("Raise to Wake"),
            value: _raiseToWake,
            onChanged: (val) {
              setState(() => _raiseToWake = val);
              YcProductPlugin().setDeviceWristBrightScreen(val);
            },
          ),
          SwitchListTile(
            title: const Text("Do Not Disturb"),
            value: _dndMode,
            onChanged: (val) {
              setState(() => _dndMode = val);
              YcProductPlugin().setDeviceNotDisturb(val, 22, 0, 8, 0); // Default schedule
            },
          ),

          _buildSectionHeader("System"),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text("Firmware Update (OTA)"),
            subtitle: const Text("v1.0.0"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirmwareUpdatePage())),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Factory Reset"),
            onTap: _factoryReset,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _setStepGoal() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Set Step Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Target Steps (e.g. 10000)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
             onPressed: () {
                final steps = int.tryParse(controller.text);
                if (steps != null && mounted) {
                   context.read<DeviceBloc>().add(SetDeviceStepGoal(steps));
                   Navigator.pop(ctx);
                }
             },
             child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _factoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Unpair / Reset Device"),
        content: const Text("Are you sure you want to unpair and reset the device connection? This will disconnect the device."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
               // Perform reset sequence
               await YcProductPlugin().disconnectDevice();
               await YcProductPlugin().setReconnectEnabled(isReconnectEnable: false);
               await YcProductPlugin().resetBond();
               
               if (mounted) {
                 Navigator.pop(ctx); // Close dialog
                 Navigator.pop(ctx); // Go back to previous screen (Device Manager)
               }
            },
             child: const Text("Reset", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
