import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/hacker_news_bookmark_controller.dart';
import 'package:google_news/views/book_mark_screen.dart';
import 'package:google_news/views/the_hacker_news_bookmark_screen.dart';

class BookmarkOptionController extends GetxController {

  final _bookMarkController = Get.put(BookmarkController());
  final _hackerNewsbookMarkController = Get.put(HackerNewsBookmarkController());


  int selectedOption = 0;

  List<String> options = [
    'Google News',
    'The Hacker News',
  ];
  
  void selectOption({
    required int index,
  }) {
    selectedOption = index;
    update();
  }

  void loadBookmarks() {
    if(selectedOption == 0) {
      _bookMarkController.loadBookmarks();
    } else {
      _hackerNewsbookMarkController.loadBookmarks();
    }
  }

  List<Widget> bookmarkScreen = [
    BookMarkScreen(),
    TheHackerNewsBookmarkScreen(),
  ];
}