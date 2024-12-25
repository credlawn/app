class AdobeDatabaseModel {
  final String name;
  final String customerName;
  final String creationDate;
  final String decisionDate;
  final String promoCode;
  final String ipaStatus;
  final String kycType;
  final String vkycStatus;
  final String employeeName;
  final String referenceNo;
  final String vkycLink;
  final String vkycExpireDate;
  final String finalDecision;
  final String finalStage;
  final String actionRequired;
  final String mobileNo;

  AdobeDatabaseModel({
    required this.name,
    required this.customerName,
    required this.creationDate,
    required this.decisionDate,
    required this.promoCode,
    required this.ipaStatus,
    required this.kycType,
    required this.vkycStatus,
    required this.employeeName,
    required this.referenceNo,
    required this.vkycLink,
    required this.vkycExpireDate,
    required this.finalDecision,
    required this.finalStage,
    required this.actionRequired,
    required this.mobileNo,
  });

  // Factory method to create an instance from a JSON map
  factory AdobeDatabaseModel.fromJson(Map<String, dynamic> json) {
    return AdobeDatabaseModel(
      name: json['name'] ?? '',
      customerName: json['customer_name'] ?? '',
      creationDate: json['creation_date'] ?? '',
      decisionDate: json['decision_date'] ?? '',
      promoCode: json['promo_code'] ?? '',
      ipaStatus: json['ipa_status'] ?? '',
      kycType: json['kyc_type'] ?? '',
      vkycStatus: json['vkyc_status'] ?? '',
      employeeName: json['employee_name'] ?? '',
      referenceNo: json['reference_no'] ?? '',
      vkycLink: json['vkyc_link'] ?? '',
      vkycExpireDate: json['vkyc_expire_date'] ?? '',
      finalDecision: json['final_decision'] ?? '',
      finalStage: json['final_stage'] ?? '',
      actionRequired: json['action_required'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
    );
  }

  // Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customer_name': customerName,
      'creation_date': creationDate,
      'decision_date': decisionDate,
      'promo_code': promoCode,
      'ipa_status': ipaStatus,
      'kyc_type': kycType,
      'vkyc_status': vkycStatus,
      'employee_name': employeeName,
      'reference_no': referenceNo,
      'vkyc_link': vkycLink,
      'vkyc_expire_date': vkycExpireDate,
      'final_decision': finalDecision,
      'final_stage': finalStage,
      'action_required': actionRequired,
      'mobile_no': mobileNo,
    };
  }
}
