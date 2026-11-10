import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/referral/repository/referral_repository.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

/// The referral page: the customer's referral code with ways to share it, the
/// credit earned so far and how the programme works.
///
/// The mobile center of the server adds this page to the navigation as a
/// custom page with the path `/referral`.
class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _repository = ReferralRepository(getIt());

  ReferralInfo _referral = const ReferralInfo();
  bool _isLoading = true;
  bool _showCopiedText = false;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    if (!_isLoading) setState(() => _isLoading = true);
    try {
      _referral = await _repository.fetch();
    } catch (e) {
      debugPrint('Error loading referral data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String _getShareText(BuildContext context) =>
      S.of(context).referralShareText(_referral.code ?? '', _referral.url);

  Future<void> _copyCode() async {
    final code = _referral.code;
    if (code != null) {
      await Clipboard.setData(ClipboardData(text: code));
      if (!mounted) return;
      setState(() => _showCopiedText = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showCopiedText = false);
    }
  }

  Future<void> _shareCode(BuildContext context) async {
    if (_referral.code != null) {
      await Share.share(
        _getShareText(context),
        subject: S.of(context).referralShareSubject,
      );
    }
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    if (_referral.code != null) {
      final url = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(_getShareText(context))}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: TbAppBar(title: Text(S.of(context).referral)),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadReferralData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCodeCard(context),
                  const SizedBox(height: 16),
                  _buildStatsCard(context),
                  const SizedBox(height: 16),
                  _buildExplanationCard(context),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SizedBox.expand(
              child: ColoredBox(
                color: Color(0x99FFFFFF),
                child: Center(child: TbProgressIndicator(size: 50.0)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context) {
    final code = _referral.code;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              S.of(context).referralCode,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code ?? S.of(context).referralLoading,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label:
                      _showCopiedText
                          ? S.of(context).referralCopied
                          : S.of(context).referralCopy,
                  color: Colors.blue,
                  onPressed: _copyCode,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: S.of(context).referralShare,
                  color: Colors.indigo,
                  onPressed: () => _shareCode(context),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onPressed: () => _shareWhatsApp(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            if (code != null) ...[
              QrImageView(
                data: _referral.url,
                size: 140,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).referralScanQr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final creditFormatted = _referral.credit
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              value: '€$creditFormatted',
              label: S.of(context).referralCredit,
            ),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _StatItem(
              value: _referral.count.toString(),
              label: S.of(context).referralReferrals,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).referralHowItWorks,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _ExplanationItem(S.of(context).referralStep1),
            _ExplanationItem(S.of(context).referralStep2),
            _ExplanationItem(S.of(context).referralStep3),
            _ExplanationItem(S.of(context).referralStep4),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class _ExplanationItem extends StatelessWidget {
  const _ExplanationItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
