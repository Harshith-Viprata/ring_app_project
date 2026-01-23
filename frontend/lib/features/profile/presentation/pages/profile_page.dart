import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text("User Name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
          
          _buildInfoTile("Gender", "Male"),
          _buildInfoTile("Height", "180 cm"),
          _buildInfoTile("Weight", "75 kg"),
          _buildInfoTile("Birth Date", "1990-01-01"),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Logout logic
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onTap: () {
          // Edit logic
        },
      ),
    );
  }
}
