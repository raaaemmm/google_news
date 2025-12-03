import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_news/models/news_model.dart';
import 'package:google_news/services/news_service.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsBySourceController extends GetxController {

  final _newsService = NewsService();

  List<NewsModel> newsSourceList = [];

  bool isLoading = false;
  bool isOpeningURL = false;

  // refresh Controller
  final refreshController = RefreshController(initialRefresh: false);

  // pull-to-refresh news by source
  Future<void> onRefreshNewsBySource({
    required String source,
  }) async {
    try {
      await getNewsBySource(source: source);
      refreshController.refreshCompleted();
    } catch (_) {
      refreshController.refreshFailed();
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

  // get News By Source | BBC CNN ABC or others
  Future<void> getNewsBySource({
    required String source,
  }) async {
    if(isLoading) return;
    try {
      isLoading = true;
      update();

      newsSourceList = await _newsService.getNewsBySource(
        source: source,
      );

    } catch (e) {
      debugPrint('Error getting news by source: $e');
      showMessage(
        msg: 'Error get news by source.',
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