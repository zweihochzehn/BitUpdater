enum UpdateStatus {
  ///when checking for an update
  checking,

  ///when an update is available
  available,

  ///when an update is available but dismissed by user until a force update
  availableButDismissed,

  ///when update dialog dismissed
  dialogDismissed,

  ///when an update is preparing to download
  pending,

  ///when an update starts downloading
  downloading,

  ///when the update is downloaded and ready to install
  completed,

  ///when an update is downloading and canceled
  cancelled,

  ///when there is an error that stopped the update to download
  failed,
}