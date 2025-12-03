import 'package:get/get.dart';
import 'package:google_news/controllers/internet/internet_controller.dart';

class DependencyInjection {
  void init() {
    Get.put<InternetController>(
      InternetController(),
      permanent: true,
    );
  }
}