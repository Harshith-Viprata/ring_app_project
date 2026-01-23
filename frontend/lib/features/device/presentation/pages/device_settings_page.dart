import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

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
  void initState() {
    super.initState();
    // In a real app, query current settings from SDK
    // YcProductPlugin().getDeviceSettings...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Settings')),
      body: ListView(
        children: [
          _buildSectionHeader("Notifications"),
          SwitchListTile(
            title: const Text("Call Alerts"),
            value: _callNotifications,
            onChanged: (val) {
              setState(() => _callNotifications = val);
              // SDK Call
            },
          ),
          SwitchListTile(
            title: const Text("SMS Alerts"),
            value: _smsNotifications,
            onChanged: (val) {
              setState(() => _smsNotifications = val);
              // SDK Call
            },
          ),
           SwitchListTile(
            title: const Text("App Notifications"),
            value: _appNotifications,
            onChanged: (val) {
              setState(() => _appNotifications = val);
              // SDK Call
            },
          ),

          _buildSectionHeader("Display & Gestures"),
          SwitchListTile(
            title: const Text("Raise to Wake"),
            value: _raiseToWake,
            onChanged: (val) {
              setState(() => _raiseToWake = val);
              // YcProductPlugin().setRaiseToWake(val);
            },
          ),
          SwitchListTile(
            title: const Text("Do Not Disturb"),
            value: _dndMode,
            onChanged: (val) {
              setState(() => _dndMode = val);
              // YcProductPlugin().setDND(val);
            },
          ),

          _buildSectionHeader("System"),
          ListTile(
            title: const Text("Firmware Update (OTA)"),
            subtitle: const Text("v1.0.0"),
            trailing: ElevatedButton(
              onPressed: _checkFirmwareUpdate,
              child: const Text("Check"),
            ),
          ),
          ListTile(
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

  void _checkFirmwareUpdate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Firmware Update"),
        content: const Text("You are on the latest version."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  void _factoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Factory Reset"),
        content: const Text("Are you sure you want to reset the device? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
               // YcProductPlugin().factoryReset();
               Navigator.pop(ctx);
            },
             child: const Text("Reset", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
