class LapModel {
  final int lapNumber;
  final int totalTimeMs;
  final String formattedTime;

  LapModel({required this.lapNumber, required this.totalTimeMs, required this.formattedTime});

  Map<String, dynamic> toJson() => {
        'lapNumber': lapNumber,
        'totalTimeMs': totalTimeMs,
        'formattedTime': formattedTime,
      };

  factory LapModel.fromJson(Map<String, dynamic> json) => LapModel(
        lapNumber: json['lapNumber'],
        totalTimeMs: json['totalTimeMs'],
        formattedTime: json['formattedTime'],
      );
}
