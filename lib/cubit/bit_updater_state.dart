part of 'bit_updater_cubit.dart';

abstract class BitUpdaterState extends Equatable {
  const BitUpdaterState();
}

class BitUpdaterInitial extends BitUpdaterState {
  final UpdateStatus currentStatus = UpdateStatus.pending;
  @override
  List<Object> get props => [currentStatus];
}

class UpdateStatusState extends BitUpdaterState {
  final UpdateStatus currentStatus;

  const UpdateStatusState(this.currentStatus);

  @override
  List<Object?> get props => [currentStatus];
}

class UpdateDialogParameterState extends BitUpdaterState {
  final bool isUpdateAvailable;
  final bool allowSkip;
  final int dismissedVersion;
  final bool isCheckBoxAvailable;

  const UpdateDialogParameterState(this.isUpdateAvailable, this.allowSkip, this.dismissedVersion, this.isCheckBoxAvailable);

  @override
  List<Object?> get props => [isUpdateAvailable, allowSkip, dismissedVersion, isCheckBoxAvailable];
}

class LoadingState extends BitUpdaterState {
  @override
  List<Object?> get props => [];
}

class DownloadProgressState extends BitUpdaterState {
  final int current;
  final int total;

  const DownloadProgressState(this.current, this.total);

  @override
  List<Object?> get props => [current, total];
}

class OnErrorState extends BitUpdaterState {
  final Object error;

  const OnErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
