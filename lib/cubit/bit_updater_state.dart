part of 'bit_updater_cubit.dart';

abstract class BitUpdaterState extends Equatable {
  const BitUpdaterState();
}

class BitUpdaterInitial extends BitUpdaterState {
  final UpdateStatus currentStatus = UpdateStatus.pending;
  @override
  List<Object> get props => [currentStatus];
}

/// Whenever a new event is triggered
class UpdateStatusState extends BitUpdaterState {
  final UpdateStatus currentStatus;

  const UpdateStatusState(this.currentStatus);

  @override
  List<Object?> get props => [currentStatus];
}
/// Whenever the user checks the checkbox, it disallows the non-forced updates so no update is shows until a forced one.
/// This value is saved in the sharedPrefs.
/// When BitUpdater is run, it checks the saved value and dismisses the update if there is no forced update.

class UpdateDialogParameterState extends BitUpdaterState {
  final bool isUpdateAvailable;
  final bool allowSkip;
  final bool isNonForcedUpdateAllowed;
  final bool isCheckBoxAvailable;

  const UpdateDialogParameterState(this.isUpdateAvailable, this.allowSkip, this.isNonForcedUpdateAllowed, this.isCheckBoxAvailable);

  @override
  List<Object?> get props => [isUpdateAvailable, allowSkip, isNonForcedUpdateAllowed];
}

class LoadingState extends BitUpdaterState {
  @override
  List<Object?> get props => [];
}

/// Updates the progress of the download
class DownloadProgressState extends BitUpdaterState {
  final int current;
  final int total;

  const DownloadProgressState(this.current, this.total);

  @override
  List<Object?> get props => [current, total];
}
/// When there is an error
class OnErrorState extends BitUpdaterState {
  final Object error;

  const OnErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
