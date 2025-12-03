import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_news/models/hacker_news_model.dart';
import 'package:google_news/services/hacker_news_service.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HackerNewsController extends GetxController {

  final _hackerNewsService = HackerNewsService();

  List<HackerNewsModel> hackerNewsList = [];

  bool isLoading = false;
  bool isOpeningURL = false;

  // random generator for hint position
  final Random _random = Random();
  int? hintPosition;
  bool showHint = true;

  // refresh Controller
  final refreshController = RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    getTopHackerNewsStories();
  }

  // dismiss hint
  void dismissHint() {
    showHint = false;
    update();
  }

  // generate random hint position
  void generateRandomHintPosition() {
    if (hackerNewsList.isNotEmpty) {
      hintPosition = _random.nextInt(hackerNewsList.length); // show hint randomly between position 1 to list length
      debugPrint('Hint position generated: 👉 $hintPosition');
    } else {
      hintPosition = null;
    }
    update();
  }

  // predefined hint messages
  final List<String> hintMessages = [
    '💡 Hold on any image to view it in full screen!',
    '✨ Long press on text to copy it to your clipboard',
    '👆 Did you know? You can zoom images by holding them',
    '🎯 Pro tip: Hold down on titles or descriptions to copy them',
    '💫 Tap images for preview • Long press text to copy',
  ];

  // get random hint
  String getRandomHint() {
    return hintMessages[_random.nextInt(hintMessages.length)];
  }

  // pull-to-refresh function
  Future<void> onRefresh() async {
    try {
      await getTopHackerNewsStories();
      generateRandomHintPosition();
      refreshController.refreshCompleted();
    } catch (_) {
      refreshController.refreshFailed();
    }
  }

  // get top hacker news stories
  Future<void> getTopHackerNewsStories() async {
    if(isLoading) return;
    try {
      
      isLoading = true;
      update();

      hackerNewsList = await _hackerNewsService.getTopStories();
      generateRandomHintPosition(); // generate random position for hint

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
        msg: 'Could not launch URL, Please try again later',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Could not launch URL: $e');
    } finally {
      isOpeningURL = false;
      update();
    }
  }

  // view photo in full screen
  void previewPhoto({
    required BuildContext context,
    required String imageUrl,
    required String title,
  }) {
    if (imageUrl.isEmpty) {
      showMessage(
        msg: 'No image available to view',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(15.0),
          child: Stack(
            children: [

              // image
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // title Bar
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1E1F7D),
                            Color(0xFF272397),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF272397),
                              size: 20.0,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(8.0),
                            ),
                            hoverColor: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    
                    // image
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF272397),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.white,
                                      size: 48.0,
                                    ),
                                    SizedBox(height: 10.0),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        fontFamily: 'KantumruyPro',
                                        fontSize: 12.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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

  // format date
  String formatDate({
    required String dateStr,
  }) {
    try {
      // Parse the date string with timezone
      DateTime utcDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(dateStr, true);

      // Convert to local time
      DateTime localDate = utcDate.toLocal();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(Duration(days: 1));
      final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);

      if (dateOnly == today) {
        return "Today";
      } else if (dateOnly == yesterday) {
        return "Yesterday";
      } else {
        return DateFormat("MMM d, yyyy").format(localDate); // Example: 'Feb 22, 2025'
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
      return dateStr; // Return original string if parsing fails
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