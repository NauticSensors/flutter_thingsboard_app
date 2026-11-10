# Doorverwijzen: de referral-pagina

De pagina "Doorverwijzen" toont de doorverwijscode van de klant, manieren om die te delen, het opgebouwde tegoed en een korte uitleg van de regeling. Het is een eigen Flutter-pagina, geen dashboard.

## Hoe de pagina in het menu komt

Het menu van de app komt van de server. De pagina staat daar als eigen pagina met een pad; de app koppelt dat pad aan de Flutter-pagina.

```
ThingsBoard, mobile center, bundel van de app, Layout
  pagina "Doorverwijzen", type Custom, pad /referral
        │
        ▼  de app haalt de paginalijst op na het inloggen
Flutter-app
  GoRoute /referral  →  ReferralPage
```

Instellen op de server, als systeembeheerder:

1. Ga naar Mobile center, open de bundel van de app en kies Layout.
2. Voeg een pagina toe van het type Custom.
3. Vul in: naam `Doorverwijzen`, pad `/referral`, en kies een icoon.
4. Zet de pagina op de gewenste plek en sla op.

Positie, naam en icoon zijn daarna zonder app-update aan te passen. Het pad niet: dat staat ook in de app.

## Gegevens

De backend houdt de gegevens bij als server-attributen op de klant (customer):

| Attribuut | Betekenis |
|---|---|
| `referral_code` | de code die de klant uitdeelt |
| `referral_credit` | opgebouwd tegoed in euro's |
| `referral_count` | aantal doorverwijzingen dat tot een bestelling leidde |

De app leest ze alleen. De link naar de webshop is `https://nauticsensors.com/?ref=<code>`; dezelfde link zit in de QR-code.

## Code

| Bestand | Rol |
|---|---|
| `lib/modules/referral/repository/referral_repository.dart` | alle datatoegang: leest de drie attributen van de klant van de ingelogde gebruiker en geeft een `ReferralInfo` terug |
| `lib/modules/referral/presentation/view/referral_page.dart` | de pagina: code, kopiëren, delen, WhatsApp, QR-code, tegoed en uitleg |
| `lib/config/routes/v2/routes_config/routes/referral_routes.dart` | de GoRoute voor `/referral` |
| `lib/l10n/intl_en.arb`, `lib/l10n/intl_nl_NL.arb` | teksten, sleutels die met `referral` beginnen |

De pagina praat niet zelf met de ThingsBoard-client. Verandert de manier waarop de gegevens worden opgehaald, dan hoeft alleen `ReferralRepository` mee te veranderen.

Pakketten: `qr_flutter` voor de QR-code, `share_plus` voor het deelvenster van het toestel en `url_launcher` voor de WhatsApp-link.

## Controleren

1. Log in als een klant met een `referral_code`.
2. "Doorverwijzen" staat in het menu en toont de code, het tegoed en het aantal doorverwijzingen.
3. Kopiëren zet de code op het klembord.
4. Delen opent het deelvenster van het toestel met de voorbereide tekst.
5. WhatsApp opent met dezelfde tekst.
6. De QR-code leidt naar de webshop met de code ingevuld.
