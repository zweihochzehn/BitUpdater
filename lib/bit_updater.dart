library bit_updater;

import 'package:bit_updater/services/bit_updater_service.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:bit_updater/services/shared_preferences_service.dart';
import 'package:bit_updater/widgets/bit_updater_dialog.dart';
import 'package:flutter/material.dart';

import 'const/enums.dart';
import 'cubit/bit_updater_cubit.dart';

Future<void> BitUpdaterInit() async {
  setUpLocatorService();
  WidgetsFlutterBinding.ensureInitialized();
  await bitUpdaterGetIt<SharedPreferencesService>().initSharedPreferences();
}

class BitUpdater {
  final BuildContext context;
  final String url;
  final String? confirmText;
  final String? cancelText;
  final String? titleText;
  String? contentText;
  String? forceUpdateContentText;
  String? checkBoxText;
  ShapeBorder? dialogShape;
  AlignmentGeometry? dialogAlignment;
  Color? dialogBackgroundColor;
  Color? dialogTextColor;
  double? dialogElevation;
  Clip? dialogClipBehavior;
  Curve? dialogInsetAnimationCurve;
  Duration? dialogInsetAnimationDuration;
  EdgeInsets? dialogInsetPadding;

  BitUpdater({
    required this.context,
    required this.url,
    this.confirmText = "Upgrade",
    this.cancelText = "Skip",
    this.titleText = "Update Available!",
    this.contentText =
        "Please update to take advantage of the latest features and bug fixes!",
    this.forceUpdateContentText =
        "This is a major update. If you want to continue using the app, please update!",
    this.checkBoxText = "dismiss until next available version",
    this.dialogShape,
    this.dialogAlignment,
    this.dialogBackgroundColor,
    this.dialogTextColor,
    this.dialogElevation,
    this.dialogClipBehavior,
    this.dialogInsetAnimationCurve,
    this.dialogInsetAnimationDuration,
    this.dialogInsetPadding,
  });

  Future<bool> checkServerForUpdate() async {
    bool isUpdateAvailable = await bitUpdaterGetIt<BitUpdaterService>()
        .checkServerUpdate(url, context);
    bool allowSkip = bitUpdaterGetIt<BitUpdaterCubit>().allowSkip;

    if (isUpdateAvailable) {
      bool _dismissOnTouchOutside = true;
      Future<bool> _onWillPop() async =>
          allowSkip ? _dismissOnTouchOutside : allowSkip;

      Widget _buildDialogUI() {
        return BitUpdaterDialog(
          context: context,
          titleText: titleText!,
          contentText: allowSkip ? contentText! : forceUpdateContentText!,
          confirmButtonText: confirmText!,
          cancelButtonText: cancelText!,
          downloadUrl: url,
          checkBoxText: checkBoxText!,
          dialogAlignment: dialogAlignment,
          dialogBackgroundColor: dialogBackgroundColor,
          dialogTextColor: dialogTextColor,
          dialogShape: dialogShape,
          dialogElevation: dialogElevation,
          dialogClipBehavior: dialogClipBehavior,
          dialogInsetAnimationCurve: dialogInsetAnimationCurve,
          dialogInsetAnimationDuration: dialogInsetAnimationDuration,
          dialogInsetPadding: dialogInsetPadding,
        );
      }

      showDialog(
          context: context,
          barrierDismissible: allowSkip,
          builder: (_) {
            return WillPopScope(onWillPop: _onWillPop, child: _buildDialogUI());
          }).then((value) {
        if (value == null) {
          bitUpdaterGetIt<BitUpdaterCubit>()
              .changeUpdateStatus(UpdateStatus.dialogDismissed);
        }
      });

      return true;
    } else {
      return false;
    }
  }
}
