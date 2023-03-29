import 'dart:convert';
import 'dart:io';

import 'package:bit_updater/const/enums.dart';
import 'package:bit_updater/cubit/bit_updater_cubit.dart';
import 'package:bit_updater/models/device_version_model.dart';
import 'package:bit_updater/models/server_version_model.dart';
import 'package:bit_updater/models/update_model.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class BitUpdaterService {
  final bool launchUrlInsteadOfDownloading;
  BitUpdaterService({this.launchUrlInsteadOfDownloading = true});

  ServerVersionModel serverVersion = ServerVersionModel(
      minVersion: "", updateUrl: "", platform: "", latestVersion: "");
  DeviceVersionModel deviceVersion =
      DeviceVersionModel(version: "", buildNumber: "");
  var token = CancelToken();

  /// Get the apps versioning info from server and create a ServerVersionModel object.
  Future<void> getServerVersionInfo(String url) async {
    String _endpoint = Platform.isAndroid ? "android" : "ios";
    String _versionUrl = url + _endpoint;
    print("Getting the version info from $_versionUrl");
    var response = await http.get(Uri.parse(_versionUrl), headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    });

    if (response.statusCode != 200) {
      print("Error getting version info");
      print("Status code: ${response.statusCode}");
      print("Response body:");
      print(response.body.toString());
    } else {
      print("Version info acquired:");
      print(response.body);
    }

    /// Make sure that the server versioning includes major minor and patch versioning as 3.0.0

    serverVersion = ServerVersionModel.fromJson(jsonDecode(response.body));
    // RegExp versioningPattern = RegExp(r"\d\.\d\.\d");
    // if (versioningPattern.hasMatch(serverVersion.minVersion) &&
    //     versioningPattern.hasMatch(serverVersion.latestVersion)) {
    //   throw FlutterError("Wrong versioning info from server. \n"
    //       "Versioning does not match. Make sure versioning is formatted with MAJOR, MINOR and PATCH. Exp: 3.0.0");
    // }
  }

  /// Get device info from packageInfo package and create a DeviceVersionModel object.
  Future<void> getDeviceVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    bool hasBuildFlavorInVersioning = packageInfo.version.contains(" ");
    String buildNumber = packageInfo.buildNumber;
    String version = hasBuildFlavorInVersioning
        ? packageInfo.version.split(" ")[0]
        : packageInfo.version;

    deviceVersion =
        DeviceVersionModel(version: version, buildNumber: buildNumber);
    print("Device version: " +
        deviceVersion.version +
        " Build number: " +
        deviceVersion.buildNumber);
  }

  bool checkUrlFormat(String url) {
    if (url.startsWith('http') && url.endsWith("/")) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> downloadApp() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String downloadUrl = serverVersion.updateUrl;

    try {
      bitUpdaterGetIt<BitUpdaterCubit>()
          .changeUpdateStatus(UpdateStatus.downloading);
      await Dio().download(
        downloadUrl,
        "$tempPath/app.apk",
        cancelToken: token,
        options: Options(
          receiveDataWhenStatusError: false,
        ),
        onReceiveProgress: (progress, totalProgress) {
          bitUpdaterGetIt<BitUpdaterCubit>()
              .updateDownloadProgress(progress, totalProgress);
          if (progress == totalProgress) {
            OpenFilex.open('$tempPath/app.apk');
          }
        },
        deleteOnError: true,
      ).whenComplete(() => bitUpdaterGetIt<BitUpdaterCubit>()
          .changeUpdateStatus(UpdateStatus.completed));
    } catch (error) {
      if (error is DioError) {
        bitUpdaterGetIt<BitUpdaterCubit>()
            .changeUpdateStatus(UpdateStatus.cancelled);
      } else {
        bitUpdaterGetIt<BitUpdaterCubit>()
            .changeUpdateStatus(UpdateStatus.failed);
      }

      debugPrint(error.toString());
    }
  }

  Future<bool> checkServerUpdate(String url, BuildContext context) async {
    if (!checkUrlFormat(url)) {
      bitUpdaterGetIt<BitUpdaterCubit>()
          .changeUpdateStatus(UpdateStatus.urlNotValid);
      debugPrint(
          "The given URL is not valid. Please make sure you follow the correct URL scheme and your URL starts with 'http' and ends with '/'");
      return false;
    }
    bitUpdaterGetIt<BitUpdaterCubit>()
        .changeUpdateStatus(UpdateStatus.checking);
    bitUpdaterGetIt<BitUpdaterCubit>().getDismissedVersionFromShared();

    int dismissedVersion = bitUpdaterGetIt<BitUpdaterCubit>().dismissedVersion;
    bool _isUpdateAvailable = false;

    await getServerVersionInfo(url);

    await getDeviceVersionInfo();

    try {
      int minSupportVersion =
          int.parse(serverVersion.minVersion.replaceAll(".", ""));
      int latestVersion =
          int.parse(serverVersion.latestVersion.replaceAll(".", ""));
      int deviceBuildVersion =
          int.parse(deviceVersion.version.replaceAll(".", ""));

      if (minSupportVersion > deviceBuildVersion ||
          (deviceBuildVersion < latestVersion &&
              dismissedVersion != latestVersion)) {
        _isUpdateAvailable = true;
      }

      UpdateModel updateModel = UpdateModel(
        isUpdateAvailable: _isUpdateAvailable,
        isUpdateForced: minSupportVersion > deviceBuildVersion,
        platform: serverVersion.platform,
        minSupportVersion: serverVersion.minVersion,
        latestVersion: serverVersion.latestVersion,
        deviceVersion: deviceVersion.version,
        downloadUrl: serverVersion.updateUrl,
      );

      bitUpdaterGetIt<BitUpdaterCubit>().setUpdateModel(updateModel);

      bitUpdaterGetIt<BitUpdaterCubit>().changeUpdateStatus(
          (dismissedVersion == latestVersion && !updateModel.isUpdateForced!)
              ? UpdateStatus.availableButDismissed
              : UpdateStatus.available);

      return updateModel.isUpdateForced! ? true : _isUpdateAvailable;
    } catch (error) {
      bitUpdaterGetIt<BitUpdaterCubit>().setError(FlutterError(
          "Wrong versioning info from server. \n"
          "Versioning does not match. Make sure versioning is formatted with MAJOR, MINOR and PATCH. Example: 3.0.0"));
      return false;
    }
  }
}
