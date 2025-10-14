import 'dart:convert';

class CustomerDetailsModel {
  final String fullName;
  final String segId;
  final String city;
  final String productDesc;
  final String checkdefectDesc;
  final String employer;

  CustomerDetailsModel({
    required this.fullName,
    required this.segId,
    required this.city,
    required this.productDesc,
    required this.checkdefectDesc,
    required this.employer,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      fullName: json['full_name'] ?? '',
      segId: json['seg_id'] ?? '',
      city: json['city'] ?? '',
      productDesc: json['product_desc'] ?? '',
      checkdefectDesc: json['checkdefect_desc'] ?? '',
      employer: json['employer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'seg_id': segId,
      'city': city,
      'product_desc': productDesc,
      'checkdefect_desc': checkdefectDesc,
      'employer': employer,
    };
  }
}