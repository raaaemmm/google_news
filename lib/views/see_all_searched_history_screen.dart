import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_news/controllers/news/search_news_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeeAllSearchedHistoryScreen extends StatelessWidget {
  SeeAllSearchedHistoryScreen({super.key});

  final _searchNewsController = Get.put(SearchNewsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchNewsController>(
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
            toolbarHeight: 80.0,
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
              _searchNewsController.searchedNewsHistoryList.isEmpty
                ? 'Search history'
                : 'Search histor${_searchNewsController.searchedNewsHistoryList.length > 1 ? 'ies' : 'y'} (${_searchNewsController.searchedNewsHistoryList.length})',
              style: TextStyle(
                fontFamily: 'KantumruyPro',
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _searchNewsController.searchedNewsHistoryList.isEmpty
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Clear Search History',
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            content: Text(
                              'This action will permanently delete your entire search history. 🗑️\n\n'
                              'Please note:\n'
                              '• All saved searches will be removed\n'
                              '• This action cannot be undone\n'
                              '• Your history is stored locally on your device only\n\n'
                              'Would you like to proceed? 🤔',
                              style: TextStyle(
                                fontFamily: 'KantumruyPro',
                                fontSize: 13.0,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'KantumruyPro',
                                    fontSize: 13.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _searchNewsController.removeAllSearchNewsKeywords().whenComplete(
                                    () {
                                      Get.back(); // pop-up alert
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  overlayColor: Colors.pink.shade800.withValues(alpha: 0.1),
                                ),
                                child: Text(
                                  'Delete All',
                                  style: TextStyle(
                                    fontFamily: 'KantumruyPro',
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink.shade800,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
                    Icons.delete_forever_rounded,
                    color: Colors.pink.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 15.0),
            ],
          ),
          body: GetBuilder<SearchNewsController>(
            builder: (_) {
              if(_searchNewsController.isLoadingHistory){
                return Center(
                  child: LoadingAnimationWidget.fallingDot(
                    color: Theme.of(context).primaryColor,
                    size: 30.0,
                  ),
                );
              } else if(_searchNewsController.searchedNewsHistoryList.isEmpty){
                return Center(
                  child: Text(
                    'No searched history available!',
                    style: TextStyle(
                      fontFamily: 'KantumruyPro',
                      fontSize: 12.0,
                      color: Colors.pink.shade800,
                    ),
                  ),
                );
              } else {
                return SmartRefresher(
                  enablePullDown: true,
                  controller: _searchNewsController.historyRefreshController,
                  onRefresh: () async {
                    await _searchNewsController.onRefreshSearchHistory();
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
                      Icons.done_all_rounded,
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
        
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 5.0);
                    },
                    padding: EdgeInsets.all(15.0),
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: _searchNewsController.searchedNewsHistoryList.length,
                    itemBuilder: (context, index) {
                  
                      final keyword = _searchNewsController.searchedNewsHistoryList[index];
                  
                      return GestureDetector(
                        onTap: () {
                          _searchNewsController.searchController.text = keyword.trim();
                          _searchNewsController.searchNews(query: keyword);
                  
                          // back to Search News Screen
                          Get.back();
                        },
                        child: Container(
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

                              // clear & check newest or latest searched keyword
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
                );
              }
            },
          ),
        );
      }
    );
  }
}