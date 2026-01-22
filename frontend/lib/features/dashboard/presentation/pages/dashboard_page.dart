import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_health_service.dart';
import '../../../../di/app_binding.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late MockHealthService _healthService;

  @override
  void initState() {
    super.initState();
    _healthService = sl<MockHealthService>();
    _healthService.startEmitting();
  }

  @override
  void dispose() {
    // In a real app, only dispose when logging out or completely leaving
    // _healthService.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                   StreamBuilder<int>(
                    stream: _healthService.steps,
                    initialData: 0,
                    builder: (context, snapshot) {
                      return _HealthCard(
                        title: 'Steps',
                        value: snapshot.data.toString(),
                        unit: 'steps',
                        icon: Icons.directions_walk,
                        color: Colors.orange,
                      );
                    }
                  ),
                  StreamBuilder<int>(
                    stream: _healthService.heartRate,
                    initialData: 70,
                    builder: (context, snapshot) {
                      return _HealthCard(
                         title: 'Heart Rate',
                        value: snapshot.data.toString(),
                        unit: 'bpm',
                        icon: Icons.favorite,
                        color: Colors.red,
                      );
                    }
                  ),
                  const _HealthCard(
                    title: 'Sleep',
                    value: '7h 30m',
                    unit: '',
                    icon: Icons.bedtime,
                    color: Colors.purple,
                  ),
                  const _HealthCard(
                    title: 'SPO2',
                    value: '98',
                    unit: '%',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _HealthCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$unit $title',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
