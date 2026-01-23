import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({super.key});

  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  String _status = "";

  @override
  void initState() {
    super.initState();
    YcProductPlugin().onListening((event) {
       if (event.keys.contains(NativeEventType.deviceControlFindPhoneStateChange)) {
          final state = event[NativeEventType.deviceControlFindPhoneStateChange];
          setState(() => _status = "Ring is finding phone! (State: $state)");
          _showFindAlert();
       }
       // Handle photo remote trigger
       if (event.keys.contains(NativeEventType.deviceControlPhotoStateChange)) {
          setState(() => _status = "Photo Triggered by Ring!");
       }
    });
  }

  void _showFindAlert() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Find Phone"),
      content: const Text("Your Ring is looking for you!"),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss"))],
    ));
  }

  @override
  void dispose() {
    // Ideally remove listener, but SDK only has global cancelListening which might break others.
    // In a real app we'd use a broadcast stream or multiplexer.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Remote Control")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_status.isNotEmpty)
            Container(color: Colors.amber.shade100, padding: const EdgeInsets.all(8), child: Text(_status)),
          
          _buildControlTile(
             "Find Ring", 
             Icons.vibration, 
             () => YcProductPlugin().setDeviceAntiLost(true).then((_) => setState(() => _status = "Finding Ring..."))
          ),
          
          _buildControlTile(
             "Remote Camera Mode (Enter)", 
             Icons.camera_alt, 
             () => YcProductPlugin().appControlTakePhoto(true).then((_) => setState(() => _status = "Camera Mode On"))
          ),
          
           _buildControlTile(
             "Remote Camera Mode (Exit)", 
             Icons.camera_alt_outlined, 
             () => YcProductPlugin().appControlTakePhoto(false).then((_) => setState(() => _status = "Camera Mode Off"))
          ),

          const Divider(),
          const Padding(padding: EdgeInsets.all(8), child: Text("Music Control (Simulated)")),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               IconButton(icon: const Icon(Icons.skip_previous), onPressed: () {}),
               IconButton(icon: const Icon(Icons.play_arrow), onPressed: () {}),
               IconButton(icon: const Icon(Icons.skip_next), onPressed: () {}),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildControlTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
