import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/news_by_source_controller.dart';
import 'package:google_news/controllers/news/news_controller.dart';
import 'package:google_news/views/news_by_source_screen.dart';
import 'package:google_news/views/search_news_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsScreen extends StatelessWidget {
  NewsScreen({super.key});

  final _newsController = Get.put(NewsController());
  final _bookMarkController = Get.put(BookmarkController());
  final _newsBySourceController = Get.put(NewsBySourceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20.0),
          )
        ),
        scrolledUnderElevation: 0.0,
        toolbarHeight: 90.0,
        centerTitle: false,
        elevation: 0.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breaking News',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Latest news around the worlds 🌐',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.to(
                ()=> SearchNewsScreen(),
                transition: Transition.downToUp,
              );
            },
            child: Container(
              height: 40.0,
              width: 40.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.search_rounded,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 15.0),
        ],
      ),
      body: Column(
        children: [

          // topic items | similar to categories
          GetBuilder<NewsController>(
            builder: (_) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 5.0,
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                ),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _newsController.newsTopics.length,
                    (index) {
                      return GestureDetector(
                        onTap: () {
                          _newsController.selecteTopic(
                            index: index,
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide.none,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 8.0,
                            ),
                            margin: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              gradient: index == 0
                                  ? LinearGradient(
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Colors.pink,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    )
                                  : null,
                              color: _newsController.defaultIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              _newsController.newsTopics[index],
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 12.0,
                                color: _newsController.defaultIndex == index
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                fontWeight:
                                    _newsController.defaultIndex == index
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // news items
          Expanded(
            child: GetBuilder<NewsController>(
              builder: (_) {
                if(_newsController.isLoading || _newsController.isLoadingLocation){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // loading icon
                        LoadingAnimationWidget.fallingDot(
                          color: Theme.of(context).primaryColor,
                          size: 30.0,
                        ),

                        // text
                        const SizedBox(height: 15.0),
                        Text(
                          'Be right there, please wait...',
                          style: TextStyle(
                            fontFamily: 'KantumruyPro',
                            fontSize: 13.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if(_newsController.topStories.isEmpty){
                  return Center(
                    child: Text(
                      'No news available!',
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
                      controller: _newsController.refreshController,
                      onRefresh: () async {
                        if(_newsController.defaultIndex == 0){
                          await _newsController.onRefresh();
                        } else if (_newsController.defaultIndex == 1) {
                          await _newsController.getNewsByLocation(location: _newsController.newsTopics[1]);
                        } else {
                          await _newsController.getNewsByTopic(
                            topic: _newsController.newsTopics[_newsController.defaultIndex],
                          );
                        }
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
                        left: 10.0,
                        right: 10.0,
                        bottom: 5.0,
                      ),
                      itemCount: _newsController.topStories.length,
                      itemBuilder: (context, index) {
                    
                        final news = _newsController.topStories[index];
                    
                        return GestureDetector(
                          onTap: _newsController.isOpeningURL
                            ? null
                            : () {
                              _newsController.openNewsLink(url: news.link);
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
                                    _newsController.copyText(
                                      text: news.source,
                                    );
                                  },
                                  onTap: () {
                                    Get.to(
                                      ()=> NewsBySourceScreen(news: news),
                                      transition: Transition.downToUp,
                                    );

                                    // init get news by sources
                                    _newsBySourceController.getNewsBySource(
                                      source: news.source,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 5.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _newsController.randomColor(),
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
                                    _newsController.copyText(
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
                                    _newsController.copyText(
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
                                          _newsController.formatDate(dateStr: news.pubDate),
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
                                            _newsController.shareNews(
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
                                          }
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
          ),
        ],
      ),
    );
  }
}