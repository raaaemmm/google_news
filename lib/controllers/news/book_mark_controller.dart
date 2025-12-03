import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_news/models/news_model.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkController extends GetxController {
  
  late SharedPreferences _prefs;

  // list to store bookmarked news
  List<NewsModel> bookmarkedList = [];

  bool isLoading = false;
  bool isOpeningURL = false;

  @override
  void onInit() {
    super.onInit();
    initPrefs();
  }

  // refresh Controller
  final refreshController = RefreshController(initialRefresh: false);

  // pull-to-refresh function
  Future<void> onRefresh() async {
    try {
      await loadBookmarks();
      refreshController.refreshCompleted();
    } catch (_) {
      refreshController.refreshFailed();
    }
  }

  Future<void> initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  // check if a news item is bookmarked
  bool isAddedToBookmark({
    required NewsModel news,
  }) {
    return bookmarkedList.contains(news);
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

  // load bookmarks from shared preferences
  Future<void> loadBookmarks() async {
    try {

      isLoading = true;
      update();

      final String? bookmarksJson = _prefs.getString('bookmarked_news');

      if (bookmarksJson != null) {
        List<dynamic> decodedList = json.decode(bookmarksJson);
        bookmarkedList = decodedList.map((news) {
          return NewsModel.fromJson(news);
        }).toList();
        update();
      } else {
        debugPrint('No bookmark found.');
      }
    } catch (e) {
      showMessage(
        msg: 'Error loading bookmarks. Please try again!',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Error loading bookmarks: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // add a news item to bookmarks
  Future<void> addToBookmark({
    required NewsModel news,
  }) async {
    try {

      // check if the news is already bookmarked
      if (!bookmarkedList.contains(news)) {
        bookmarkedList.insert(0, news); // insert at the beginning

        // save updated list to shared preferences
        final List<Map<String, dynamic>> encodedList = bookmarkedList.map((news) {
          return news.toJson();
        }).toList();

        await _prefs.setString('bookmarked_news', json.encode(encodedList));
        debugPrint('Bookmark added: 👉 ${news.title}');
        update();

        showMessage(
          msg: 'Added to Bookmark!',
          bgColor: Color(0xFF1B4242),
          txtColor: Colors.white,
        );

      } else {
        showMessage(
          msg: 'Oops, This news is already in your bookmarks!',
          bgColor: Colors.pink,
          txtColor: Colors.white,
        );
      }
    } catch (e) {
      showMessage(
        msg: 'Error adding bookmark. Please try again!',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Error adding bookmark: $e');
    }
  }

  // remove a news item from bookmarks
  Future<void> removeFromBookmark({
    required NewsModel news,
  }) async {
    try {
      if (bookmarkedList.contains(news)) {
        bookmarkedList.remove(news);

        // save updated list to shared preferences
        final List<Map<String, dynamic>> encodedList = bookmarkedList.map((news) {
            return news.toJson();
          }
        ).toList();

        await _prefs.setString('bookmarked_news', json.encode(encodedList));
        debugPrint('Bookmark removed: 👉 ${news.title}');
        update();

        showMessage(
          msg: 'Removed from Bookmark!',
          bgColor: Color(0xFF1B4242),
          txtColor: Colors.white,
        );

      } else {
        showMessage(
          msg: 'News not found in bookmarks!',
          bgColor: Colors.pink,
          txtColor: Colors.white,
        );
      }
    } catch (e) {
      showMessage(
        msg: 'Error removing bookmark. Please try again!',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
      debugPrint('Error removing bookmark: 👉 $e');
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
      const Color(0xFF1B4242), // Deep Green
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