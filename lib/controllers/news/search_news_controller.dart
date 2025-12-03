import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_news/models/news_model.dart';
import 'package:google_news/services/news_service.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchNewsController extends GetxController {

  late SharedPreferences _prefs;
  final _newsService = NewsService();

  List<NewsModel> searchedNewsList = [];
  List<String> searchedNewsHistoryList = [];

  Timer? debounce;
  final searchController = TextEditingController();

  // search refresh Controller
  final searchRefreshController = RefreshController(initialRefresh: false);

  // pull-to-refresh search news
  Future<void> onRefreshSearchNews() async {
    try {
      await searchNews(query: searchController.text.trim());
      searchRefreshController.refreshCompleted();
    } catch (_) {
      searchRefreshController.refreshFailed();
    }
  }

  // history refresh Controller
  final historyRefreshController = RefreshController(initialRefresh: false);

  // pull-to-refresh search history
  Future<void> onRefreshSearchHistory() async {
    try {
      await loadSearchNewsHistory();
      historyRefreshController.refreshCompleted();
    } catch (_) {
      historyRefreshController.refreshFailed();
    }
  }

  bool isLoading = false;
  bool isLoadingHistory = false;
  bool isOpeningURL = false;

  @override
  void onInit() {
    super.onInit();
    initPrefs();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearText() {
    searchController.clear();
    searchedNewsList.clear();
    update();
  }

  bool showAndHideClearButton(){
    return searchController.text.trim().isNotEmpty;
  }

  // used to delay searching for better UX
  void onSearchChanged({
    required String query,
  }) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      if(searchController.text.trim().isNotEmpty){
        searchNews(query: query);
        saveSearchNewsKeyword(keyword: query);
      }
      update();
    });
    update();
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

  Future<void> initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await loadSearchNewsHistory();
    } catch (e) {
      debugPrint('Error initializing SharedPreferences: $e');
    }
  }

  // search for News
  Future<void> searchNews({
    required String query,
  }) async {
    try {
      isLoading = true;
      update();

      searchedNewsList = await _newsService.searchNews(query: query);

    } catch (e) {
      debugPrint('Error searching news: $e');
      showMessage(
        msg: 'Failed to search news.',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  // save the search keyword to local
  Future<void> saveSearchNewsKeyword({
    required String keyword,
  }) async {
    try {

      if (!searchedNewsHistoryList.contains(keyword)) {
        searchedNewsHistoryList.insert(0, keyword);

        debugPrint('👉 Keyword $keyword added to local!');

        // limit search history to a maximum of 10 items
        if (searchedNewsHistoryList.length > 50) {
          searchedNewsHistoryList.removeLast();
        }

        await _prefs.setStringList('search-news-history', searchedNewsHistoryList);
        update();
      }
    } catch (e) {
      showMessage(
        msg: 'Error saving search news keyword: $e',
        bgColor: Colors.red,
        txtColor: Colors.white,
      );
    }
  }

  // load search history
  Future<void> loadSearchNewsHistory() async {
    if(isLoadingHistory) return;
    try {

      isLoadingHistory = true;
      update();

      searchedNewsHistoryList = _prefs.getStringList('search-news-history') ?? [];
      update();

      debugPrint('Searched news history: 👉 ${searchedNewsHistoryList.length}');
    } catch (e) {
      showMessage(
        msg: 'Error loading search news history: $e',
        bgColor: Colors.pink,
        txtColor: Colors.white,
      );
    } finally {
      isLoadingHistory = false;
      update();
    }
  }

  // remove a single search keyword
  Future<void> removeSearchNewsKeyword(String keyword) async {
    try {

      searchedNewsHistoryList.remove(keyword);
      await _prefs.setStringList('search-news-history', searchedNewsHistoryList);

      debugPrint('Keyword removed!');

      update();
    } catch (e) {
      showMessage(
        msg: 'Error removing search news keyword: $e',
        bgColor: Colors.red,
        txtColor: Colors.white,
      );
    }
  }

  // remove all search keywords
  Future<void> removeAllSearchNewsKeywords() async {
    try {
      searchedNewsHistoryList.clear();
      await _prefs.remove('search-news-history');
      update();
    } catch (e) {
      showMessage(
        msg: 'Error removing all search news keywords: $e',
        bgColor: Colors.red,
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