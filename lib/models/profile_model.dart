import 'dart:convert';
import 'package:flutter/material.dart'; 
import 'package:intl/intl.dart';

class ProfileModel {
  final String employeeName;
  final String employeeCode;
  final String joiningDate;
  final String dateOfBirth;
  final String gender;
  final String department;
  final String designation;
  final String mobileNo;
  final String email;
  final String age;
  final String tenure;

  ProfileModel({
    required this.employeeName,
    required this.employeeCode,
    required this.joiningDate,
    required this.dateOfBirth,
    required this.gender,
    required this.department,
    required this.designation,
    required this.mobileNo,
    required this.email,
    required this.age,
    required this.tenure,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      employeeName: json['employee_name'] ?? '',
      employeeCode: json['employee_code'].toString() ?? '',
      joiningDate: _formatDate(json['joining_date'] ?? ''),
      dateOfBirth: _formatDate(json['date_of_birth'] ?? ''),
      gender: json['gender'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? '',
      tenure: json['tenure'] ?? '',
    );
  }

  static String _formatDate(String date) {
    if (date.isEmpty) {
      return '';
    }
    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'joining_date': joiningDate,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'department': department,
      'designation': designation,
      'mobile_no': mobileNo,
      'email': email,
      'age': age,
      'tenure': tenure,
    };
  }
}

