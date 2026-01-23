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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mine', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
           if (state is ProfileLoaded) {
             final user = state.user;
             final age = _calculateAge(user['birthDate']);
             // Auto-sync in background
             YcProductPlugin().setDeviceUserInfo(
               user['height'] ?? 170, 
               user['weight'] ?? 65, 
               age,
               (user['gender'] == 0) ? DeviceUserGender.male : DeviceUserGender.female
             );
           }
        },
        builder: (context, state) {
          String email = "visitor";
          Map<String, dynamic>? userData;

          if (state is ProfileLoaded) {
            userData = state.user;
            email = userData['email']?.split('@')[0] ?? "visitor";
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header
                Center(
                  child: Column(
                    children: [
                       CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Text(email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Personal Info Section (User requested to see data)
                if (userData != null) 
                  ExpansionTile(
                    leading: const Icon(Icons.account_circle, color: Colors.orange),
                    title: const Text("Personal Data"),
                    children: [
                       _buildDataRow("Height", "${userData['height']} cm"),
                       _buildDataRow("Weight", "${userData['weight']} kg"),
                       _buildDataRow("Gender", (userData['gender'] == 0) ? "Male" : "Female"),
                       _buildDataRow("Birth Date", userData['birthDate']?.split('T')[0] ?? "--"),
                    ],
                  ),

                // Menu List from Screenshot
                _buildMenuItem(Icons.watch, "My Equipment", trailing: const Icon(Icons.link_off, color: Colors.orange, size: 20), onTap: () {
                   // Navigate to device settings or similar
                }),
                const Divider(height: 1, indent: 50),
                
                _buildMenuItem(Icons.cleaning_services_outlined, "Clear cache", trailingText: "3.6KB"),
                const Divider(height: 1, indent: 50),

                _buildMenuItem(Icons.security, "Security Settings"),
                const Divider(height: 1, indent: 50),

                _buildMenuItem(Icons.help_outline, "Help"),
                const Divider(height: 1, indent: 50),

                _buildMenuItem(Icons.language, "Language"),
                const Divider(height: 1, indent: 50),

                _buildMenuItem(Icons.feedback_outlined, "Feedback"),
                 const Divider(height: 1, indent: 50),

                _buildMenuItem(Icons.info_outline, "About us", trailingText: "1.0.0"),
                const Divider(height: 1, indent: 50),

                 const SizedBox(height: 40),
                 
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.go('/login'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                 ),
                 const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange), // Orange icons as per theme
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ?? (trailingText != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            )
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)
      ),
      onTap: onTap,
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
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
      return 25;
    }
  }
}
