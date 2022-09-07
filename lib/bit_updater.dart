library bit_updater;

import 'package:bit_updater/models/update_model.dart';
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

  Future<bool> checkServerForUpdateAndShowDialog() async {
    bool isUpdateAvailable = await bitUpdaterGetIt<BitUpdaterService>()
        .checkServerUpdate(url, context);
    bool? isUpdateForced = bitUpdaterGetIt<BitUpdaterCubit>().updateModel.isUpdateForced;
    FlutterError? error = bitUpdaterGetIt<BitUpdaterCubit>().error;

    if (isUpdateAvailable && error == null) {
      Future<bool> _onWillPop() async =>
          !isUpdateForced!;

      Widget _buildDialogUI() {
        return BitUpdaterDialog(
          context: context,
          titleText: titleText!,
          contentText: isUpdateForced! ? forceUpdateContentText! : contentText!,
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
          barrierDismissible: !isUpdateForced!,
          builder: (_) {
            return WillPopScope(
              onWillPop: _onWillPop,
              child: _buildDialogUI(),
            );
          }).then((value) {
        if (value == null) {
          bitUpdaterGetIt<BitUpdaterCubit>()
              .changeUpdateStatus(UpdateStatus.dialogDismissed);
        }
      });

      return true;
    } else {
      if (error != null) {
        showDialog(context: context, barrierDismissible: true, builder: (_) {
          return _buildErrorDialog(error.message);
        }).then((value) {
          if (value == null) {
            bitUpdaterGetIt<BitUpdaterCubit>().disposeBitUpdater();
            bitUpdaterGetIt<BitUpdaterCubit>()
                .changeUpdateStatus(UpdateStatus.dialogDismissed);
          }
        });
      }
      return false;
    }
  }

  Widget _buildErrorDialog(String errorMessage) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<UpdateModel> checkServerForUpdate() async {
    bool isUpdateAvailable = await bitUpdaterGetIt<BitUpdaterService>()
        .checkServerUpdate(url, context);
    return bitUpdaterGetIt<BitUpdaterCubit>().updateModel;
  }
}
