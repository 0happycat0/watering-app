import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String title;
  final int date; // Unix timestamp
  final String url;
  final String thumb;
  final String thumbL;
  final String description;

  const Article({
    this.title = '',
    this.date = 0,
    this.url = '',
    this.thumb = '',
    this.thumbL = '',
    this.description = '',
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    title: json['title'] ?? '',
    date: json['date'] ?? 0, 
    url: json['url'] ?? '',
    thumb: json['thumb'] ?? '',
    thumbL: json['thumbL'] ?? '',
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'date': date,
      'url': url,
      'thumb': thumb,
      'thumbL': thumbL,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
    title,
    date,
    url,
    thumb,
    thumbL,
    description,
  ];
}