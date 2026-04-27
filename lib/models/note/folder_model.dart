class FolderModel {
  int? id;
  String title;
  String? date;

  FolderModel({
    this.id,
    required this.title,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date ?? DateTime.now().toIso8601String(),
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      title: map['title'] ?? '',
      date: map['date'],
    );
  }
}
