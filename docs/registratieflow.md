# Registratieflow: testen en verder werken op de Mac

Hoe een nieuwe klant van de knop in de app tot het eerste dashboard komt, waar elk onderdeel staat, en hoe je het op de Mac in een simulator test. Stand per 2026-11-20.

## Hoe de flow loopt

1. **App** (dit repo). Het inlogscherm (`lib/core/auth/login/login_page.dart`) heeft één knop. Die opent een inlogvenster van het systeem: op iOS een `ASWebAuthenticationSession` (`ios/Runner/TbWebAuthHandler.swift`), op Android een Custom Tab (`android/app/src/main/kotlin/org/thingsboard/app/TbWebAuthHandler.kt`).
2. **ThingsBoard** (`bluestar.nauticsensors.com`). Bepaalt welke knop de app toont (mobiele app `com.nauticsensors.bluestar`, OAuth2-client "NauticSensors ID") en stuurt het inlogvenster door naar Keycloak.
3. **Keycloak** (`account.nauticsensors.com`, realm `nauticsensors`). Toont de inlogpagina, het registratieformulier en "Bevestig uw e-mailadres". Deze pagina's komen uit het repo `keycloak-theme`.
4. **Bevestigingsmail.** De link opent in de browser van de telefoon en niet in het inlogvenster van de app. Keycloak bevestigt het adres daar en zegt dat de klant terug moet naar de app.
5. **Terug in de app.** Het inlogvenster gaat vanzelf verder zodra het weer in beeld komt (script in het thema). Keycloak stuurt via ThingsBoard terug naar `com.nauticsensors.bluestar.auth://…`, het venster sluit en de app is ingelogd.
6. **Backend** (`bluestar`, service tb-messages). Maakt bij de registratie in ThingsBoard de klant, de gebruiker, een boot en de dashboards aan en stuurt een Telegram-melding.

| Onderdeel | Waar | Stand |
|-----------|------|-------|
| Inlogscherm van de app | dit repo, branch `bluestar-1.7.0` | gemerged, nog niet uitgebracht. In de winkels staat 1.7.4+24 met de oude knop "NauticSensors ID". |
| Pagina's van Keycloak | repo `keycloak-theme`, branch `main` | live sinds 2026-11-20 |
| Uitrol van Keycloak | repo `homelab-infra`, `apps/helm/keycloakx` | thema-image `26.5.4-phasetwo.1` |

De pagina's van Keycloak zijn dus al te testen met de app uit de winkel. Voor de nieuwe tekst op het inlogscherm heb je een eigen build nodig.

## De app in een simulator draaien

Nodig: `fvm` (Flutter 3.29.0 staat in `.fvmrc`), Xcode met een simulator of Android Studio met een emulator, en `configs.json` in de root van dit repo. Dat bestand staat niet in git. Het is `configs.sample.json` met de echte app-secrets erin.

```bash
git fetch && git checkout bluestar-1.7.0 && git pull
fvm install                  # eenmalig
fvm flutter pub get
open -a Simulator            # of start een Android-emulator
fvm flutter devices
fvm flutter run -d <device> --dart-define-from-file=configs.json
```

`--dart-define-from-file` is niet optioneel. De bundle-id (`com.nauticsensors.bluestar`), het callback-schema (`com.nauticsensors.bluestar.auth`) en het app-secret komen eruit, en ThingsBoard weigert de login als die niet kloppen met de mobiele app die daar geregistreerd staat.

De app praat met productie (`thingsboardApiEndpoint` in `configs.json`). Alles wat je in de simulator doet, is echt: een registratie maakt een echte klant aan.

## De registratie testen in de iOS Simulator

1. Zorg dat de app is uitgelogd.
2. Tik op de knop, kies in het inlogvenster "Account aanmaken" en vul het formulier in met een adres dat nog geen account heeft, bijvoorbeeld een plus-adres van je eigen mailbox (`naam+test1@…`).
3. Het venster toont "Bevestig uw e-mailadres". De mail komt binnen op je Mac. **De link is 5 minuten geldig.**
4. Kopieer de link achter "E-mailadres bevestigen" uit de mail en open hem in Safari van de simulator:

   ```bash
   xcrun simctl openurl booted '<link uit de mail>'
   ```

   Dit is dezelfde situatie als tikken op de link in Mail op een iPhone: Safari opent naast het inlogvenster van de app.
5. Tik in Safari op "E-mailadres bevestigen". De pagina zegt daarna dat het adres bevestigd is en dat je terug moet naar de BlueStar-app.
6. Ga terug naar de app: Home (⇧⌘H) en tik op BlueStar, of de app-wisselaar (⌃⇧⌘H).
7. **Verwacht:** het inlogvenster herlaadt, sluit, en de app toont het dashboard.

Stap 7 is het enige dat nog niet in een echt inlogvenster van iOS is gezien. Het is nagespeeld met twee browsersessies, lokaal en op productie, en daar werkte het. Blijft het venster op "Bevestig uw e-mailadres" staan, tik dan op "Ik heb mijn e-mailadres bevestigd": die knop doet hetzelfde met de hand. Het script dat het vanzelf moet doen staat in `keycloak-theme` in `themes/nauticsensors/login/resources/js/nauticsensors-verify-email.js` en reageert op `visibilitychange`, `focus` en `pageshow`. Komt geen van die drie in het inlogvenster van iOS, dan is een controle op een timer de voor de hand liggende aanvulling.

