import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  int _gender = 0; // 0: Male, 1: Female
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/'); // Navigate to Dashboard on success
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock)
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              const Text("Physical Profile (Required for Ring)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Male")),
                  DropdownMenuItem(value: 1, child: Text("Female")),
                ], 
                onChanged: (val) => setState(() => _gender = val ?? 0),
              ),
              const SizedBox(height: 16),
              ListTile(
                 title: Text(_selectedDate == null ? "Select Birth Date" : "DOB: ${_selectedDate!.toIso8601String().split('T')[0]}"),
                 trailing: const Icon(Icons.calendar_today),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: const BorderSide(color: Colors.grey)),
                 onTap: () async {
                   final date = await showDatePicker(
                     context: context, 
                     initialDate: DateTime(2000), 
                     firstDate: DateTime(1900), 
                     lastDate: DateTime.now()
                   );
                   if (date != null) setState(() => _selectedDate = date);
                 },
              ),

              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                      RegisterRequested(
                        _emailController.text,
                        _passwordController.text,
                        height: int.tryParse(_heightController.text),
                        weight: int.tryParse(_weightController.text),
                        gender: _gender,
                        birthDate: _selectedDate?.toIso8601String(),
                      ),
                    );
                  },
                  child: const Text('Register & Sync', style: TextStyle(fontSize: 18)),
                ),
              ),
              TextButton(
                 onPressed: () {
                   context.pop(); // Go back to Login
                 },
                 child: const Text('Already have an account? Login'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
