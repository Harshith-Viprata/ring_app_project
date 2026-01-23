import 'package:flutter/material.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

class WatchFacePage extends StatefulWidget {
  const WatchFacePage({super.key});

  @override
  State<WatchFacePage> createState() => _WatchFacePageState();
}

class _WatchFacePageState extends State<WatchFacePage> {
  String _status = "Ready";
  List<dynamic> _onlineFaces = [];

  @override
  void initState() {
    super.initState();
    // In a real app, query a server/CDN for faces
    // For now we simulate the SDK query logic
  }

  void _queryFaceInfo() {
    setState(() => _status = "Querying Device Face Info...");
    YcProductPlugin().queryWatchFaceInfo().then((result) {
       if (result?.statusCode == PluginState.succeed) {
         setState(() => _status = "Result: ${result?.data.toString()}");
       } else {
         setState(() => _status = "Query Failed");
       }
    });
  }

  void _installLocalFace() {
    // This would pick a file from assets or storage
    // Implementation requires file assets which we might not have yet
    setState(() => _status = "Installing Demo Face...");
    // Mock call
    // YcProductPlugin().installWatchFace(true, 306, 0, 0, path, (code, progress, err) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Watch Faces")),
      body: Column(
        children: [
          Container(
             padding: const EdgeInsets.all(16),
             color: Colors.grey.shade100,
             width: double.infinity,
             child: Text(_status),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Query Device Info"),
                  onTap: _queryFaceInfo,
                ),
                const Divider(),
                const Padding(padding: EdgeInsets.all(16), child: Text("Presets")),
                _buildFaceItem("Digital Modern", 1),
                _buildFaceItem("Analog Classic", 2),
                _buildFaceItem("Sporty Red", 3),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFaceItem(String name, int id) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50, height: 50, 
          color: Colors.blue.shade100,
          child: const Icon(Icons.watch),
        ),
        title: Text(name),
        trailing: ElevatedButton(
          onPressed: () {
             setState(() => _status = "Installing $name...");
             // YcProductPlugin().changeWatchFace(id)...
          },
          child: const Text("Install"),
        ),
      ),
    );
  }
}
