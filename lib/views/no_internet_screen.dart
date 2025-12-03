import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/internet/internet_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NoInternetScreen extends StatelessWidget {
  NoInternetScreen({super.key});

  final _internetController = Get.put(InternetController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20.0),
          ),
        ),
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80.0,
        centerTitle: true,
        elevation: 0.0,
        title: const Text(
          'You\'re Offline',
          style: TextStyle(
            fontFamily: 'KantumruyPro',
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: GetBuilder<InternetController>(
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          
                // animated icon with ripple effect
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
          
                      // outer ripple
                      AnimatedBuilder(
                        animation: _internetController.rippleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _internetController.rippleAnimation.value,
                            child: Container(
                              width: 250.0,
                              height: 250.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
          
                      // middle Layer
                      Container(
                        width: 170.0,
                        height: 170.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
          
                      // inner circle with icon
                      Container(
                        width: 110.0,
                        height: 110.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 50.0,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // main message
                const SizedBox(height: 40.0),
                Text(
                  'Whoops!',
                  style: TextStyle(
                    fontFamily: 'KantumruyPro',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // descriptive text
                const SizedBox(height: 15.0),
                Text(
                  'No internet connection found. Check your connection or try again.',
                  style: TextStyle(
                    fontFamily: 'KantumruyPro',
                    fontSize: 15.0,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // open Wi-Fi & Try Again button
                const SizedBox(height: 40.0),
          
                // try again
                GestureDetector(
                  onTap: () {
                    _internetController.tryAgain();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.orange.shade900.withValues(alpha: 0.1),
                    ),
                    child: _internetController.isChecking
                      ? LoadingAnimationWidget.fallingDot(
                          color: Colors.orange.shade900,
                          size: 21.0,
                        )
                      : Text(
                        'Try again',
                        style: TextStyle(
                          fontFamily: 'KantumruyPro',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                  ),
                ),
          
                // open Wi-Fi
                const SizedBox(height: 10.0),
                GestureDetector(
                  onTap: () {
                    _internetController.openWifiSettings();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      'Open Wi-Fi',
                      style: TextStyle(
                        fontFamily: 'KantumruyPro',
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}