class UpdateModel {
  bool isUpdateAvailable;
  String? latestVersion;
  String? minSupportVersion;
  String? deviceVersion;
  bool? isUpdateForced;
  String? platform;
  String? downloadUrl;

  UpdateModel({
    required this.isUpdateAvailable,
    this.latestVersion,
    this.minSupportVersion,
    this.deviceVersion,
    this.isUpdateForced,
    this.platform,
    this.downloadUrl,
  });
}
