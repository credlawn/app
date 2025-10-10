class AttendanceResponse {
  final String message;

  AttendanceResponse({required this.message});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      message: json['message'] ?? 'Attendance submitted',
    );
  }
}
