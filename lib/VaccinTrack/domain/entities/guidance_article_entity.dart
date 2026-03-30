class GuidanceRemarkEntity {
  final String id;
  final String text;
  final DateTime createdAt;

  const GuidanceRemarkEntity({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'createdAt': createdAt.toIso8601String()};
  }

  factory GuidanceRemarkEntity.fromJson(Map<String, dynamic> json) {
    return GuidanceRemarkEntity(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class GuidanceArticleEntity {
  final String id;
  final String title;
  final String category; // side_effects | advice | warning_signs
  final String content;
  final List<GuidanceRemarkEntity> remarks;

  const GuidanceArticleEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    this.remarks = const [],
  });

  GuidanceArticleEntity copyWith({
    String? id,
    String? title,
    String? category,
    String? content,
    List<GuidanceRemarkEntity>? remarks,
  }) {
    return GuidanceArticleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'remarks': remarks.map((e) => e.toJson()).toList(),
    };
  }

  factory GuidanceArticleEntity.fromJson(Map<String, dynamic> json) {
    return GuidanceArticleEntity(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? 'side_effects').toString(),
      content: (json['content'] ?? '').toString(),
      remarks: ((json['remarks'] as List<dynamic>?) ?? [])
          .map(
            (e) => GuidanceRemarkEntity.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }
}
