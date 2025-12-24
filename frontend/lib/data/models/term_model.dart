import '../../domain/entities/term_entity.dart';

class TermModel {
  final String id;
  final TermType termType;
  final String version;
  final String content;
  final DateTime createdAt;

  TermModel({
    required this.id,
    required this.termType,
    required this.version,
    required this.content,
    required this.createdAt,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
      id: json['id'] as String,
      termType: TermType.values.firstWhere(
        (e) => e.name == (json['term_type'] as String).toUpperCase(),
      ),
      version: json['version'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term_type': termType.name.toLowerCase(),
      'version': version,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
