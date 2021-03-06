import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BlogPost {
  final String title;
  final DateTime publishedDate;
  final String body;

  String get date => DateFormat('d MMMM y').format(publishedDate);

  BlogPost({this.title, this.publishedDate, this.body});

  factory BlogPost.fromDocument(DocumentSnapshot doc) {
    final map = doc?.data();
    if (map == null) return null;

    return BlogPost(
      title: '[title]',
      publishedDate: DateTime.now(),
      body: '[body]',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'published_date': Timestamp.fromDate(publishedDate),
    };
  }
}