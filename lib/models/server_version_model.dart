import 'package:bit_updater/cubit/bit_updater_cubit.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:flutter/material.dart';

import '../utils/global.dart';

class ServerVersionModel {
  ServerVersionModel({
    required this.minVersion,
    required this.latestVersion,
    required this.updateUrl,
    required this.platform,
  });

  String minVersion;
  String latestVersion;
  String updateUrl;
  String platform;

  factory ServerVersionModel.fromJson(Map<String, dynamic> json) {
    ServerVersionModel serverVersionModel = ServerVersionModel(
      minVersion: tryCast(json["minVersion"]),
      latestVersion: tryCast(json["latestVersion"]),
      updateUrl: tryCast(json["updateUrl"]),
      platform: tryCast(json["platform"]),
    );
    return serverVersionModel;
  }
}
