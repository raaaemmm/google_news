import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_news/services/news_service.dart';
import 'package:google_news/models/news_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsController extends GetxController {

  final _newsService = NewsService();

  List<NewsModel> topStories = [];

  bool isLoading = false;
  bool isLoadingLocation = false;
  bool isOpeningURL = false;

  // refresh Controller
  final refreshController = RefreshController(initialRefresh: false);

  // pull-to-refresh function
  Future<void> onRefresh() async {
    try {
      await getTopStories();
      refreshController.refreshCompleted();
    } catch (_) {
      refreshController.refreshFailed();
    }
  }

  // topics
  List<String> newsTopics = [
    'TOP STORIES',
    'WORLD',
    'HEALTH',
    'SPORTS',
    'SCIENCE',
    'BUSINESS', 
    'NATION',
    'TECHNOLOGY',
    'ENTERTAINMENT'
  ];

  //=================== GET USER DEVICE LOCATION FOR GET getNewsByLocation ===================

  // track permission status
  bool isLocationPermissionGranted = false;

  // timer-related
  Timer? _locationAlertTimer;

    @override
  void onInit() {
    super.onInit();
    getUserDeviceLocation().then((_) {
      if (!isLocationPermissionGranted) { // start the timer if location permission is not granted
        _startLocationAlertTimer();
      }
      getTopStories();
    });
  }

  @override
  void onClose() {
    _locationAlertTimer?.cancel();
    super.onClose();
  }

  void _startLocationAlertTimer() {

    // cancel existing timer if any
    _locationAlertTimer?.cancel();
    
    // create new timer that fires every 15 minutes
    _locationAlertTimer = Timer.periodic(
      Duration(minutes: 1),
      (timer) {
        if (!isLocationPermissionGranted) {
          showDialogToEnableLocation();
        } else {
          timer.cancel(); // cancel timer if permission is granted
        }
      }
    );
  }

  Future<void> getUserDeviceLocation() async {
    try {
      isLoadingLocation = true;
      update();

      // check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMessage(
          msg: 'Location services are disabled. Please enable them.',
          bgColor: Colors.pink,
          txtColor: Colors.white,
        );

        isLocationPermissionGranted = false;
        _startLocationAlertTimer(); // start timer when service is disabled
        update();

        // skip location-dependent logic
        return;
      }

      // check location permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showMessage(
            msg: 'Location permission denied. Please grant permission.',
            bgColor: Colors.pink,
            txtColor: Colors.white,
          );

          isLocationPermissionGranted = false;
          _startLocationAlertTimer(); // start timer when permission is denied
          update();

          // skip location-dependent logic
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {

        debugPrint('Location permissions are permanently denied.');

        isLocationPermissionGranted = false;
        _startLocationAlertTimer(); // start timer when permission is permanently denied
        update();

        // skip location-dependent logic
        return;
      }

      // Permission granted, update state and stop timer
      isLocationPermissionGranted = true;
      _locationAlertTimer?.cancel();
      update();

      // define location settings
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high, // high accuracy
        distanceFilter: 120, // minimum distance (in meters) for location updates
      );

      // get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // convert latitude and longitude to a city name
      String? cityName = await getUserDeviceLocationInfo(position: position);
      if (cityName == null) {
        showMessage(
          msg: 'Could not determine city. Please try again.',
          bgColor: Colors.pink,
          txtColor: Colors.white,
        );
        return;
      }

      // insert "FOR YOU" with the city name after "TOP STORIES" in the news topics
      newsTopics.insert(1, 'FOR YOU ( $cityName )');

      // After successful location, proceed with getting top stories
      getTopStories();

    } catch (e) {
      showMessage(
        msg: 'Failed to get user location. Please try again.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Error fetching user location: 👉 $e');

      isLocationPermissionGranted = false;
      _startLocationAlertTimer(); // start timer on error
      update();
      
      // skip location-dependent logic
      return;
    } finally {
      isLoadingLocation = false;
      update();
    }
  }

  Future<String?> getUserDeviceLocationInfo({
    required Position position,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // extract more details
      Placemark place = placemarks.first;

      // show location info on console
      debugPrint(
        'Your device location is at: 👉 \n'
        'Country: ${place.country}\n'
        'Locality: ${place.locality}\n'
        'Street: ${place.street}\n'
        'Postal Code: ${place.postalCode}\n'
        'SubLocality: ${place.subLocality}\n'
        'Admin Area: ${place.administrativeArea}\n'
        'SubAdmin Area: ${place.subAdministrativeArea}\n'
        'Country Code: ${place.isoCountryCode}'
      );

      return place.locality?.toUpperCase(); // city name
    } catch (e) {
      debugPrint('Error getting city name: $e');
      return null;
    }
  }

  // to show the alert dialog
  void showDialogToEnableLocation() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enable Location Services 📍',
            style: TextStyle(
              fontFamily: 'KantumruyPro',
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We need your location to:',
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Show local news from your area\n'
                '• Provide relevant regional updates\n'
                '• Customize your news feed\n',
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 14.0,
                  color: Theme.of(context).primaryColor,
                  height: 1.4,
                ),
              ),
              Text(
                'You can enable location access in your device settings.',
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Not Now',
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 13.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {

                // close the dialog
                Get.back();

                // open settings and check location
                await Geolocator.openAppSettings();

                // wait a bit to give user time to change settings
                await Future.delayed(const Duration(seconds: 1));

                // check location again
                getUserDeviceLocation();
              },
              style: TextButton.styleFrom(
                overlayColor: Colors.blue.shade900.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              child: Text(
                'Open Settings',
                style: TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // choose Topic to get News included 'FOR YOU (User's device location)'
  int defaultIndex = 0;

  void selecteTopic({
    required int index,
  }) async {
    try {

      defaultIndex = index;
      topStories.clear();

      if(index == 0){
        await getTopStories();
      } else if(index == 1){
        await getNewsByLocation(location: newsTopics[1]);
      } else {
        await getNewsByTopic(topic: newsTopics[index]);
      }
      update();

    } catch (e) {
      debugPrint('Error getting news data: 👉 $e');
    }
  }

  void copyText({
    required String text,
  }) {
    try {
      Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Error copying text: $e');
      showMessage(
        msg: 'Failed to copy text.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    }
  }

  // launch News Link
  void openNewsLink({
    required String url,
  }) async {
    if(isOpeningURL) return;
    try {
      isOpeningURL = true;
      update();

      final Uri parsedUrl = Uri.parse(url);
      await launchUrl(
        parsedUrl, 
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(enableJavaScript: true)
      );
      debugPrint('Opening URL: 👉 $parsedUrl');
    } catch (e) {
      showMessage(
        msg: 'Could not launch URL, PLease try again later',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Could not launch URL: $e');
    } finally {
      isOpeningURL = false;
      update();
    }
  }

  Future<void> shareNews({
    required String title,
    required String link,
  }) async {    
    try {
      
      // formatted share message
      final String shareMessage = 
          '📰 $title\n\n'
          '🔗 Read more at: $link\n\n'
          'Shared via ( GG News ) By: Raaaemmm 😚';

      await Share.share(
        shareMessage,
        subject: 'Check out this news: $title',
      );
      
    } catch (e) {
      
      // more specific error message
      showMessage(
        msg: 'Unable to share news. Please try again.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Error sharing news: $e');
    }
  }

  // get Top Stories (Global)
  Future<void> getTopStories() async {
    if(isLoading) return;
    try {
      isLoading = true;
      update();

      topStories = await _newsService.getTopStories();

    } catch (e) {
      debugPrint('Error getting top stories: $e');
      showMessage(
        msg: 'Failed to get top stories.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // get News By Topic
  Future<void> getNewsByTopic({
    required String topic,
  }) async {
    if(isLoading) return;
    try {
      isLoading = true;
      update();

      topStories = await _newsService.getNewsByTopic(
        topic: topic,
      );

    } catch (e) {
      debugPrint('Error getting news by topic: $e');
      showMessage(
        msg: 'Error get news by topic.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getNewsByLocation({
    required String location,
  }) async {
    if(isLoading) return;
    try {
      isLoading = true;
      update();

      topStories = await _newsService.getNewsByLocation(
        location: location,
      );

    } catch (e) {
      debugPrint('Error getting news by location: $e');
      showMessage(
        msg: 'Error get news by location.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // format date
  String formatDate({
    required String dateStr,
  }) {
    try {
      DateTime date = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(dateStr);

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (date.year == now.year) {
        return DateFormat.MMMMd().format(date); // e.g., 'January 22'
      } else {
        return DateFormat.yMMMMd().format(date); // e.g., 'January 22, 2024'
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return dateStr; // return original string if parsing fails
    }
  }

  // get random colors
  Color randomColor() {

  final random = Random();
  
  final colors = [
    const Color(0xFF900C3F), // Deep Red
    const Color(0xFF581845), // Dark Purple
    const Color(0xFF1A5F7A), // Deep Blue
    const Color(0xFF2D3047), // Navy
    const Color(0xFF1B2845), // Dark Blue
    const Color(0xFF234E70), // Steel Blue
    const Color(0xFF2C3639), // Dark Gray
    const Color(0xFF2E4F4F), // Forest Green
    const Color(0xFF1B4242), // Deep Green
    const Color(0xFF313866), // Royal Blue
    const Color(0xFF3F4E4F), // Charcoal
    const Color(0xFF2C3333), // Dark Slate
  ];

  return colors[random.nextInt(colors.length)];
  }

  // show a snackBar with a message
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
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
  }
}