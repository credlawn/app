class AttendanceRecord {
  final String date;
  final String? inTime;
  final String? outTime;
  final String? status;
  final String? holidayName;

  AttendanceRecord({
    required this.date,
    this.inTime,
    this.outTime,
    this.status,
    this.holidayName,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Check if it's a holiday record
    if (json.containsKey('holiday_name')) {
      return AttendanceRecord(
        date: json['date'] ?? 'N/A',
        inTime: null,
        outTime: null,
        status: null,
        holidayName: json['holiday_name'],
      );
    }

    // Regular attendance record
    return AttendanceRecord(
      date: json['date'] ?? 'N/A',
      inTime: json['inTime'],
      outTime: json['outTime'],
      status: null, // Status calculated on frontend
      holidayName: null,
    );
  }
}
