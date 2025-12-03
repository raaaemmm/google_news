import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/internet/internet_controller.dart';
import 'package:google_news/views/home.dart';
import 'package:google_news/views/no_internet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize SharedPreferences | local storage
  await SharedPreferences.getInstance(); 

  // initialize the InternetController early
  final internetController = InternetController();
  Get.put(internetController);

  // wait for the initial connectivity check to complete
  await internetController.initializeConnectivity();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _internetController = Get.put(InternetController());

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Google News RSS | Integrate API as XML Format',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1B4242),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1B4242)),
        useMaterial3: true,
      ),
      home: GetBuilder<InternetController>(
        init: InternetController(),
        builder: (_) => _internetController.isConnected ? Home() : NoInternetScreen(),
      )
    );
  }
}
