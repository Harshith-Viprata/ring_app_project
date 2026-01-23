import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
           if (state is ProfileLoaded) {
             // Sync to Ring whenever we load profile
             final user = state.user;
             final age = _calculateAge(user['birthDate']);
             YcProductPlugin().setDeviceUserInfo(
               user['height'] ?? 170, 
               user['weight'] ?? 65, 
               age,
               (user['gender'] == 0) ? DeviceUserGender.male : DeviceUserGender.female
             );
           }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(user['email'] ?? "User", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 32),
                
                _buildInfoTile("Gender", (user['gender'] == 0) ? "Male" : "Female"),
                _buildInfoTile("Height", "${user['height'] ?? '--'} cm"),
                _buildInfoTile("Weight", "${user['weight'] ?? '--'} kg"),
                _buildInfoTile("Birth Date", "${user['birthDate']?.split('T')[0] ?? '--'}"),
                
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.watch),
                  title: const Text("Sync Profile to Ring"),
                  subtitle: const Text("Updates algorithms on device"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                     // Re-trigger sync
                     final age = _calculateAge(user['birthDate']);
                     YcProductPlugin().setDeviceUserInfo(
                       user['height'] ?? 170, 
                       user['weight'] ?? 65, 
                       age, 
                       (user['gender'] == 0) ? DeviceUserGender.male : DeviceUserGender.female
                     );
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sync command sent (Age: $age)")));
                  },
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      // Logout logic (basic pop for now, ideally clear token)
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Logout", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            );
          } else if (state is AuthFailure) {
             return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Load Profile"));
        },
      ),
    );
  }

  int _calculateAge(String? birthDateString) {
    if (birthDateString == null) return 25;
    try {
      final birthDate = DateTime.parse(birthDateString);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 25; // Default fallback
    }
  }

  Widget _buildInfoTile(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
