import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_services.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'owner';
  bool _obscurePassword = true;
  final AuthService authService = AuthService();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final user = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Check if user's role matches selected role
        if (user.role != _selectedRole) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Wrong role! This account is for ${user.role}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }

        // Role matches - navigate with user's actual role
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.home,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid username or password'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Lottie Animation
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.asset(
                  'lib/animations/login.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back',
                style: AppTextStyles.displayLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Login to continue',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username
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
                          borderSide: BorderSide(color: AppColors.gray300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password
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
                          borderSide: BorderSide(color: AppColors.gray300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Role Selection
                    Text('Login as', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard('owner', 'Owner', Icons.business),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRoleCard('tenant', 'Tenant', Icons.person),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.gray300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or', style: TextStyle(color: AppColors.gray500)),
                        ),
                        Expanded(child: Divider(color: AppColors.gray300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Register Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        final phone = '6281385277926';
                        final message = 'Halo, saya tertarik untuk mendaftar sebagai penyewa';
                        final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeFull(message)}');
                        
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cannot open WhatsApp')),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.chat_bubble_outline, size: 20),
                      label: const Text('Register via WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.gray400, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Guest Button
                    TextButton.icon(
                      onPressed: () async {
                        // Set guest session
                        await authService.login('guest', 'guest');
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }
                      },
                      icon: Icon(Icons.visibility_outlined, size: 18, color: AppColors.gray600),
                      label: Text('Browse as Guest', style: TextStyle(color: AppColors.gray600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.small : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.gray600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
