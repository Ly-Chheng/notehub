class Folder {
  String title;
  int colorValue;
  bool isDefault;
  int count;
  bool isPinned; // NEW

  Folder({
    required this.title,
    required this.colorValue,
    this.isDefault = false,
    this.count = 0,
    this.isPinned = false, // default false
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'colorValue': colorValue,
      'isDefault': isDefault,
      'count': count,
      'isPinned': isPinned,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      title: map['title'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF000000,
      isDefault: map['isDefault'] ?? false,
      count: map['count'] ?? 0,
      isPinned: map['isPinned'] ?? false,
    );
  }
}