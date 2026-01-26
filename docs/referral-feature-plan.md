# Referral Feature - Native Flutter Menu Item

## Doel

De referral feature verplaatsen van een ThingsBoard dashboard naar een native Flutter pagina in het menu. Dit geeft een betere gebruikerservaring.

## Huidige Situatie

- ThingsBoard dashboard "Doorverwijzen" is werkend
- Customer attributes: `referral_code`, `referral_credit`, `referral_count`
- BLE Scanner is een voorbeeld van hoe custom pages werken

## Aanpak

Net als de BLE Scanner ("Scan" met path `/ble-scanner`):
1. **Flutter app**: Route handler registreren voor `/referral`
2. **ThingsBoard**: Custom page toevoegen in Mobile Bundle Layout

## Architectuur

```
┌─────────────────────────────────────────────────────────────┐
│ ThingsBoard (Admin UI)                                      │
│ System Admin > Mobile app > Edit bundle > Layout            │
│ + Add specific page:                                        │
│   - Page name: Doorverwijzen                                │
│   - Page type: Custom                                       │
│   - Path: /referral                                         │
│   - Icon: card_giftcard                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ PageLayout via API
┌─────────────────────────────────────────────────────────────┐
│ Flutter App                                                 │
│ Router: /referral → ReferralPage                            │
└─────────────────────────────────────────────────────────────┘
```

## Te Maken/Wijzigen Bestanden

### 1. `lib/modules/referral/presentation/view/referral_page.dart` (NIEUW)

Native Flutter pagina met:
- Kortingscode prominent bovenaan
- Kopieer, Delen, WhatsApp buttons
- QR code
- Tegoed en statistieken
- Uitleg sectie

```dart
class ReferralPage extends TbContextWidget {
  ReferralPage(super.tbContext, {super.key});

  @override
  State<StatefulWidget> createState() => _ReferralPageState();
}

class _ReferralPageState extends TbContextState<ReferralPage> {
  String? referralCode;
  double referralCredit = 0;
  int referralCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    final customerId = tbContext.tbClient.getAuthUser()?.customerId;
    if (customerId != null) {
      final attrs = await tbContext.tbClient.getAttributeService().getEntityAttributes(
        EntityId(EntityType.CUSTOMER, customerId),
        AttributeScope.SERVER_SCOPE.toShortString(),
        ['referral_code', 'referral_credit', 'referral_count'],
      );
      // Parse attributes and setState
    }
  }
  // ... UI build method
}
```

### 2. `lib/modules/referral/referral_routes.dart` (NIEUW)

```dart
import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/tb_routes.dart';
import 'package:thingsboard_app/modules/referral/presentation/view/referral_page.dart';

class ReferralRoutes extends TbRoutes {
  ReferralRoutes(super.tbContext);

  late final referralHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      return ReferralPage(tbContext);
    },
  );

  @override
  void doRegisterRoutes(FluroRouter router) {
    router.define('/referral', handler: referralHandler);
  }
}
```

### 3. `lib/config/routes/router.dart` (WIJZIGEN)

Toevoegen aan `_initRoutes()` (na regel 151):
```dart
ReferralRoutes(_tbContext).doRegisterRoutes(router);
```

Import toevoegen:
```dart
import 'package:thingsboard_app/modules/referral/referral_routes.dart';
```

### 4. ThingsBoard Configuratie (UI - geen code)

In ThingsBoard Admin:
1. Ga naar: System Admin → Mobile app → Edit bundle → Layout
2. Klik: "+ Add specific page"
3. Configureer:
   - Page name: `Doorverwijzen`
   - Page type: `Custom`
   - Path: `/referral`
   - Icon: kies een geschikt icoon (bijv. gift/card)
4. Zet de pagina op de gewenste positie
5. Save

## ReferralPage UI Design

```
┌─────────────────────────────────────┐
│ ← Doorverwijzen                     │  AppBar
├─────────────────────────────────────┤
│                                     │
│        JOUW KORTINGSCODE            │
│  ┌─────────────────────────────────┐│
│  │         JB8XMSEX                ││
│  └─────────────────────────────────┘│
│                                     │
│  [Kopieer]  [Delen]  [WhatsApp]     │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│           ┌─────────┐               │
│           │ QR CODE │               │
│           └─────────┘               │
│      Scan voor de webshop           │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│     €0,00              0            │
│   Jouw tegoed    Doorverwijzingen   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Hoe het werkt                      │
│  • Deel je code met booteigenaren   │
│  • Zij krijgen 5% korting (min €250)│
│  • Jij ontvangt €15 tegoed          │
│  • Max €150 tegoed opbouwen         │
│                                     │
└─────────────────────────────────────┘
```

## Dependencies

### Reeds aanwezig:
- `url_launcher: ^6.2.1` - Voor WhatsApp links

### Toe te voegen aan `pubspec.yaml`:
- `qr_flutter: ^4.1.0` - QR code generatie
- `share_plus: ^7.2.1` - Native sharing

## Verificatie

1. Build Flutter app: `flutter build apk --debug`
2. Configureer custom page in ThingsBoard
3. Login als klant met referral_code
4. Test:
   - "Doorverwijzen" verschijnt in menu
   - Code wordt correct getoond
   - Kopieer button werkt
   - Delen opent native share sheet
   - WhatsApp opent met voorgeformuleerde tekst
   - QR code is scanbaar

## Voordelen van deze aanpak

- **Dynamisch**: Menu item via ThingsBoard UI te configureren
- **Flexibel**: Positie en zichtbaarheid aanpasbaar zonder app update
- **Consistent**: Zelfde patroon als BLE Scanner
- **Clean**: Geen hardcoded menu items in Flutter code
