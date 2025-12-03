import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/views/bookmark_options_screen.dart';
import 'package:google_news/views/news_screen.dart';
import 'package:google_news/views/the_hacker_news_screen.dart';

class HomeController extends GetxController {

  int selectedIndex = 0;

  void tappedIndex ({
    required int index,
  }){
    selectedIndex = index;
    update();
  }

  void backToNewsScreen(){
    selectedIndex = 0;
    update();
  }

  List<Widget> screens = [
    NewsScreen(),
    TheHackerNewsScreen(),
    BookmarkOptionsScreen(),
  ];
}