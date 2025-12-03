import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:google_news/models/news_model.dart';

class NewsService {
  final _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    ),
  );

  static const String _baseUrl = 'https://news.google.com/rss';

  List<NewsModel> _parseXmlResponse({
    required String xmlString,
  }) {
    try {
      
      final document = xml.XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      final newsList = items.map((item) => NewsModel.fromXml(item)).toList();

      debugPrint('Fetched news data: 👉 ${newsList.length}');

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

  Future<List<NewsModel>> getTopStories() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'hl': 'en-US',
          'gl': 'US',
          'ceid': 'US:en',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Success with status code: 👉 ${response.statusCode}');
        return _parseXmlResponse(xmlString: response.data);
      } else {
        debugPrint('Failed to search news. Status: 👉 ${response.statusCode}');
        throw Exception('Failed to get top stories. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting top stories: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getNewsByTopic({
    required String topic,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/headlines/section/topic/$topic',
        queryParameters: {
          'hl': 'en-US',
          'gl': 'US',
          'ceid': 'US:en',
        },
      );

      if (response.statusCode == 200) {
        return _parseXmlResponse(xmlString: response.data);
      } else {
        throw Exception('Failed to get topic news. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting topic news: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getNewsByLocation({
    required String location,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/headlines/section/geo/$location',
        queryParameters: {
          'hl': 'en-US',
          'gl': 'US',
          'ceid': 'US:en',
        },
      );

      if (response.statusCode == 200) {
        return _parseXmlResponse(xmlString: response.data);
      } else {
        throw Exception('Failed to get location news. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting location news: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> getNewsBySource({
    required String source,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'q': 'source:$source',
          'hl': 'en-US',
          'gl': 'US',
          'ceid': 'US:en',
        },
      );

      if (response.statusCode == 200) {
        return _parseXmlResponse(xmlString: response.data);
      } else {
        debugPrint('Failed to get news from source. Status: 👉 ${response.statusCode}');
        throw Exception('Failed to get news from $source. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting news from source: $e');
      rethrow;
    }
  }

  Future<List<NewsModel>> searchNews({
    required String query,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'hl': 'en-US',
          'gl': 'US',
          'ceid': 'US:en',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Success with status code: 👉 ${response.statusCode}');
        return _parseXmlResponse(xmlString: response.data);
      } else {
        debugPrint('Failed to search news. Status: 👉 ${response.statusCode}');
        throw Exception('Failed to search news. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching news: $e');
      rethrow;
    }
  }
}
