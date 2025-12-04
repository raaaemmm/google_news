import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/hacker_news_bookmark_controller.dart';
import 'package:google_news/controllers/news/hacker_news_controller.dart';
import 'package:google_news/widgets/action_hint_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TheHackerNewsScreen extends StatelessWidget {
  TheHackerNewsScreen({super.key});

  final _hackerNewsController = Get.put(HackerNewsController());
  final _hackerNewsbookMarkController = Get.put(HackerNewsBookmarkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF272397),
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
              'The Hacker News',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Latest hacker news around the worlds 🌐',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 15.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            height: 40.0,
            width: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 1.0,
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/THN.jpg',
                ),
              )
            ),
          ),
          const SizedBox(width: 15.0),
        ],
      ),
      body: GetBuilder<HackerNewsController>(
        builder: (_) {
          if(_hackerNewsController.isLoading){
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // loading icon
                  LoadingAnimationWidget.fallingDot(
                    color: Color(0xFF272397),
                    size: 30.0,
                  ),

                  // text
                  const SizedBox(height: 15.0),
                  Text(
                    'Be right there, please wait...',
                    style: TextStyle(
                      fontFamily: 'KantumruyPro',
                      fontSize: 13.0,
                      color: Color(0xFF272397),
                    ),
                  ),
                ],
              ),
            );
          } else if(_hackerNewsController.hackerNewsList.isEmpty){
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
                controller: _hackerNewsController.refreshController,
                onRefresh: () async {
                  await _hackerNewsController.onRefresh();
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
                    Icons.done_rounded,
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
                
                // scroll direction and physics
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
              
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 15.0);
                },
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(15.0),
                itemCount: _hackerNewsController.hackerNewsList.length,
                itemBuilder: (context, index) {
              
                  final news = _hackerNewsController.hackerNewsList[index];
              
                  return Column(
                    children: [

                      // show hint at random position
                      if(index == _hackerNewsController.hintPosition && _hackerNewsController.showHint) ...[
                        ActionHintWidget(
                          hintText: _hackerNewsController.getRandomHint(),
                          icon: Icons.touch_app_rounded,
                          backgroundColor: Color(0xFF272397).withValues(alpha: 0.1),
                          textColor: Color(0xFF272397),
                          iconColor: Color(0xFF272397),
                          onDismiss: () {
                            _hackerNewsController.dismissHint(); // dismiss hint
                          },
                          onTap: () {
                            _hackerNewsController.getRandomHint(); // get new random hint
                            _hackerNewsController.update(); // update UI
                          },
                        ),
                      ],

                      // news card
                      GestureDetector(
                        onTap: _hackerNewsController.isOpeningURL
                          ? null
                          : () {
                            _hackerNewsController.openNewsLink(url: news.link);
                          },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // news image | hold on to preview news image
                              GestureDetector(
                                onLongPress: () {
                                  _hackerNewsController.previewPhoto(
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
                                  _hackerNewsController.copyText(
                                    text: news.source,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _hackerNewsController.randomColor(),
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
                                  _hackerNewsController.copyText(
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
                                  _hackerNewsController.copyText(
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
                                        _hackerNewsController.formatDate(dateStr: news.pubDate),
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
                                          _hackerNewsController.shareNews(
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
                                    
                                      // add to bookmark
                                      const SizedBox(width: 10.0),
                                      GetBuilder<HackerNewsBookmarkController>(
                                        builder: (_) {
                                          return GestureDetector(
                                            onTap: () {
                                              _hackerNewsbookMarkController.addToBookmark(news: news);
                                            },
                                            child: Icon(
                                              _hackerNewsbookMarkController.isAddedToBookmark(news: news)
                                                ? Icons.bookmark_rounded
                                                : Icons.bookmark_add_rounded,
                                              color: Color(0xFF272397),
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
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}