import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_property_screen.dart';
import 'screens/add_edit_property_screen.dart';
import 'screens/booking_form_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/booking_management_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/register_tenant_screen.dart';
import 'screens/check_booking_screen.dart';
import 'models/property.dart';
import 'models/booking.dart';

void main() {
  runApp(const MyRentalApp());
}

class MyRentalApp extends StatelessWidget {
  const MyRentalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental Properti',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => MainScreen());
          case AppRoutes.detailProperty:
            final property = settings.arguments as Property;
            return MaterialPageRoute(builder: (_) => DetailPropertyScreen(property: property));
          case AppRoutes.addEditProperty:
            final property = settings.arguments as Property?;
            return MaterialPageRoute(builder: (_) => AddEditPropertyScreen(property: property));
          case AppRoutes.bookingForm:
            final property = settings.arguments as Property;
            return MaterialPageRoute(builder: (_) => BookingFormScreen(property: property));
          case AppRoutes.myBookings:
            return MaterialPageRoute(builder: (_) => const MyBookingsScreen());
          case AppRoutes.bookingManagement:
            return MaterialPageRoute(builder: (_) => const BookingManagementScreen());
          case AppRoutes.bookingDetail:
            final booking = settings.arguments as Booking;
            return MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking));
          case AppRoutes.registerTenant:
            return MaterialPageRoute(builder: (_) => const RegisterTenantScreen());
          case AppRoutes.checkBooking:
            return MaterialPageRoute(builder: (_) => const CheckBookingScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
