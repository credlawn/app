class TodayAttendanceStatus {
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? lastLogType; // 'In', 'Out', or null

  TodayAttendanceStatus({
    this.hasCheckedIn = false,
    this.hasCheckedOut = false,
    this.lastLogType,
  });
}
