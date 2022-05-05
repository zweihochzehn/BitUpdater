import 'package:bit_updater/models/update_model.dart';
import 'package:bit_updater/services/locator_service.dart';
import 'package:bit_updater/services/shared_preferences_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../const/enums.dart';

part 'bit_updater_state.dart';

class BitUpdaterCubit extends Cubit<BitUpdaterState> {
  BitUpdaterCubit() : super(BitUpdaterInitial());

  UpdateStatus updateStatus = UpdateStatus.pending;
  bool isUpdateAvailable = false;
  int dismissedVersion = 0;
  int latestVersion = 0;
  bool allowSkip = false;
  bool isCheckBoxAvailable = false;
  String downloadUrl = "";
  UpdateModel updateModel = UpdateModel(isUpdateAvailable: false);

  void disposeBitUpdater() {
    isUpdateAvailable = false;
    allowSkip = false;
    isCheckBoxAvailable = false;
    dismissedVersion = 0;
  }

  void setDismissedVersion(int dismissedVersion) {
    dismissedVersion = dismissedVersion;
    bitUpdaterGetIt<SharedPreferencesService>().setDismissedVersion(
        dismissedVersion);
  }

  void setUpdateModel(UpdateModel model) {
    updateModel = model;
  }

  void setDownloadUrl(String url) {
    downloadUrl = url;
    debugPrint("App download URL: $url");
  }

  void getDismissedVersionFromShared() {
    dismissedVersion =
        bitUpdaterGetIt<SharedPreferencesService>().getDismissedVersion();
  }
  /// If the checkbox is ticked, we save this value to sharedPrefs.
  void setLatestVersion(int version) {
    latestVersion = version;
  }
  /// After the update check is complete, the values are saves with this and used by the Dialog afterwards.
  void setupUpdateDialogParameters(bool updateAvailability, bool isSkipAllowed,
      bool checkBoxAvailability) {
    emit(LoadingState());
    isUpdateAvailable = updateAvailability;
    allowSkip = isSkipAllowed;
    isCheckBoxAvailable = checkBoxAvailability;

    emit(UpdateDialogParameterState(
        isUpdateAvailable, allowSkip, dismissedVersion, isCheckBoxAvailable));
  }
  /// Follows the update status for debug purposes.
  void changeUpdateStatus(UpdateStatus currentUpdateStatus) {
    emit(LoadingState());
    updateStatus = currentUpdateStatus;
    debugPrint(updateStatus.toString());
    emit(UpdateStatusState(updateStatus));
  }
  /// Updates the download progress indicator.
  void updateDownloadProgress(int current, int total) {
    emit(LoadingState());
    emit(DownloadProgressState(current, total));
  }

  void setError(Object error) {
    emit(LoadingState());
    emit(OnErrorState(error));
  }
}

