import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_news/models/hacker_news_model.dart';
import 'package:xml/xml.dart' as xml;

class HackerNewsService {
  final Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    ),
  );

  static const String _baseUrl = 'https://feeds.feedburner.com/TheHackersNews';

  List<HackerNewsModel> _parseXmlResponse({required String xmlString}) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      final newsList = items.map((item) => HackerNewsModel.fromXml(item)).toList();

      debugPrint('Fetched hacker news data: 👉 ${newsList.length}');

      // show formatted JSON output
      debugPrint(jsonEncode(newsList.map((news) => {
        "Title": news.title,
        "Link": news.link,
        "Description": news.description,
        "Published Date": news.pubDate,
        "Image URL": news.imageUrl,
        "Source": news.source,
      }).toList()));

      return newsList;
    } catch (e) {
      debugPrint('Error parsing XML: $e');
      rethrow;
    }
  }

  Future<List<HackerNewsModel>> getTopStories() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        debugPrint('Success with status code: 👉 ${response.statusCode}');
        return _parseXmlResponse(xmlString: response.data);
      } else {
        debugPrint('Failed to fetch top stories. Status: 👉 ${response.statusCode}');
        throw Exception('Failed to get top stories. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching top stories: $e');
      rethrow;
    }
  }
}
