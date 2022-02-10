import 'dart:io';
import 'package:dio/dio.dart';
import 'package:esamudaay_app_update/app_update_dialog.dart';
import 'package:esamudaay_app_update/update_info.dart';
import 'package:esamudaay_app_update/string_constants.dart';
import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

enum APP_TYPE { CONSUMER, DELIVERY, SELLER }

extension ParseToString on APP_TYPE {
  /// Converts enum value to a string value that is expected by the API
  String stringify() {
    // Convert object to string, will traslate to `_API_FIELDS.<type>` - split
    // at period, get last element of array
    String result = this.toString().split('.').last;

    if (Platform.isIOS)
      // For iOS consumer app, return result as "CONSUMER_IOS"
      return result + "_IOS";

    return result;
  }
}

/// Fetches app update information from the backend
class _GetUpdateInfo {
  static Future<UpdateInfo> fetch({
    required APP_TYPE appType,
    bool isTesting = false,
    String? tpid,
  }) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Dio dio = new Dio(new BaseOptions(
      baseUrl: (isTesting ? testURL : liveURL),
      connectTimeout: 50000,
      receiveTimeout: 100000,
      followRedirects: false,
      validateStatus: (status) {
        if (status != null) return status < 500;
        return false;
      },
      responseType: ResponseType.json,
    ));

    dio.interceptors.add(LogInterceptor(
        responseBody: true,
        request: true,
        requestBody: true,
        requestHeader: true));

    // Initialize to no update
    UpdateInfo result = UpdateInfo(
      updateAvailable: false,
      latestVersion: 0,
      priorityCode: 0,
    );
    Map<String, dynamic> queryParameters = {
      'app_type': appType.stringify(),
      'app_version': int.parse(packageInfo.buildNumber),
    };
    if (tpid != null) {
      queryParameters['tpid'] = tpid;
    }
    try {
      await dio.get(apiURL, queryParameters: queryParameters).then((response) =>
          {
            if (response.statusCode != 200)
              throw Exception("Response code ${response.statusCode} obtained")
            else
              result = UpdateInfo.fromJson(response.data)
          });
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }
}

/// Generic methods to handle app update availavility.
class AppUpdateService {
  // Defining this class as singleton to manage state variables.
  AppUpdateService._();
  static AppUpdateService _instance = AppUpdateService._();
  factory AppUpdateService() => _instance;

  static late bool _isSelectedLater = false;
  static late final UpdateInfo _updateInfo;

  static bool get isSelectedLater => _isSelectedLater;

  static Future<void> checkAppUpdateAvailability({
    required APP_TYPE appType,
    bool isTesting = false,
    String? tpid,
  }) async {
    if (Platform.isIOS && appType != APP_TYPE.CONSUMER) {
      // For iOS platforms, only consumer apps will go beyond this point. Works
      // as a failsafe to prevent crashes if the other apps are deployed to iOS
      // without changes in this package
      debugPrint('attempt to check updates for iOS without porting the ' +
          'app update package - ignore the attempt');
      return;
    }

    _updateInfo = await _GetUpdateInfo.fetch(
      appType: appType,
      isTesting: isTesting,
      tpid: tpid,
    );

    if (!_updateInfo.updateAvailable)
      // Other fields may be null if the `update` boolean is false - return
      return null;
  }

  static Future<void> showUpdateDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String laterButtonText,
    required String updateButtonText,
    required Widget logoImage,
    required EsamudaayThemeData customThemeData,
    required String androidPackageName,
    String appleStoreID = '',
    bool selectedLater = false,
  }) async {
    if (!_updateInfo.updateAvailable ||
        _updateInfo.getUpdateType() == UPDATE_TYPE.NONE)
      // Exit if no update is available, or update type is `NONE`
      return;

    if (_updateInfo.getUpdateType() == UPDATE_TYPE.FLEXIBLE && selectedLater)
      // Return if the user has previously tapped on update later
      return;

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
            laterButtonText: laterButtonText,
            onUpdate: () => updateApp(androidPackageName, appleStoreID),
            headerWidget: logoImage,
            isForcedUpdate:
                _updateInfo.getUpdateType() == UPDATE_TYPE.IMMEDIATE,
            onLater: () {
              _isSelectedLater = true;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  static Future<void> updateApp(
    String androidId,
    String appleAppId,
  ) async {
    await StoreRedirect.redirect(androidAppId: androidId, iOSAppId: appleAppId);
  }
}
