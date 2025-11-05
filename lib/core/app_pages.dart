import 'package:get/get.dart';
import 'package:zero/appModules/auth/login_page.dart';
import 'package:zero/appModules/auth/signup_page.dart';
import 'package:zero/appModules/auth/splash_screen.dart';
import 'package:zero/appModules/home/home_navigation.dart';

class AppPages {
  final routes = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/signup', page: () => const SignupPage()),
    GetPage(name: '/login', page: () => const LoginPage()),
    GetPage(name: '/home', page: () => HomeNavigationPage()),
  ];
}
