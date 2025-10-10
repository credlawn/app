class AttendanceRecord {
  final String date;
  final String inTime;
  final String outTime;
  final String status;

  AttendanceRecord({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['attendance_date'] ?? 'N/A',
      inTime: json['in_time'] ?? 'N/A',
      outTime: json['out_time'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
    );
  }
}
