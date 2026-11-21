import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/auth/login/widgets/o_auth_button.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/modules/main/providers/navigation_helper.dart';
import 'package:thingsboard_app/thingsboard_client.dart';

/// Name of the NauticSensors OAuth2 client as configured on the server. Its
/// button shows the BlueStar logo instead of the configured icon, and reads
/// "Sign in or create account" instead of the client's name.
const nauticSensorsIdClientName = 'NauticSensors ID';

/// One full-width button per OAuth2 client, with the client's name.
class OAuthButtons extends StatelessWidget {
  const OAuthButtons({
    super.key,
    required this.clients,
    required this.onButtonPressed,
  });
  final void Function(OAuth2ClientInfo) onButtonPressed;
  final List<OAuth2ClientInfo> clients;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          clients
              .map(
                (e) => OAuthButton(
                  logo: _getOauth2ButtonLogo(context, e),
                  title:
                      e.name == nauticSensorsIdClientName
                          ? S.of(context).loginOrCreateAccount
                          : e.name,
                  onTap: () => onButtonPressed(e),
                ),
              )
              .toList(),
    );
  }
}

Widget _getOauth2ButtonLogo(BuildContext context, OAuth2ClientInfo info) {
  if (info.name == nauticSensorsIdClientName) {
    return SvgPicture.asset(ThingsboardImage.thingsboard, height: 32);
  }

  final String? svgPath = ThingsboardImage.oauth2Logos[info.icon];

  if (svgPath != null) {
    return SizedBox(width: 24, height: 24, child: SvgPicture.asset(svgPath));
  }

  final iconData = NavigationHelper.getIconFromString(info.icon);

  return SizedBox(
    width: 24,
    height: 24,
    child: Icon(
      iconData,
      color: Colors.black,
    ),
  );
}
