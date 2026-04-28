class FolderModel {
  int? id;
  String title;
  String? date;
  bool isPinned;
  bool isLocked;

  FolderModel({
    this.id,
    required this.title,
    this.date,
    this.isPinned = false,
    this.isLocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date ?? DateTime.now().toIso8601String(),
      'isPinned': isPinned ? 1 : 0,
      'isLocked': isLocked ? 1 : 0,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      title: map['title'] ?? '',
      date: map['date'],
      isPinned: map['isPinned'] == 1 || map['isPinned'] == true,
      isLocked: map['isLocked'] == 1 || map['isLocked'] == true,
    );
  }
}
