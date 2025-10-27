class FollowUp {
  final String customerName;
  final String mobileNo;
  final String followUpDate;
  final String followUpTime;
  final String status;

  FollowUp({
    required this.customerName,
    required this.mobileNo,
    required this.followUpDate,
    required this.followUpTime,
    required this.status,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      customerName: json['customer_name'],
      mobileNo: json['mobile_no'],
      followUpDate: json['follow_up_date'],
      followUpTime: json['follow_up_time'],
      status: json['status'],
    );
  }
}
