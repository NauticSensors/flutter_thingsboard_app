import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thingsboard_app/config/themes/tb_text_styles.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';
import 'package:thingsboard_app/core/auth/login/provider/oauth_provider.dart';
import 'package:thingsboard_app/core/auth/login/widgets/footer/login_footer.dart';
import 'package:thingsboard_app/core/auth/login/widgets/full_screen_loader.dart';
import 'package:thingsboard_app/core/auth/login/widgets/header/login_header.dart';
import 'package:thingsboard_app/core/auth/login/widgets/o_auth_buttons.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/ui/visibility_widget.dart';

/// BlueStar signs in through OAuth2 only (NauticSensors ID): there is no
/// email and password form and no QR code login.
class LoginWidget extends HookConsumerWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = useState(false);
    final providers = ref.watch(oauthProvider);
    final clients = providers.valueOrNull?.oAuth2Clients ?? const [];

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              spacing: 16,
              children: [
                const LoginHeader(),
                Text(
                  S.of(context).loginToYourAccount,
                  style: TbTextStyles.titleMedium,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child:
                      clients.isNotEmpty
                          ? _OAuthLogin(
                            clients: clients,
                            onButtonPressed:
                                (client) => onOauth2ButtonPressed(
                                  client,
                                  context,
                                  loading,
                                  ref,
                                ),
                          )
                          : providers.isLoading
                          ? const SizedBox.shrink()
                          : _NoLoginProviders(
                            onRetry: () => ref.invalidate(oauthProvider),
                          ),
                ),
                const Spacer(),
                const LoginFooter(),
              ],
            ),
          ),
        ),
        AnimatedVisibilityWidget(
          show: loading.value || providers.isLoading,
          child: const FullScreenLoader(),
        ),
      ],
    );
  }
}

class _OAuthLogin extends StatelessWidget {
  const _OAuthLogin({required this.clients, required this.onButtonPressed});

  final List<OAuth2ClientInfo> clients;
  final void Function(OAuth2ClientInfo) onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          S.of(context).loginWith.toUpperCase(),
          style: TbTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
            letterSpacing: 0.4,
          ),
        ),
        OAuthButtons(onButtonPressed: onButtonPressed, clients: clients),
      ],
    );
  }
}

/// Shown when the server could not be reached and no login providers are
/// cached yet: without a provider there is nothing to sign in with.
class _NoLoginProviders extends StatelessWidget {
  const _NoLoginProviders({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        Text(
          S.of(context).failedToConnectToServer,
          style: TbTextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),
        OutlinedButton(onPressed: onRetry, child: Text(S.of(context).retry)),
      ],
    );
  }
}

Future<void> onOauth2ButtonPressed(
  OAuth2ClientInfo client,
  BuildContext context,
  ValueNotifier<bool> loading,
  WidgetRef ref,
) async {
  FocusScope.of(context).unfocus();
  loading.value = true;
  final res = await ref.read(loginProvider.notifier).oauthLogin(client.url);
  loading.value = res;
}
