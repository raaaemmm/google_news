import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/bookmark_option_controller.dart';
import 'package:google_news/controllers/news/hacker_news_bookmark_controller.dart';

class BookmarkOptionsScreen extends StatelessWidget {
  BookmarkOptionsScreen({super.key});

  final _bookOptionsMarkController = Get.put(BookmarkOptionController());
  final _bookMarkController = Get.put(BookmarkController());
  final _hackerNewsbookMarkController = Get.put(HackerNewsBookmarkController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookmarkOptionController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: _bookOptionsMarkController.selectedOption == 0
              ? Theme.of(context).primaryColor
              : Color(0xFF272397),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0),
              ),
            ),
            scrolledUnderElevation: 0.0,
            toolbarHeight: 70.0,
            centerTitle: true,
            elevation: 0.0,
            title: Text(
              'Bookmarks',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: Row(
            children: [
        
              // options
              RotatedBox(
                quarterTurns: -1,
                child: GetBuilder<BookmarkOptionController>(
                  builder: (_) {
                    return Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Container(
                        height: 50.0,
                        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          color: _bookOptionsMarkController.selectedOption == 0
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                            : Color(0xFF272397).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            _bookOptionsMarkController.options.length,
                            (index) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _bookOptionsMarkController.selectOption(index: index);
                                    _bookOptionsMarkController.loadBookmarks();
                                  },
                                  child: GetBuilder<BookmarkController>(
                                    builder: (_) {
                                      return GetBuilder<HackerNewsBookmarkController>(
                                        builder: (_) {
                                          return Container(
                                            width: MediaQuery.of(context).size.width / 2,
                                            height: 50.0,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _bookOptionsMarkController.selectedOption == index
                                                  ? _bookOptionsMarkController.selectedOption == 0
                                                      ? Theme.of(context).primaryColor
                                                      : Color(0xFF272397)
                                                  : null,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(index == 0 ? 7.0 : 7.0),
                                                topLeft: Radius.circular(index == 1 ? 7.0 : 7.0),
                                              ),
                                            ),
                                            child: badges.Badge(
                                              position: badges.BadgePosition.topEnd(top: -12.0, end: -10.0),
                                              showBadge: (index == 0 && _bookMarkController.bookmarkedList.isNotEmpty) || (index == 1 && _hackerNewsbookMarkController.bookmarkedList.isNotEmpty),
                                              badgeContent: Text(
                                                index == 0
                                                  ? '${_bookMarkController.bookmarkedList.length}'
                                                  : '${_hackerNewsbookMarkController.bookmarkedList.length}',
                                                style: TextStyle(
                                                  fontFamily: 'KantumruyPro',
                                                  fontSize: 13.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              badgeStyle: badges.BadgeStyle(
                                                shape: badges.BadgeShape.circle,
                                                badgeColor: Colors.pink,
                                                padding: const EdgeInsets.all(5),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _bookOptionsMarkController.options[index],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'KantumruyPro',
                                                  fontSize: 13.0,
                                                  fontWeight: _bookOptionsMarkController.selectedOption == index
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                  color: _bookOptionsMarkController.selectedOption == index
                                                    ? _bookOptionsMarkController.selectedOption == 0
                                                      ? Colors.white
                                                      : Colors.white
                                                    : _bookOptionsMarkController.selectedOption == 0
                                                      ? Color(0xFF272397)
                                                      : Theme.of(context).primaryColor
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      );
                                    }
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        
              // bookmark screen
              GetBuilder<BookmarkOptionController>(
                builder: (_) {
                  return Expanded(
                    child: _bookOptionsMarkController.bookmarkScreen[_bookOptionsMarkController.selectedOption],
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }
}
