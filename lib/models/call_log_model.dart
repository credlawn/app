
class CallLogModel {
  final String phoneNumber;
  final int duration;
  final String callType;
  final int timestamp;
  final String user;

  CallLogModel({
    required this.phoneNumber,
    required this.duration,
    required this.callType,
    required this.timestamp,
    required this.user,
  });

  factory CallLogModel.fromMap(Map<String, dynamic> map) {
    return CallLogModel(
      phoneNumber: map['phone_number'] ?? '',
      duration: map['duration'] ?? 0,
      callType: map['call_type'] ?? 'UNKNOWN',
      timestamp: map['timestamp'] ?? 0,
      user: map['user'] ?? '',
    );
  }
}
