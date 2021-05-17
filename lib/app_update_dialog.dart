import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';

class AppUpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final String updateButtonText;
  final String? laterButtonText;
  final VoidCallback onUpdate;
  final VoidCallback onLater;
  final Widget headerWidget;
  final EsamudaayThemeData customThemeData;
  AppUpdateDialog({
    required this.title,
    required this.message,
    required this.updateButtonText,
    this.laterButtonText,
    required this.onLater,
    required this.onUpdate,
    required this.headerWidget,
    required this.customThemeData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            color: customThemeData.colors.backgroundColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              headerWidget,
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 46),
                child: Text(
                  title,
                  style: customThemeData.textStyles.topTileTitle
                      .copyWith(fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  message,
                  style: customThemeData.textStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25),
              Row(
                children: [
                  if (laterButtonText != null) ...{
                    Expanded(
                      child: _CustomIconButton(
                        icon: Icons.clear,
                        text: laterButtonText ?? "",
                        onTap: onLater,
                        customThemeData: customThemeData,
                      ),
                    ),
                  },
                  Expanded(
                    child: _CustomIconButton(
                      icon: Icons.check,
                      text: updateButtonText,
                      onTap: onUpdate,
                      color: customThemeData.colors.positiveColor,
                      customThemeData: customThemeData,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function() onTap;
  final Color? color;
  final EsamudaayThemeData customThemeData;
  const _CustomIconButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.customThemeData,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Icon(
                      icon,
                      color: color ?? customThemeData.colors.textColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        text,
                        style: customThemeData.textStyles.sectionHeading2
                            .copyWith(
                                color:
                                    color ?? customThemeData.colors.textColor),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
