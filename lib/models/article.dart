import 'idea.dart';

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.source,
    required this.reads,
    required this.ideas,
  });

  final String id;
  final String title;
  final String author;
  final String source;
  final int reads;
  final List<Idea> ideas;
}
