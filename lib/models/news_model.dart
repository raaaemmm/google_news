import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as html;

class NewsModel {
  
  final String title;
  final String link;
  final String description;
  final String pubDate;
  final String imageUrl;
  final String source;

  NewsModel({
    required this.title,
    required this.link,
    required this.description,
    required this.pubDate,
    required this.imageUrl,
    required this.source,
  });

  factory NewsModel.fromXml(xml.XmlElement item) {
    final title = _getElementText(item, 'title');
    final link = _getElementText(item, 'link');
    final description = _getElementText(item, 'description');
    final pubDate = _getElementText(item, 'pubDate');

    final sourceElement = item.findElements('source').firstOrNull;
    final source = sourceElement?.innerText ?? '';
    final sourceUrl = sourceElement?.getAttribute('url') ?? '';

    // extract image URL
    String imageUrl = _getImageUrl(item) ?? _getFaviconUrl(sourceUrl: sourceUrl);

    return NewsModel(
      title: _cleanText(title),
      link: link,
      description: _extractMainContent(description: description),
      pubDate: pubDate,
      imageUrl: imageUrl,
      source: source,
    );
  }

  // fromJson method
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      description: json['description'] ?? '',
      pubDate: json['pubDate'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'] ?? '',
    );
  }

  // convert NewsModel to JSON
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

  // remove extra whitespace and newlines
  static String _cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // extract news content (removes unnecessary HTML)
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

  // extract image from <media:content> or <enclosure>
  static String? _getImageUrl(xml.XmlElement item) {
    final mediaContent = item.findElements('media:content').firstOrNull;
    if (mediaContent != null) {
      return mediaContent.getAttribute('url');
    }

    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null && enclosure.getAttribute('type')?.startsWith('image') == true) {
      return enclosure.getAttribute('url');
    }

    // extract from description if available
    final description = _getElementText(item, 'description');
    return _extractImageFromDescription(description);
  }

  // extract image from <description> (if contains <img>)
  static String? _extractImageFromDescription(String description) {
    try {
      final document = html.parse(description);
      final imgTag = document.getElementsByTagName('img').firstOrNull;
      return imgTag?.attributes['src'];
    } catch (e) {
      debugPrint('Error extracting image from description: $e');
      return null;
    }
  }

  // get website favicon URL if no image is found
  static String _getFaviconUrl({required String sourceUrl}) {
    try {
      if (sourceUrl.isNotEmpty) {
        final uri = Uri.parse(sourceUrl);
        return 'https://www.google.com/s2/favicons?domain=${uri.host}&sz=128';
      }
    } catch (e) {
      debugPrint('Error creating favicon URL: $e');
    }
    return 'https://news.google.com/favicon.ico'; // default fallback image
  }

  // override the equality operator and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel && other.link == link; // unique property: link
  }

  @override
  int get hashCode => link.hashCode; // using link to generate unique hash code
}