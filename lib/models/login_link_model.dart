
class LoginLinkModel {
  final String linkType;
  final String link;

  LoginLinkModel({
    required this.linkType,
    required this.link,
  });

  factory LoginLinkModel.fromJson(Map<String, dynamic> json) {
    return LoginLinkModel(
      linkType: json['link_type'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'link_type': linkType,
      'link': link,
    };
  }
}