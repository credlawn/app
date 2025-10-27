class FcmLogModel {
  final String name;
  final String title;
  final String body;
  final String? status;
  final String messageStatus;
  final DateTime creation;

  FcmLogModel({
    required this.name,
    required this.title,
    required this.body,
    this.status,
    required this.messageStatus,
    required this.creation,
  });

  factory FcmLogModel.fromJson(Map<String, dynamic> json) {
    return FcmLogModel(
      name: json['name'] ?? '',
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      status: json['status'],
      messageStatus: json['message_status'] ?? '',
      // Safely parse the creation date
      creation: json['creation'] != null
          ? DateTime.parse(json['creation'])
          : DateTime.now(),
    );
  }
}
