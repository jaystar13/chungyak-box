import 'package:equatable/equatable.dart';

enum TermType { TERMS_OF_USE, PRIVACY_POLICY }

class TermEntity extends Equatable {
  final String id;
  final TermType termType;
  final String version;
  final String content;
  final DateTime createdAt;

  const TermEntity({
    required this.id,
    required this.termType,
    required this.version,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, termType, version, content, createdAt];
}
