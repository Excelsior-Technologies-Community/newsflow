import 'package:get/get.dart';

class SourceIconModel {
  final int id;
  final String name;
  final String iconUrl;
  final bool status;
  final RxBool isFollowed = false.obs;

  SourceIconModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.status,
    bool initiallyFollowed = false,
  }) {
    isFollowed.value = initiallyFollowed;
  }

  factory SourceIconModel.fromJson(Map<String, dynamic> json) {
    return SourceIconModel(
      id: json['id'] ?? json['source_id'] ?? 0,
      name: json['source_name'] ?? json['name'] ?? '',
      iconUrl: json['source_icon'] ?? json['source_logo'] ?? json['icon_url'] ?? json['logo'] ?? '',
      status: json['status'] == 1 || json['status'] == true || json['status'] == '1',
      initiallyFollowed: json['is_followed'] == true || json['is_followed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'status': status ? 1 : 0,
      'is_followed': isFollowed.value,
    };
  }
}
