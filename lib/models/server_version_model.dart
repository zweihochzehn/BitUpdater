import 'package:bit_updater/cubit/bit_updater_cubit.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:flutter/material.dart';

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
      minVersion: json["minVersion"] as String,
      latestVersion: json["latestVersion"] as String,
      updateUrl: json["updateUrl"] as String,
      platform: json["platform"] as String,
    );
    return serverVersionModel;
  }
}
