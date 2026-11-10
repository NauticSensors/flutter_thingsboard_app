import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/utils/utils.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            ThingsboardImage.thingsBoardWithTitle,
            height: 44,
            colorFilter: Utils.toColorFilter(theme.primaryColor),
            semanticsLabel: S.of(context).logoDefaultValue,
          ),
        ],
      ),
    );
  }
}
