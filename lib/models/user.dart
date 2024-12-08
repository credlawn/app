import 'dart:convert';

class User {
  final String sid;
  final String fullName;
  final String userId;
  final String? userImage;

  final String? employeeName;
  final String? employeeCode;
  final String? joiningDate;
  final String? dateOfBirth;
  final String? gender;
  final String? department;
  final String? designation;
  final String? mobileNo;
  final String? email;
  final String? age;
  final String? tenure;

  User({
    required this.sid,
    required this.fullName,
    required this.userId,
    this.userImage,
    this.employeeName,
    this.employeeCode,
    this.joiningDate,
    this.dateOfBirth,
    this.gender,
    this.department,
    this.designation,
    this.mobileNo,
    this.email,
    this.age,
    this.tenure,
  });

  User copyWith({
    String? sid,
    String? fullName,
    String? userId,
    String? userImage,
    String? employeeName,
    String? employeeCode,
    String? joiningDate,
    String? dateOfBirth,
    String? gender,
    String? department,
    String? designation,
    String? mobileNo,
    String? email,
    String? age,
    String? tenure,
  }) {
    return User(
      sid: sid ?? this.sid,
      fullName: fullName ?? this.fullName,
      userId: userId ?? this.userId,
      userImage: userImage ?? this.userImage,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      joiningDate: joiningDate ?? this.joiningDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      age: age ?? this.age,
      tenure: tenure ?? this.tenure,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sid': sid,
      'full_name': fullName,
      'user_id': userId,
      'user_image': userImage ?? '',
      'employee_name': employeeName ?? '',
      'employee_code': employeeCode ?? '',
      'joining_date': joiningDate ?? '',
      'date_of_birth': dateOfBirth ?? '',
      'gender': gender ?? '',
      'department': department ?? '',
      'designation': designation ?? '',
      'mobile_no': mobileNo ?? '',
      'email': email ?? '',
      'age': age ?? '',
      'tenure': tenure ?? '',
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      sid: map['sid'] ?? '',
      fullName: map['full_name'] ?? '',
      userId: map['user_id'] ?? '',
      userImage: map['user_image'],
      employeeName: map['employee_name'],
      employeeCode: map['employee_code'],
      joiningDate: map['joining_date'],
      dateOfBirth: map['date_of_birth'],
      gender: map['gender'],
      department: map['department'],
      designation: map['designation'],
      mobileNo: map['mobile_no'],
      email: map['email'],
      age: map['age'],
      tenure: map['tenure'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  String getProfileImage() {
    return userImage ?? 'assets/images/default_profile.png';
  }
}
