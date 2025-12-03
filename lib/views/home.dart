import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:google_news/controllers/home/home_controller.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/hacker_news_bookmark_controller.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final _homeController = Get.put(HomeController());
  final _bookMarkController = Get.put(BookmarkController());
  final _hackerNewsbookMarkController = Get.put(HackerNewsBookmarkController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return Scaffold(
          body: _homeController.screens[_homeController.selectedIndex],
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.all(
                TextStyle(
                  fontFamily: 'KantumruyPro',
                  fontSize: 15.0,
                ),
              ),
            ),
            child: NavigationBar(
              height: 60.0,
              backgroundColor: _homeController.selectedIndex == 1
                ? Color(0xFF272397).withValues(alpha: 0.1)
                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              indicatorColor: _homeController.selectedIndex == 1
                ? Color(0xFF272397).withValues(alpha: 0.1)
                : Theme.of(context).primaryColor.withValues(alpha: 0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              selectedIndex: _homeController.selectedIndex,
              elevation: 0,
              onDestinationSelected: (index) {
                _homeController.tappedIndex(
                  index: index,
                );
              },
              destinations: [
          
                // news screen
                NavigationDestination(
                  icon: Icon(
                    Icons.home_max_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: 'News',
                ),

                // the hacker news screen
                NavigationDestination(
                  icon: Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF272397),
                  ),
                  selectedIcon: Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF272397),
                  ),
                  label: 'The Hacker News',
                ),
          
                // bookmark screen
                GetBuilder<BookmarkController>(
                  builder: (_) {
                    return GetBuilder<HackerNewsBookmarkController>(
                      builder: (_) {
                        return NavigationDestination(
                          icon: badges.Badge(
                            position: BadgePosition.topEnd(top: -15, end: -8.0),
                            showBadge: _bookMarkController.bookmarkedList.isEmpty && _hackerNewsbookMarkController.bookmarkedList.isEmpty
                              ? false
                              : true,
                            badgeContent: Text(
                              '${_bookMarkController.bookmarkedList.length + _hackerNewsbookMarkController.bookmarkedList.length}',
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 13.0,
                                color: Colors.white,
                              ),
                            ),
                            badgeStyle: BadgeStyle(
                              shape: BadgeShape.circle,
                              badgeColor: Colors.pink,
                              padding: const EdgeInsets.all(5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.bookmarks_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          selectedIcon: badges.Badge(
                            position: BadgePosition.topEnd(top: -15, end: -8.0),
                            showBadge: _bookMarkController.bookmarkedList.isEmpty && _hackerNewsbookMarkController.bookmarkedList.isEmpty
                              ? false
                              : true,
                            badgeContent: Text(
                              '${_bookMarkController.bookmarkedList.length + _hackerNewsbookMarkController.bookmarkedList.length}',
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 13.0,
                                color: Colors.white,
                              ),
                            ),
                            badgeStyle: BadgeStyle(
                              shape: BadgeShape.circle,
                              badgeColor: Colors.pink,
                              padding: const EdgeInsets.all(5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.bookmarks_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          label: 'Bookmark',
                        );
                      }
                    );
                  }
                ),
              ]
            ),
          ),
        );
      },
    );
  }
}
