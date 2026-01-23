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
    // Fetch initial data
    context.read<HealthBloc>().add(FetchHealthData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<HealthBloc>().add(FetchHealthData()),
          ),
        ],
      ),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          int steps = 0;
          int hr = 0;
          String sleep = "--";
          String bp = "--";

          if (state is HealthLoaded) {
            steps = state.steps;
            hr = state.heartRate;
            sleep = state.sleepQuality;
            bp = state.bloodPressure;
          } else if (state is HealthLoading) {
             // Optional: Show loading indicator or keep stale data
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HealthBloc>().add(FetchHealthData());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView( // Use ListView for RefreshIndicator
                children: [
                   const SizedBox(height: 20),
                   GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true, // Important for ListView
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _HealthCard(
                          title: 'Steps',
                          value: steps.toString(),
                          unit: 'steps',
                          icon: Icons.directions_walk,
                          color: Colors.orange,
                        ),
                        _HealthCard(
                          title: 'Heart Rate',
                          value: hr.toString(),
                          unit: 'bpm',
                          icon: Icons.favorite,
                          color: Colors.red,
                        ),
                        _HealthCard(
                          title: 'Sleep',
                          value: sleep,
                          unit: '',
                          icon: Icons.bedtime,
                          color: Colors.purple,
                        ),
                        _HealthCard(
                          title: 'BP',
                          value: bp,
                          unit: '',
                          icon: Icons.water_drop,
                          color: Colors.blue,
                        ),
                        _HealthCard(
                          title: 'ECG',
                          value: 'View',
                          unit: '',
                          icon: Icons.monitor_heart,
                          color: Colors.green,
                          onTap: () => context.push('/ecg'),
                        ),
                      ],
                   ),
                ],
              ),
            ),
          );
        },
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
  final VoidCallback? onTap;

  const _HealthCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
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
                        fontSize: 24,
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
    ),
    );
  }
}
