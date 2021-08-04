enum UPDATE_TYPE { IMMEDIATE, FLEXIBLE, NONE }

class UpdateInfo {
  late bool updateAvailable;

  late final int latestVersion;
  late final int priorityCode;

  UpdateInfo({
    required this.updateAvailable,
    required this.latestVersion,
    required this.priorityCode,
  });

  UpdateInfo.fromJson(Map<String, dynamic> json) {
    updateAvailable = json['update'] ?? false;
    latestVersion = json['latest_version'] ?? 0;
    priorityCode = json['priority'] ?? 0;
  }

  /// getUpdateType tries to make sense of the required update type internally
  /// An update with priority of zero will be ignored, priority five (maximum)
  /// will be regarded as a forced-update, and any other value will be a
  /// flexible update
  UPDATE_TYPE getUpdateType() {
    if (!updateAvailable)
      // No update required
      return UPDATE_TYPE.NONE;

    if (priorityCode == 0)
      return UPDATE_TYPE.NONE;
    else if (priorityCode <= 4)
      return UPDATE_TYPE.FLEXIBLE;
    else
      return UPDATE_TYPE.IMMEDIATE;
  }
}
