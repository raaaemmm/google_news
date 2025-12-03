import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/hacker_news_bookmark_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TheHackerNewsBookmarkScreen extends StatelessWidget {
  TheHackerNewsBookmarkScreen({super.key});

  final _hackerNewsbookMarkController = Get.put(HackerNewsBookmarkController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HackerNewsBookmarkController>(
      builder: (_) {
        return Scaffold(
          body: GetBuilder<HackerNewsBookmarkController>(
            builder: (_) {
              if(_hackerNewsbookMarkController.isLoading){
                return Center(
                  child: LoadingAnimationWidget.fallingDot(
                    color: Color(0xFF272397),
                    size: 30.0,
                  ),
                );
              } else if(_hackerNewsbookMarkController.bookmarkedList.isEmpty){
                return RotatedBox(
                  quarterTurns: -1,
                  child: Center(
                    child: Text(
                      'No bookmark available!',
                      style: TextStyle(
                        fontFamily: 'KantumruyPro',
                        fontSize: 12.0,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                );
              } else {
                return SmartRefresher(
                  enablePullDown: true,
                    controller: _hackerNewsbookMarkController.refreshController,
                    onRefresh: () async {
                      await _hackerNewsbookMarkController.onRefresh();
                    },

                    // 🔄 custom Refresh Indicator (Header)
                    header: ClassicHeader(
                      refreshingText: 'Refreshing...',
                      completeText: 'Refresh Complete!',
                      failedText: 'Refresh Failed!',
                      idleText: 'Pull to Refresh',
                      releaseText: 'Release to Refresh',
                      refreshingIcon: Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF272397),
                      ),
                      completeIcon: Icon(
                        Icons.done_all_rounded,
                        color: Color(0xFF272397),
                      ),
                      failedIcon: Icon(
                        Icons.error_rounded,
                        color: Color(0xFF272397),
                      ),
                      idleIcon: Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFF272397),
                      ),
                      releaseIcon: Icon(
                        Icons.arrow_upward_rounded,
                        color: Color(0xFF272397),
                      ),

                      // position of the icon
                      iconPos: IconPosition.top,
                      textStyle: TextStyle(
                        fontFamily: 'KantumruyPro',
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF272397),
                      ),
                      completeDuration: Duration(milliseconds: 500),
                    ),
                    
                    // ccroll direction and physics
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                  
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10.0);
                    },
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(
                      top: 10.0,
                      right: 10.0,
                      bottom: 5.0,
                    ),
                    itemCount: _hackerNewsbookMarkController.bookmarkedList.length,
                    itemBuilder: (context, index) {
                  
                      final news = _hackerNewsbookMarkController.bookmarkedList[index];
                  
                      return GestureDetector(
                        onTap: _hackerNewsbookMarkController.isOpeningURL
                          ? null
                          : () {
                            _hackerNewsbookMarkController.openNewsLink(url: news.link);
                          },
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 5.0,
                            right: 5.0,
                            bottom: 10.0,
                          ),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // news image
                              GestureDetector(
                                onLongPress: () {
                                  _hackerNewsbookMarkController.previewPhoto(
                                    context: context,
                                    imageUrl: news.imageUrl,
                                    title: news.title,
                                  );
                                },
                                child: Container(
                                  height: 200.0,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF272397).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.only(
                                      topRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.first == _hackerNewsbookMarkController.bookmarkedList[index]
                                        ? Radius.circular(20.0)
                                        : Radius.zero,
                                      bottomRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.last == _hackerNewsbookMarkController.bookmarkedList[index]
                                        ? Radius.circular(20.0)
                                        : Radius.zero,
                                    ),
                                  ),
                                  child: news.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        key: UniqueKey(),
                                        imageUrl: news.imageUrl,
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.first == _hackerNewsbookMarkController.bookmarkedList[index]
                                                  ? Radius.circular(20.0)
                                                  : Radius.zero,
                                                bottomRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.last == _hackerNewsbookMarkController.bookmarkedList[index]
                                                  ? Radius.circular(20.0)
                                                  : Radius.zero,
                                              ),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageProvider,
                                              ),
                                            ),
                                          );
                                        },
                                        progressIndicatorBuilder: (context, url, progress) {
                                          if (progress.totalSize == null) {
                                            return Center(
                                              child: LoadingAnimationWidget.fallingDot(
                                                color: Color(0xFF272397),
                                                size: 30.0,
                                              ),
                                            );
                                          } else {
                                            double progressPercentage = progress.downloaded / progress.totalSize!;
                                            return Center(
                                              child: Text(
                                                'Loading... ${(progressPercentage * 100).toStringAsFixed(2)} %',
                                                style: TextStyle(
                                                  fontFamily: 'KantumruyPro',
                                                  fontSize: 12.0,
                                                  color: Color(0xFF272397),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        errorWidget: (context, url, error) {
                                          return Center(
                                            child: Image.asset(
                                              'assets/images/news-black.png',
                                              height: 60.0,
                                              width: 60.0,
                                              color: Color(0xFF272397),
                                            ),
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/news-black.png',
                                        height: 60.0,
                                        width: 60.0,
                                        color: Color(0xFF272397),
                                      ),
                                ),
                              ),
                  
                              // news source
                              const SizedBox(height: 15.0),
                              GestureDetector(
                                onLongPress: () {
                                  _hackerNewsbookMarkController.copyText(
                                    text: news.source,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hackerNewsbookMarkController.randomColor(),
                                    borderRadius: BorderRadius.only(
                                      topRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.first == _hackerNewsbookMarkController.bookmarkedList[index]
                                        ? Radius.circular(5.0)
                                        : Radius.zero,
                                      bottomRight: _hackerNewsbookMarkController.bookmarkedList.isNotEmpty && _hackerNewsbookMarkController.bookmarkedList.last == _hackerNewsbookMarkController.bookmarkedList[index]
                                        ? Radius.circular(5.0)
                                        : Radius.zero,
                                      ),
                                    ),
                                    child: Text(
                                      news.source.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: 'KantumruyPro',
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                  
                              // news title
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onLongPress: () {
                                  _hackerNewsbookMarkController.copyText(
                                    text: news.title,
                                  );
                                },
                                child: Text(
                                  news.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontFamily: 'KantumruyPro',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF272397),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onLongPress: () {
                                  _hackerNewsbookMarkController.copyText(
                                    text: news.description,
                                  );
                                },
                                child: Text(
                                  news.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontFamily: 'KantumruyPro',
                                    fontSize: 15.0,
                                    color: Color(0xFF272397),
                                  ),
                                ),
                              ),
                  
                              // day ago & more options
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                  
                                  // day ago
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/time.png',
                                        height: 18.0,
                                        width: 18.0,
                                        color: Color(0xFF272397),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        _hackerNewsbookMarkController.formatDate(dateStr: news.pubDate),
                                        style: TextStyle(
                                          fontFamily: 'KantumruyPro',
                                          fontSize: 12.0,
                                          color: Color(0xFF272397),
                                        ),
                                      ),
                                    ],
                                  ),
                  
                                  // group buttons
                                  Row(
                                    children: [
                  
                                      // share
                                      GestureDetector(
                                        onTap: () {
                                          _hackerNewsbookMarkController.shareNews(
                                            title: news.title,
                                            link: news.link,
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/share.png',
                                          height: 28.0,
                                          width: 28.0,
                                          color: Color(0xFF272397),
                                        ),
                                      ),
                  
                                      // remove from bookmark
                                      const SizedBox(width: 10.0),
                                      GestureDetector(
                                        onTap: () {
                                          _hackerNewsbookMarkController.removeFromBookmark(news: news);
                                        },
                                        child: Icon(
                                          Icons.bookmark_remove_rounded,
                                          color: Colors.red.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}