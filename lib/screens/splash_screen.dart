import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_services.dart';
import '../routes/app_routes.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
    _checkSession();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final session = await _authService.getSession();

    if (session != null) {
      final role = session['role'] as String;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.home,
        arguments: {'role': role},
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Splash Animation
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Lottie.asset(
                    'lib/animations/splash-anim.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                // App Name
                const Text(
                  'Rental Properti',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find Your Perfect Space',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 48),
                // Loading
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
