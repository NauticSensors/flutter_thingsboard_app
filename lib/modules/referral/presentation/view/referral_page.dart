import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralPage extends TbPageWidget {
  ReferralPage(super.tbContext, {super.key});

  @override
  State<StatefulWidget> createState() => _ReferralPageState();
}

class _ReferralPageState extends TbPageState<ReferralPage> {
  final _isLoadingNotifier = ValueNotifier<bool>(true);

  String? _referralCode;
  double _referralCredit = 0;
  int _referralCount = 0;
  String _copyButtonText = 'Kopieer';

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    _isLoadingNotifier.value = true;
    try {
      final customerId = tbClient.getAuthUser()?.customerId;
      if (customerId != null) {
        final attrs = await tbClient.getAttributeService().getAttributesByScope(
          CustomerId(customerId),
          AttributeScope.SERVER_SCOPE.toShortString(),
          ['referral_code', 'referral_credit', 'referral_count'],
        );

        for (final attr in attrs) {
          switch (attr.getKey()) {
            case 'referral_code':
              _referralCode = attr.getValue()?.toString();
              break;
            case 'referral_credit':
              _referralCredit = (attr.getValue() as num?)?.toDouble() ?? 0;
              break;
            case 'referral_count':
              _referralCount = (attr.getValue() as num?)?.toInt() ?? 0;
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading referral data: $e');
    }
    _isLoadingNotifier.value = false;
    if (mounted) setState(() {});
  }

  String get _referralUrl =>
      'https://nauticsensors.com/?ref=${_referralCode ?? ''}';

  String get _shareText =>
      'Ontvang 5% korting bij NauticSensors met deze code $_referralCode $_referralUrl';

  Future<void> _copyCode() async {
    if (_referralCode != null) {
      await Clipboard.setData(ClipboardData(text: _referralCode!));
      setState(() => _copyButtonText = 'Gekopieerd!');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _copyButtonText = 'Kopieer');
    }
  }

  Future<void> _shareCode() async {
    if (_referralCode != null) {
      await Share.share(_shareText, subject: 'NauticSensors doorverwijscode');
    }
  }

  Future<void> _shareWhatsApp() async {
    if (_referralCode != null) {
      final url = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(_shareText)}',
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
      appBar: TbAppBar(tbContext, title: const Text('Doorverwijzen')),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadReferralData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCodeCard(),
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildExplanationCard(),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isLoadingNotifier,
            builder: (context, loading, _) {
              if (loading) {
                return const SizedBox.expand(
                  child: ColoredBox(
                    color: Color(0x99FFFFFF),
                    child: Center(child: TbProgressIndicator(size: 50.0)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'JOUW DOORVERWIJSCODE',
              style: TextStyle(
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
                _referralCode ?? 'Laden...',
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
                  label: _copyButtonText,
                  color: Colors.blue,
                  onPressed: _copyCode,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Delen',
                  color: Colors.indigo,
                  onPressed: _shareCode,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onPressed: _shareWhatsApp,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            if (_referralCode != null) ...[
              QrImageView(
                data: _referralUrl,
                version: QrVersions.auto,
                size: 140,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan voor de webshop',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final creditFormatted =
        _referralCredit.toStringAsFixed(2).replaceAll('.', ',');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(value: '€$creditFormatted', label: 'Jouw tegoed'),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            _StatItem(
              value: _referralCount.toString(),
              label: 'Doorverwijzingen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoe het werkt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _ExplanationItem('Deel je code met een andere booteigenaar'),
            _ExplanationItem(
              'Bij hun bestelling krijgen zij 5% korting (min. €250)',
            ),
            _ExplanationItem('Jij ontvangt €15 tegoed voor een volgende bestelling'),
            _ExplanationItem('Je kunt tot €150 tegoed opbouwen'),
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
