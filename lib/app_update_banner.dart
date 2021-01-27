import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'app_update_service.dart';

class AppUpdateBanner extends StatelessWidget {
  final String updateMessage;
  final String updateButtonText;
  final EsamudaayThemeData customThemeData;
  final String packageName;
  const AppUpdateBanner({
    @required this.updateMessage,
    @required this.updateButtonText,
    @required this.customThemeData,
    @required this.packageName,
    Key key,
  })  : assert(
          updateMessage != null && updateButtonText != null,
          "updateMessage and updateButtonText cannot be null",
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customThemeData.colors.secondaryColor,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            child: Text(
              updateMessage,
              style: customThemeData.textStyles.body1.copyWith(
                color: customThemeData.colors.backgroundColor,
              ),
            ),
          ),
          SizedBox(width: 20),
          InkWell(
            onTap: () => AppUpdateService.updateApp(packageName),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 12),
              decoration: BoxDecoration(
                border:
                    Border.all(color: customThemeData.colors.backgroundColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                updateButtonText,
                style: customThemeData.textStyles.sectionHeading2.copyWith(
                  color: customThemeData.colors.backgroundColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}
