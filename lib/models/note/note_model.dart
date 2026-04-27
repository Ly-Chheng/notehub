import 'dart:convert';

class NoteModel {
  int? id;
  int folderId;
  String title;
  String content;
  String date;
  bool isLocked;
  bool isPinned;
  int bgColor;
  List<String> imagePaths;
  bool showTable;
  List<List<String>> tableData;
  List<Map<String, dynamic>> drawingLayers;

  NoteModel({
    this.id,
    required this.folderId,
    required this.title,
    required this.content,
    required this.date,
    this.isLocked = false,
    this.isPinned = false,
    this.bgColor = 0,
    this.imagePaths = const [],
    this.showTable = false,
    this.tableData = const [],
    this.drawingLayers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_id': folderId,
      'title': title,
      'content': content,
      'date': date,
      'is_locked': isLocked ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'bg_color': bgColor,
      'image_paths': jsonEncode(imagePaths),
      'show_table': showTable ? 1 : 0,
      'table_data': jsonEncode(tableData),
      'drawing_layers': jsonEncode(drawingLayers),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      folderId: map['folder_id'],
      title: map['title'] ?? "",
      content: map['content'] ?? "",
      date: map['date'] ?? "",
      isLocked: map['is_locked'] == 1,
      isPinned: map['is_pinned'] == 1,
      bgColor: map['bg_color'] ?? 0,
      imagePaths: List<String>.from(jsonDecode(map['image_paths'] ?? '[]')),
      showTable: map['show_table'] == 1,
      tableData: (jsonDecode(map['table_data'] ?? '[[]]') as List)
          .map((row) => List<String>.from(row))
          .toList(),
      drawingLayers: List<Map<String, dynamic>>.from(jsonDecode(map['drawing_layers'] ?? '[]')),
    );
  }
}