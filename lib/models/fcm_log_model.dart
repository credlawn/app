class FcmLogModel {
  final String title;
  final String body;
  final String? status;
  final DateTime creation;

  FcmLogModel({
    required this.title,
    required this.body,
    this.status,
    required this.creation,
  });

  factory FcmLogModel.fromJson(Map<String, dynamic> json) {
    return FcmLogModel(
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      status: json['status'],
      // Safely parse the creation date
      creation: json['creation'] != null
          ? DateTime.parse(json['creation'])
          : DateTime.now(),
    );
  }
}
