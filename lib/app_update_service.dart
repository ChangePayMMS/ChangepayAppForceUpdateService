import 'dart:io';
import 'package:esamudaay_app_update/app_update_dialog.dart';
import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

enum _UPDATE_TYPE { IMMEDIATE, FLEXIBLE, NONE }

/// Generic methods to handle app update availavility.
class AppUpdateService {
  // Defining this class as singleton to manage state variables.
  AppUpdateService._();
  static AppUpdateService _instance = AppUpdateService._();
  factory AppUpdateService() => _instance;

  static bool _isUpdateAvailable;
  static _UPDATE_TYPE _updateType;
  static bool _isSelectedLater;

  static bool get isSelectedLater => _isSelectedLater;

  static Future<void> checkAppUpdateAvailability({
    bool isTesting = false,
  }) async {
    try {
      // for testing pupose.
      if (isTesting) {
        _isUpdateAvailable = true;
        _updateType = _UPDATE_TYPE.FLEXIBLE;
        _isSelectedLater = false;
        return;
      }

      // TODO : IOS platform implementation.
      if (Platform.isIOS) {
        throw Exception("ios implementation not found");
      }

      // InAppUpdate works for Android platform only.
      final AppUpdateInfo appUpdateInfo = await InAppUpdate.checkForUpdate();

      debugPrint("appUpdateInfo => $appUpdateInfo");

      /// Possible values for updateAvailability are
      /// unknown , updateNotAvailable , updateAvailable , developerTriggeredUpdateInProgress.
      _isUpdateAvailable = appUpdateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable;

      _updateType = (appUpdateInfo?.flexibleUpdateAllowed ?? false)
          ? _UPDATE_TYPE.FLEXIBLE
          : (appUpdateInfo?.immediateUpdateAllowed ?? false)
              ? _UPDATE_TYPE.IMMEDIATE
              : _UPDATE_TYPE.NONE;

      _isSelectedLater = false;
    } catch (e) {
      _isUpdateAvailable = false;
      _updateType = _UPDATE_TYPE.NONE;
      _isSelectedLater = false;
    }
  }

  static Future<void> showUpdateDialog({
    @required BuildContext context,
    @required String title,
    @required String message,
    @required String laterButtonText,
    @required String updateButtonText,
    @required Widget logoImage,
    @required EsamudaayThemeData customThemeData,
    @required String packageName,
  }) async {
    // show app update dialog only if update is available and update priority is atleast flexible.
    if (_isUpdateAvailable && (_updateType != _UPDATE_TYPE.NONE)) {
      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => Future.value(false),
            child: AppUpdateDialog(
              customThemeData: customThemeData,
              title: title,
              message: message,
              updateButtonText: updateButtonText,
              laterButtonText: _updateType == _UPDATE_TYPE.IMMEDIATE
                  ? null
                  : laterButtonText,
              onLater: () {
                _isSelectedLater = true;
                Navigator.of(context).pop();
              },
              onUpdate: () => updateApp(packageName),
              headerWidget: logoImage,
            ),
          );
        },
      );
    }
  }

  static Future<void> updateApp(String packageName) async {
    // TODO : IOS platform implementation.

    String PLAY_STORE_URL =
        'https://play.google.com/store/apps/details?id=$packageName';
    if (await canLaunch(PLAY_STORE_URL)) {
      await launch(PLAY_STORE_URL);
    } else {
      throw 'Could not launch $PLAY_STORE_URL';
    }
  }
}
