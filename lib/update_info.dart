enum UPDATE_TYPE { IMMEDIATE, FLEXIBLE, NONE }

class UpdateInfo {
  late bool updateAvailable;

  late final int? latestVersion;
  late int? _priorityCode;

  UpdateInfo({
    required this.updateAvailable,
    required this.latestVersion,
    required priorityCode,
  }) {
    this._priorityCode = priorityCode;
  }

  UpdateInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty || !json.containsKey('update')) {
      // The update variable should always be present, direct return if not
      this.updateAvailable = false;
      return;
    }

    updateAvailable = json['update'];
    latestVersion = json['latest_version'];
    _priorityCode = json['priority'];

    // Priority code should have the range [0, 5] (inclusive of extremities)
    _priorityCode = (_priorityCode ?? 0) % 6;
  }

  /// getUpdateType tries to make sense of the required update type internally
  UPDATE_TYPE getUpdateType() {
    if (!updateAvailable)
      // No update required
      return UPDATE_TYPE.NONE;

    _priorityCode = _priorityCode ?? 0; // can assume the code won't be null
    if (_priorityCode! == 0)
      return UPDATE_TYPE.NONE;
    else if (_priorityCode! <= 4)
      return UPDATE_TYPE.FLEXIBLE;
    else
      return UPDATE_TYPE.IMMEDIATE;
  }
}
