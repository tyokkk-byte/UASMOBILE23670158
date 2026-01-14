import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class RegisterTenantScreen extends StatefulWidget {
  const RegisterTenantScreen({Key? key}) : super(key: key);

  @override
  State<RegisterTenantScreen> createState() => _RegisterTenantScreenState();
}

class _RegisterTenantScreenState extends State<RegisterTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DBHelper _db = DBHelper();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _registerTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final existingUser = await _db.getUser(_usernameController.text.trim(), '');
      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already exists!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final newUser = User(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'tenant',
      );

      await _db.insertUser(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tenant account created!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Register Tenant'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create new tenant account',
                        style: TextStyle(color: AppColors.gray700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.gray600),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username required';
                  }
                  if (value.trim().length < 3) {
                    return 'Min 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.gray600),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.gray600,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.gray300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Password required';
                  }
                  if (value.trim().length < 3) {
                    return 'Min 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerTenant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
