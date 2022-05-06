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
  int dismissedVersion = 0;
  UpdateModel updateModel = UpdateModel(isUpdateAvailable: false);
  FlutterError? error;

  void disposeBitUpdater() {
    updateModel = UpdateModel(isUpdateAvailable: false);
    dismissedVersion = 0;
    error = null;
  }
  /// When the checkbox is ticked, we save the version user dismissed to sharedPrefs.
  void setDismissedVersion(int version) {
    dismissedVersion = version;
    bitUpdaterGetIt<SharedPreferencesService>().setDismissedVersion(
        dismissedVersion);
  }
  /// Gather and save update info from updater service
  void setUpdateModel(UpdateModel model) {
    updateModel = model;
  }
  /// If user dismissed a version by ticking the checkbox, we restore that value here.
  void getDismissedVersionFromShared() {
    dismissedVersion =
        bitUpdaterGetIt<SharedPreferencesService>().getDismissedVersion();
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

  void setError(Object flutterError) {
    emit(LoadingState());
    error = flutterError as FlutterError;
    emit(OnErrorState(flutterError));
  }
}

