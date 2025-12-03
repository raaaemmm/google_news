import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as html;

class HackerNewsModel {
  final String title;
  final String link;
  final String description;
  final String pubDate;
  final String imageUrl;
  final String source;

  HackerNewsModel({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    required this.imageUrl,
    required this.source,
  });

  factory HackerNewsModel.fromXml(xml.XmlElement item) {
    final title = _getElementText(item, 'title');
    final link = _getElementText(item, 'link');
    final description = _getElementText(item, 'description');
    final pubDate = _getElementText(item, 'pubDate');

    // the Hacker News RSS feed doesn't have a <source> element, so we use a default source
    final source = "The Hacker News";

    // extract image URL from <enclosure> (if available)
    String imageUrl = _getImageUrl(item) ?? _getFaviconUrl();

    return HackerNewsModel(
      title: _cleanText(title),
      link: link,
      description: _extractMainContent(description: description),
      pubDate: pubDate,
      imageUrl: imageUrl,
      source: source,
    );
  }

  // fromJson method
  factory HackerNewsModel.fromJson(Map<String, dynamic> json) {
    return HackerNewsModel(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      pubDate: json['pubDate'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'] ?? '',
    );
  }

  // convert HackerNewsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'description': description,
      'pubDate': pubDate,
      'imageUrl': imageUrl,
      'source': source,
    };
  }

  // get text content of an XML tag
  static String _getElementText(xml.XmlElement item, String tag) {
    return item.findElements(tag).firstOrNull?.innerText ?? '';
  }

  // clean the text (remove extra whitespaces)
  static String _cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // extract main content (remove unnecessary HTML)
  static String _extractMainContent({required String description}) {
    try {
      final document = html.parse(description);
      final firstArticle = document.getElementsByTagName('a').firstOrNull;
      return firstArticle != null ? _cleanText(firstArticle.text) : _cleanText(description.replaceAll(RegExp(r'<[^>]*>'), ' '));
    } catch (e) {
      debugPrint('Error extracting main content: $e');
      return description;
    }
  }

  // extract image URL from <enclosure> element (if available)
  static String? _getImageUrl(xml.XmlElement item) {
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null && enclosure.getAttribute('type')?.startsWith('image') == true) {
      return enclosure.getAttribute('url');
    }
    return null;
  }

  // get favicon URL for the source (as a fallback)
  static String _getFaviconUrl() {
    return 'https://news.ycombinator.com/favicon.ico'; // default favicon for Hacker News
  }

  // override the equality operator and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HackerNewsModel && other.link == link; // unique property: link
  }

  @override
  int get hashCode => link.hashCode; // using link to generate a unique hash code
}
