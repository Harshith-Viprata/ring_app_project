import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';
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
