import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';
import 'home_screen.dart';
import 'booking_management_screen.dart';
import 'my_bookings_screen.dart';
import 'check_booking_screen.dart';
import 'add_edit_property_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _userRole = 'owner';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('session_role') ?? 'owner';
      _isLoading = false;
    });
  }

  List<Widget> _getScreensForRole() {
    switch (_userRole) {
      case 'owner':
        return [
          const HomeScreen(),
          const BookingManagementScreen(),
          const AddEditPropertyScreen(property: null),
          _buildProfileScreen(),
        ];
      case 'tenant':
        return [
          const HomeScreen(),
          const MyBookingsScreen(),
          _buildProfileScreen(),
        ];
      case 'guest':
      default:
        return [
          const HomeScreen(),
          const CheckBookingScreen(),
          _buildLoginPrompt(),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavItemsForRole() {
    switch (_userRole) {
      case 'owner':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'tenant':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
      case 'guest':
      default:
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Check',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            activeIcon: Icon(Icons.login),
            label: 'Login',
          ),
        ];
    }
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.small,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset(
                    'lib/animations/avatar-male.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    final username = snapshot.data?.getString('session_username') ?? 'User';
                    return Column(
                      children: [
                        Text(username, style: AppTextStyles.headlineLarge),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _userRole.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Owner-specific actions
          if (_userRole == 'owner') ...[
            _buildMenuItem(
              icon: Icons.person_add_outlined,
              title: 'Register Tenant',
              onTap: () => Navigator.pushNamed(context, AppRoutes.registerTenant),
            ),
            const SizedBox(height: 8),
          ],

          // Logout
          _buildMenuItem(
            icon: Icons.logout_outlined,
            title: _userRole == 'guest' ? 'Go to Login' : 'Logout',
            color: AppColors.error,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Login Required'),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              Text('Login to Access More', style: AppTextStyles.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Create an account to book properties long-term',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text('Go to Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(color: color),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final screens = _getScreensForRole();
    final navItems = _getNavItemsForRole();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: navItems,
      ),
    );
  }
}
