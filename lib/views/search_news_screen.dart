import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/book_mark_controller.dart';
import 'package:google_news/controllers/news/news_by_source_controller.dart';
import 'package:google_news/controllers/news/search_news_controller.dart';
import 'package:google_news/views/news_by_source_screen.dart';
import 'package:google_news/views/see_all_searched_history_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchNewsScreen extends StatelessWidget {
  SearchNewsScreen({super.key});

  final _searchNewsController = Get.put(SearchNewsController());
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
          'Find Newest Hot News',
          style: TextStyle(
            fontFamily: 'KantumruyPro',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [

          // search field
          GetBuilder<SearchNewsController>(
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _searchNewsController.searchController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontFamily: 'KantumruyPro',
                    fontSize: 15.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    suffixIcon: _searchNewsController.showAndHideClearButton()
                        ? IconButton(
                            onPressed: () {
                              _searchNewsController.clearText();
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                            ),
                          )
                        : null,
                    fillColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    filled: true,
                    hintText: 'Search news...',
                    hintStyle: TextStyle(
                      fontFamily: 'KantumruyPro',
                      fontSize: 15.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onChanged: (query) {
                    _searchNewsController.onSearchChanged(query: query.trim());
                  },
                ),
              );
            },
          ),
      
      
          // searched news
          Expanded(
            child: GetBuilder<SearchNewsController>(
              builder: (_) {
                if (_searchNewsController.isLoading) {
                  return Center(
                    child: LoadingAnimationWidget.fallingDot(
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                  );
                } else if (_searchNewsController.searchedNewsList.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // show history
                      if(_searchNewsController.searchedNewsHistoryList.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          
                              // title
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent ${_searchNewsController.searchedNewsHistoryList.length > 1 ? 'searches' : 'search'} (${_searchNewsController.searchedNewsHistoryList.length})',
                                      style: TextStyle(
                                        fontFamily: 'KantumruyPro',
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // body
                              const SizedBox(height: 10.0),
                              GetBuilder<SearchNewsController>(
                                builder: (_) {

                                  int maxItems = 3; // show only 3 searched history items
                                  bool showSeeAll = _searchNewsController.searchedNewsHistoryList.length > maxItems;
                                  
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ...List.generate(
                                        _searchNewsController.searchedNewsHistoryList.length > maxItems
                                            ? maxItems
                                            : _searchNewsController.searchedNewsHistoryList.length,
                                        (index) {
                                          final keyword = _searchNewsController.searchedNewsHistoryList[index];
                                          return GestureDetector(
                                            onTap: () {
                                              _searchNewsController.searchController.text = keyword.trim();
                                              _searchNewsController.searchNews(query: keyword);
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.all(3.0),
                                              width: MediaQuery.of(context).size.width,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0,
                                                vertical: 10.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(10.0),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      keyword,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontFamily: 'KantumruyPro',
                                                        fontSize: 15.0,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _searchNewsController.removeSearchNewsKeyword(keyword);
                                                    },
                                                    child: Icon(
                                                      Icons.clear_rounded,
                                                      size: 18.0,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      // see all searched histories
                                      if (showSeeAll)
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(
                                              ()=> SeeAllSearchedHistoryScreen(),
                                              transition: Transition.downToUp,
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              right: 5.0,
                                            ),
                                            child: Text(
                                              'See all search history',
                                              style: TextStyle(
                                                fontFamily: 'KantumruyPro',
                                                fontSize: 12.0,
                                                color: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      // no searched photo
                      Expanded(
                        child: Center(
                          child: Text(
                            'No news available!',
                            style: TextStyle(
                              fontFamily: 'KantumruyPro',
                              fontSize: 12.0,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return SmartRefresher(
                    enablePullDown: true,
                      controller: _searchNewsController.searchRefreshController,
                      onRefresh: () async {
                        await _searchNewsController.onRefreshSearchNews();
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
                        bottom: 15.0
                      ),
                      itemCount: _searchNewsController.searchedNewsList.length,
                      itemBuilder: (context, index) {
                    
                        final news = _searchNewsController.searchedNewsList[index];
                    
                        return GestureDetector(
                          onTap: _searchNewsController.isOpeningURL
                            ? null
                            : () {
                              _searchNewsController.openNewsLink(url: news.link);
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
                                    _searchNewsController.copyText(
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
                                      color: _searchNewsController.randomColor(),
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
                                    _searchNewsController.copyText(
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
                                    _searchNewsController.copyText(
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
                                          _searchNewsController.formatDate(dateStr: news.pubDate),
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
                                            _searchNewsController.shareNews(
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