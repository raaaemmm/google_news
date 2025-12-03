import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/news_by_source_controller.dart';
import 'package:google_news/models/news_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsBySourceScreen extends StatelessWidget {
  NewsBySourceScreen({super.key, required this.news});

  final _newsBySourceController = Get.put(NewsBySourceController());
  final _bookMarkController = Get.put(BookmarkController());
  final NewsModel news;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsBySourceController>(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0),
              ),
            ),
            scrolledUnderElevation: 0.0,
            toolbarHeight: 70.0,
            centerTitle: true,
            elevation: 0.0,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
            title: Text(
              news.source.toUpperCase(),
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body: GetBuilder<NewsBySourceController>(
            builder: (_) {
              if(_newsBySourceController.isLoading){
                return Center(
                  child: LoadingAnimationWidget.fallingDot(
                    color: Theme.of(context).primaryColor,
                    size: 30.0,
                  ),
                );
              } else if(_newsBySourceController.newsSourceList.isEmpty){
                return Center(
                  child: Text(
                    'No news from (${news.source.toUpperCase()}) available!',
                    style: TextStyle(
                      fontFamily: 'KantumruyPro',
                      fontSize: 12.0,
                      color: Colors.pink,
                    ),
                  ),
                );
              } else {
                return SmartRefresher(
                  enablePullDown: true,
                    controller: _newsBySourceController.refreshController,
                    onRefresh: () async {
                      await _newsBySourceController.onRefreshNewsBySource(
                        source: news.source,
                      );
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
                        color: Theme.of(context).primaryColor,
                      ),
                      completeIcon: Icon(
                        Icons.done_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      failedIcon: Icon(
                        Icons.error_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      idleIcon: Icon(
                        Icons.arrow_downward_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      releaseIcon: Icon(
                        Icons.arrow_upward_rounded,
                        color: Theme.of(context).primaryColor,
                      ),

                      // position of the icon
                      iconPos: IconPosition.top,
                      textStyle: TextStyle(
                        fontFamily: 'KantumruyPro',
                        fontSize: 12.0,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).primaryColor,
                      ),
                      completeDuration: Duration(milliseconds: 500),
                    ),

                    // scroll direction and physics
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                  
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.only(
                      top: 10.0,
                      left: 10.0,
                      right: 10.0,
                      bottom: 5.0,
                    ),
                    itemCount: _newsBySourceController.newsSourceList.length,
                    itemBuilder: (context, index) {
                  
                      final news = _newsBySourceController.newsSourceList[index];
                  
                      return GestureDetector(
                        onTap: _newsBySourceController.isOpeningURL
                          ? null
                          : () {
                            _newsBySourceController.openNewsLink(url: news.link);
                          },
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 5.0,
                            left: 5.0,
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
                              Container(
                                height: 200.0,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
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
                                              topLeft: Radius.circular(20.0),
                                              bottomRight: Radius.circular(20.0),
                                            ),
                                            image: DecorationImage(
                                              image: imageProvider,
                                            ),
                                          ),
                                        );
                                      },
                                      progressIndicatorBuilder: (context, url, progress) {
                                        if (progress.totalSize == null) {
                                          return Center(
                                            child: LoadingAnimationWidget.fallingDot(
                                              color: Theme.of(context).primaryColor,
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
                                                color: Theme.of(context).primaryColor,
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
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/news-black.png',
                                      height: 60.0,
                                      width: 60.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                  
                              // news source
                              const SizedBox(height: 15.0),
                              GestureDetector(
                                onLongPress: () {
                                  _newsBySourceController.copyText(
                                    text: news.source,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bookMarkController.randomColor(),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5.0),
                                      bottomRight: Radius.circular(5.0),
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
                                  _newsBySourceController.copyText(
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
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onLongPress: () {
                                  _newsBySourceController.copyText(
                                    text: news.description,
                                  );
                                },
                                child: Text(
                                  news.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  style: TextStyle(
                                    fontFamily: 'KantumruyPro',
                                    fontSize: 15.0,
                                    color: Theme.of(context).primaryColor,
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
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        _newsBySourceController.formatDate(dateStr: news.pubDate),
                                        style: TextStyle(
                                          fontFamily: 'KantumruyPro',
                                          fontSize: 12.0,
                                          color: Theme.of(context).primaryColor,
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
                                          _newsBySourceController.shareNews(
                                          title: news.title,
                                          link: news.link,
                                        );
                                        },
                                        child: Image.asset(
                                        'assets/images/share.png',
                                        height: 28.0,
                                        width: 28.0,
                                      ),
                                      ),
                  
                                      // add to bookmark
                                      const SizedBox(width: 10.0),
                                      GetBuilder<BookmarkController>(
                                        builder: (_) {
                                          return GestureDetector(
                                            onTap: () {
                                              _bookMarkController.addToBookmark(news: news);
                                            },
                                            child: Icon(
                                              _bookMarkController.isAddedToBookmark(news: news)
                                                ? Icons.bookmark_rounded
                                                : Icons.bookmark_add_rounded,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          );
                                        },
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
      }
    );
  }
}