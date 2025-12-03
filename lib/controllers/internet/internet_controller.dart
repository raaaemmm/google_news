import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController with GetTickerProviderStateMixin {

  final _connectivity = Connectivity();
  bool isConnected = false;
  bool isChecking = false;
  bool _isInitialized = false;

  late AnimationController animationController;
  late Animation<double> rippleAnimation;

  @override
  void onInit() {
    super.onInit();

    // initialize connectivity synchronously first
    initializeConnectivity();

    // initialize connectivity listener
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // initialize Animation Controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    rippleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(animationController);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> initializeConnectivity() async {
    try {

      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);

      _isInitialized = true;
      update();

    } catch (e) {
      debugPrint("Error initializing connectivity: $e");
      isConnected = false;
      _isInitialized = true;
      update();
    }
  }

  void _updateConnectionStatus(dynamic connectivityResult) {
    bool previousState = isConnected;

    if (connectivityResult is List<ConnectivityResult>) {
      final singleResult = connectivityResult.isNotEmpty
          ? connectivityResult.first
          : ConnectivityResult.none;
      isConnected = singleResult != ConnectivityResult.none;
    } else if (connectivityResult is ConnectivityResult) {
      isConnected = connectivityResult != ConnectivityResult.none;
    } else {
      debugPrint("Unknown connectivity result: $connectivityResult");
      isConnected = false;
      update();
    }

    if (_isInitialized && previousState != isConnected) {
      update();

      showMessage(
        msg: isConnected ? "You're back online!" : "No internet connection!",
        bgColor: isConnected ? Color(0xFF1B4242) : Colors.pink,
        txtColor: Colors.white,
      );
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      isChecking = true;
      update();

      await Future.delayed(const Duration(milliseconds: 500));
      final connectivityResult = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);

    } catch (e) {
      debugPrint("Error checking connectivity: $e");
      isConnected = false;
      update();
    } finally {
      isChecking = false;
      update();
    }
    return isConnected;
  }

  Future<bool> tryAgain() async {
    if (isChecking) return isConnected;

    final hasConnection = await checkConnectivity();

    showMessage(
      msg: hasConnection ? "Connection restored!" : "Still no connection, try again later.",
      bgColor: hasConnection ? Color(0xFF1B4242) : Colors.pink,
      txtColor: Colors.white,
    );

    debugPrint("Connection status: 👉 $hasConnection");

    return hasConnection;
  }

  void openWifiSettings() {
    AppSettings.openAppSettings(
      type: AppSettingsType.wifi,
      asAnotherTask: true,
    );
  }

  void showMessage({
    required String msg,
    required Color bgColor,
    required Color txtColor,
  }) {
    final snackBar = SnackBar(
      content: Text(
        msg,
        style: TextStyle(
          fontFamily: 'KantumruyPro',
          fontSize: 12.0,
          color: txtColor,
        ),
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }
}