Om mee te kijken in het inlogvenster: Safari op de Mac toont onder Ontwikkel de pagina's van de simulator, met console. Of het inlogvenster van de app daar tussen staat, is niet geprobeerd.

### Testaccounts

- Elke registratie maakt een Keycloak-gebruiker, een ThingsBoard-klant met boot en dashboards, en een Telegram-melding.
- Je kunt één testaccount hergebruiken. Zet in de Keycloak-admin (`account-admin.nauticsensors.com`, realm `nauticsensors`, Users, de gebruiker) "Email verified" uit. Bij de volgende login met dat account verschijnt "Bevestig uw e-mailadres" weer en gaat er een nieuwe mail uit. Zo test je stap 3 tot en met 7 zonder nieuwe klant.
- Er staat een testaccount van de uitrol: `support+uitrol-20261120@nauticsensors.com` ("Test Uitrol 2026-11-20"). Het wachtwoord is niet bewaard. Met "Wachtwoord vergeten?" stel je er een in; die mail komt in de mailbox van support.
- Opruimen doe je met de hand: de gebruiker in de Keycloak-admin, de klant en zijn boot in ThingsBoard.

## Android-emulator

De link uit de mail open je zo in de emulator:

```bash
adb shell "am start -a android.intent.action.VIEW -d '<link uit de mail>'"
```

Android werkt anders dan iOS, en dit is afgeleid uit de code, niet getest:

- Het inlogvenster is een Custom Tab van Chrome en deelt de sessie met Chrome. De link uit de mail opent in dezelfde browser, waar Keycloak de login zelf afmaakt en via het callback-schema naar de app terugstuurt.
- De app annuleert een lopende login zodra hij weer op de voorgrond komt (`_cleanUpDanglingCalls` in `lib/core/auth/web/tb_web_auth.dart`, `cleanUpDanglingCalls` in `TbWebAuthHandler.kt`). Komt de klant terug in de app voordat de browser heeft teruggestuurd, dan staat het inlogscherm er weer. Nog een keer op de knop tikken logt dan meteen in, omdat de sessie in Chrome bestaat. Het is de moeite waard om te zien hoe dat voor een klant overkomt.

## Het inlogscherm of de teksten aanpassen

- Scherm: `lib/core/auth/login/login_page.dart`. `_buildOAuth2Button` geeft de client "NauticSensors ID" zijn logo en label.
- Teksten: `lib/l10n/intl_nl.arb` en `intl_en.arb`, sleutels `loginWelcomeTitle`, `loginWelcomeText` en `loginOrCreateAccount`. Daarna de gegenereerde bestanden bijwerken:

  ```bash
  fvm dart run intl_utils:generate
  ```

  De drie sleutels zijn op 2026-11-20 met de hand aan `lib/generated/` toegevoegd, in dezelfde vorm als de generator. Draai de generator een keer om dat te bevestigen.
- De app en de pagina's van Keycloak gebruiken "u". De bevestigingsmail zegt "je".
- Met `r` in het venster van `flutter run` zie je een wijziging direct.

## De pagina's van Keycloak aanpassen

Dat gebeurt in het repo `keycloak-theme`. De README daar beschrijft de lokale Keycloak met Mailpit (`docker compose up -d`), de test die de hele registratie doorloopt (`dev/test`, `npm test`) en de uitrol.

De app kan de lokale Keycloak niet gebruiken: hij logt in via ThingsBoard, en ThingsBoard op productie stuurt door naar Keycloak op productie. Een wijziging in het thema bekijk je dus lokaal in een browser of in Safari van de simulator (`http://localhost:8888/…`), en in de app pas na uitrol.

## Uitbrengen

- Versie in `pubspec.yaml` ophogen (nu `1.7.4+24`) en committen zoals eerder (`chore: Bump version to …`).
- Bouwen en uploaden zoals bij de vorige releases, met `--dart-define-from-file=configs.json`.
- Daarna de handleiding bijwerken. `docs.nauticsensors.com/content/1.bluestar/2.installatie.md` en `nauticsensors.com/content/blog/bluestar-systeem-installeren.md` noemen nog de knop "NauticSensors ID" en het linkje "Registreer". Een push naar die twee repo's rolt de sites uit.

## Open punten

1. Zien dat het inlogvenster op iOS vanzelf doorgaat (stap 7 hierboven), in de simulator en op een iPhone.
2. Het gedrag op Android bekijken, zie hierboven.
3. De app uitbrengen met het nieuwe inlogscherm.
4. De link in de mail en het scherm "Bevestig uw e-mailadres" verlopen allebei na 5 minuten, de standaard van Keycloak. Wie langer naar de mail zoekt, moet opnieuw inloggen en krijgt een nieuwe mail. In de Keycloak-admin: Realm settings, Tokens ("User-Initiated Action Lifespan", of de override voor "Email Verification") en Sessions ("Login action timeout").
5. "je" in de bevestigingsmail naast "u" in de app en op de pagina's.
6. De handleiding en de blogpost bijwerken.
7. Het testaccount van de uitrol verwijderen als je het niet gebruikt.
