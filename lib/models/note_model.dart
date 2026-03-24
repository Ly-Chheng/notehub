import 'dart:convert';

class Note {
  int? id; // optional if using auto-increment in DB
  String title;
  String subtitle; // can store plain text or JSON for rich text
  DateTime createdAt;
  DateTime updatedAt;
  String? color; // optional color string (hex)
  bool isFavorite;

  Note({
    this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.updatedAt,
    this.color,
    this.isFavorite = false,
  });

  // Convert Note object to Map (for SQLite/Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'color': color,
      'is_favorite': isFavorite ? 1 : 0, // SQLite boolean
    };
  }

  // Convert Map to Note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      color: map['color'],
      isFavorite: map['is_favorite'] == 1,
    );
  }

  // Optional: JSON serialization
  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source));
}