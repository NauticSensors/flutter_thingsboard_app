import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

/// Where a customer stands in the referral programme.
class ReferralInfo {
  const ReferralInfo({this.code, this.credit = 0, this.count = 0});

  /// The code the customer hands out, or null when the customer has none.
  final String? code;

  /// Credit earned so far, in euros.
  final double credit;

  /// Number of referrals that led to an order.
  final int count;

  /// Link to the webshop that applies the code.
  String get url => 'https://nauticsensors.com/?ref=${code ?? ''}';
}

/// All data access of the referral page: the page itself does not talk to the
/// ThingsBoard client.
///
/// The backend keeps the referral data as server attributes on the customer.
class ReferralRepository {
  const ReferralRepository(this._clientService);

  final ITbClientService _clientService;

  static const _codeKey = 'referral_code';
  static const _creditKey = 'referral_credit';
  static const _countKey = 'referral_count';

  /// Loads the referral data of the customer of the signed-in user. Returns an
  /// empty [ReferralInfo] when the user does not belong to a customer.
  Future<ReferralInfo> fetch() async {
    final client = _clientService.client;
    final customerId = client.getAuthUser()?.customerId;
    if (customerId == null) {
      return const ReferralInfo();
    }

    final attributes = await client.getAttributeService().getAttributesByScope(
      CustomerId(customerId),
      AttributeScope.SERVER_SCOPE.toShortString(),
      [_codeKey, _creditKey, _countKey],
    );
    final values = {
      for (final attribute in attributes)
        attribute.getKey(): attribute.getValue(),
    };

    return ReferralInfo(
      code: values[_codeKey]?.toString(),
      credit: _toNum(values[_creditKey])?.toDouble() ?? 0,
      count: _toNum(values[_countKey])?.toInt() ?? 0,
    );
  }

  static num? _toNum(dynamic value) {
    if (value is num) {
      return value;
    }
    return value == null ? null : num.tryParse(value.toString());
  }
}
