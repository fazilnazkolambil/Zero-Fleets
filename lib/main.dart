import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_binding.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/core/app_pages.dart';
import 'package:zero/core/global_variables.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zero/core/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('zeroCache');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(ThemeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.find();
  MyApp({super.key});
  final AuthController controller = Get.isRegistered()
      ? Get.find<AuthController>()
      : Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    h = MediaQuery.of(context).size.height;

    return Obx(
      () => GetMaterialApp(
        title: 'Zero Fleets',
        debugShowCheckedModeBanner: false,
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: themeController.theme,
        // themeMode: ThemeMode.system,
        // home: SplashScreen(),
        getPages: AppPages().routes,
        initialRoute: '/splash',
        initialBinding: AuthBinding(),
        builder: (context, child) {
          return child!;
        },
      ),
    );
  }
}
