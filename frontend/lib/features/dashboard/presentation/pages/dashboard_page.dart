import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../health/presentation/bloc/health_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<HealthBloc>().add(FetchHealthData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background
      appBar: AppBar(
        title: const Text('HomePage', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.watch, color: Colors.orange),
            onPressed: () => context.read<HealthBloc>().add(FetchHealthData()),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          int steps = 0;
          int hr = 0;
          String sleep = "--";
          
          if (state is HealthLoaded) {
            steps = state.steps;
            hr = state.heartRate;
            sleep = state.sleepQuality;
          }

          return RefreshIndicator(
            onRefresh: () async => context.read<HealthBloc>().add(FetchHealthData()),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Orange Gradient Header Card
                  _buildStepsHeader(steps),
                  
                  const SizedBox(height: 16),
                  
                  // Status Text
                  const Text(
                    "Device connected. Data syncing...",
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  // Grid Layout
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildGridCard(
                        title: "Leaderboard",
                        icon: Icons.emoji_events,
                        iconColor: Colors.pinkAccent,
                        onTap: () {},
                      ),
                      _buildGridCard(
                        title: "Care",
                        icon: Icons.favorite,
                        iconColor: Colors.purpleAccent,
                        onTap: () {},
                      ),
                      _buildDataCard(
                        label: "HR",
                        value: "$hr",
                        unit: "bpm",
                        icon: Icons.monitor_heart,
                        iconColor: Colors.tealAccent,
                        onTap: () => context.push('/ecg'),
                      ),
                      _buildDataCard(
                        label: "Sleep",
                        value: sleep, // e.g. "08h 30m"
                        unit: "",
                        icon: Icons.bedtime,
                        iconColor: Colors.indigoAccent,
                         onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dashboard_customize, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text("Edit module", style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepsHeader(int steps) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFCCBC), Color(0xFFFF7043)], // Light Orange to Dark Orange
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 15),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Steps", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text("$steps",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(Icons.local_fire_department, "0 Kcal"),
                _buildHeaderStat(Icons.flag, "10000"),
                _buildHeaderStat(Icons.location_on, "0.000 km"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  Widget _buildGridCard({required String title, required IconData icon, required Color iconColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({required String label, required String value, required String unit, required IconData icon, required Color iconColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
       child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                 if (label == 'HR') const Text("-- bpm", style: TextStyle(fontSize: 12, color: Colors.grey))
                 else if (label == 'Sleep') const Text("00h 00min", style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold))
              ],
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                Icon(icon, color: iconColor, size: 40),
              ],
            )
          ],
        ),
      ),
    );
  }
}
