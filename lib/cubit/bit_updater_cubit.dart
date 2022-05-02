import 'package:bit_updater/services/locator_service.dart';
import 'package:bit_updater/services/shared_preferences_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../const/enums.dart';

part 'bit_updater_state.dart';

class BitUpdaterCubit extends Cubit<BitUpdaterState> {
  BitUpdaterCubit() : super(BitUpdaterInitial());

  UpdateStatus updateStatus  = UpdateStatus.pending;
  bool isUpdateAvailable = false;
  bool isUserDismissedNonForcedUpdates = false;
  bool allowSkip = false;
  bool isCheckBoxAvailable = false;

  void disposeBitUpdater() {
    isUpdateAvailable = false;
    allowSkip = false;
    isCheckBoxAvailable = false;
    isUserDismissedNonForcedUpdates = false;
  }

  void setNonForcedUpdateStatus(bool isUserDismissed) {
    isUserDismissedNonForcedUpdates = isUserDismissed;
    bitUpdaterGetIt<SharedPreferencesService>().setNonForcedUpdateAllowed(isUserDismissed);
  }

  void setupUpdateDialogParameters(bool updateAvailability, bool isSkipAllowed, bool checkBoxAvailability) {
    emit(LoadingState());
    isUpdateAvailable = updateAvailability;
    allowSkip = isSkipAllowed;
    isCheckBoxAvailable = checkBoxAvailability;
    isUserDismissedNonForcedUpdates = bitUpdaterGetIt<SharedPreferencesService>().getNonForcedUpdateAllowed();

    emit(UpdateDialogParameterState(isUpdateAvailable, allowSkip, isUserDismissedNonForcedUpdates, isCheckBoxAvailable));
  }

  void changeUpdateStatus(UpdateStatus currentUpdateStatus) {
    emit(LoadingState());
    updateStatus = currentUpdateStatus;
    debugPrint(updateStatus.toString());
    emit(UpdateStatusState(updateStatus));
  }

  void updateDownloadProgress(int current, int total) {
    emit(LoadingState());
    emit(DownloadProgressState(current, total));
  }

  void setError(Object error) {
    emit(LoadingState());
    emit(OnErrorState(error));
  }
}

