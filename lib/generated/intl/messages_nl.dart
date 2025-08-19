// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a nl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'nl';

  static String m0(appTitle) =>
      "Gefeliciteerd!\nUw ${appTitle} account is geactiveerd.\nNu kunt u inloggen op uw ${appTitle} ruimte.";

  static String m1(count) =>
      "${Intl.plural(count, one: 'Alarm', other: 'Alarmen')}";

  static String m2(deviceName) =>
      "Kan geen sessie opzetten met apparaat ${deviceName}. Probeer opnieuw";

  static String m3(link) => "Kan url niet openen: ${link}";

  static String m4(wifiName) =>
      "Verbind met Wi-Fi gelijkaardig aan ${wifiName}";

  static String m5(name) =>
      "Verbinding met het ${name} Wi-Fi netwerk is mislukt.\nZorg ervoor dat uw telefoon verbonden is met het apparaat Wi-Fi netwerk en dat lokale netwerk toegang is ingeschakeld voor deze app in uw apparaat instellingen.";

  static String m6(count) =>
      "${Intl.plural(count, one: 'Dashboard', other: 'Dashboards')}";

  static String m7(count) =>
      "${Intl.plural(count, one: 'Apparaat', other: 'Apparaten')}";

  static String m8(contact) =>
      "Een beveiligingscode is verzonden naar uw e-mailadres op ${contact}.";

  static String m9(count) =>
      "${Intl.plural(count, one: 'Notificatie', other: 'Notificaties')}";

  static String m10(permissions) =>
      "U heeft niet genoeg rechten voor \"${permissions}\" om door te gaan. Open app instellingen, geef rechten en tik op \"Probeer opnieuw\".";

  static String m11(permissions) =>
      "U heeft niet genoeg rechten voor \"${permissions}\" om door te gaan. Geef de vereiste rechten en tik op \"Probeer opnieuw\".";

  static String m12(deviceName) =>
      "Voer PIN van ${deviceName} in om eigendom te bewijzen";

  static String m13(time) =>
      "Code opnieuw verzenden in ${Intl.plural(time, one: '1 seconde', other: '${time} seconden')}";

  static String m14(name) => "Route niet gedefinieerd: ${name}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'Zoek gebruiker', other: 'Zoek gebruikers')}";

  static String m16(contact) =>
      "Een beveiligingscode is verzonden naar uw telefoon op ${contact}.";

  static String m17(name) =>
      "Kan niet verbinden met Wi-Fi omdat netwerken niet gevonden zijn door apparaat ${name}";

  static String m18(version) => "Update naar ${version}";

  static String m19(deviceName) =>
      "Om de installatie van uw apparaat ${deviceName} voort te zetten, geef uw netwerk referenties op.";

  static String m20(network) => "Voer wachtwoord in voor ${network}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("Accepteren"),
    "acceptPrivacyPolicyMessage": MessageLookupByLibrary.simpleMessage(
      "U moet ons privacybeleid accepteren",
    ),
    "acceptTermsOfUseMessage": MessageLookupByLibrary.simpleMessage(
      "U moet onze gebruiksvoorwaarden accepteren",
    ),
    "accountActivated": MessageLookupByLibrary.simpleMessage(
      "Account succesvol geactiveerd!",
    ),
    "accountActivatedText": m0,
    "acknowledge": MessageLookupByLibrary.simpleMessage("Bevestigen"),
    "acknowledged": MessageLookupByLibrary.simpleMessage("Bevestigd"),
    "actionData": MessageLookupByLibrary.simpleMessage("Actie data"),
    "actionStatusFailure": MessageLookupByLibrary.simpleMessage("Mislukt"),
    "actionStatusSuccess": MessageLookupByLibrary.simpleMessage("Succes"),
    "actionTypeActivated": MessageLookupByLibrary.simpleMessage("Geactiveerd"),
    "actionTypeAdded": MessageLookupByLibrary.simpleMessage("Toegevoegd"),
    "actionTypeAddedComment": MessageLookupByLibrary.simpleMessage(
      "Commentaar toegevoegd",
    ),
    "actionTypeAlarmAck": MessageLookupByLibrary.simpleMessage("Bevestigd"),
    "actionTypeAlarmAssigned": MessageLookupByLibrary.simpleMessage(
      "Alarm toegewezen",
    ),
    "actionTypeAlarmClear": MessageLookupByLibrary.simpleMessage("Gewist"),
    "actionTypeAlarmDelete": MessageLookupByLibrary.simpleMessage(
      "Alarm verwijderd",
    ),
    "actionTypeAlarmUnassigned": MessageLookupByLibrary.simpleMessage(
      "Alarm niet toegewezen",
    ),
    "actionTypeAssignedFromTenant": MessageLookupByLibrary.simpleMessage(
      "Toegewezen van tenant",
    ),
    "actionTypeAssignedToCustomer": MessageLookupByLibrary.simpleMessage(
      "Toegewezen aan klant",
    ),
    "actionTypeAssignedToEdge": MessageLookupByLibrary.simpleMessage(
      "Toegewezen aan rand",
    ),
    "actionTypeAssignedToTenant": MessageLookupByLibrary.simpleMessage(
      "Toegewezen aan tenant",
    ),
    "actionTypeAttributesDeleted": MessageLookupByLibrary.simpleMessage(
      "Attributen verwijderd",
    ),
    "actionTypeAttributesRead": MessageLookupByLibrary.simpleMessage(
      "Attributen gelezen",
    ),
    "actionTypeAttributesUpdated": MessageLookupByLibrary.simpleMessage(
      "Attributen bijgewerkt",
    ),
    "actionTypeCredentialsRead": MessageLookupByLibrary.simpleMessage(
      "Referenties gelezen",
    ),
    "actionTypeCredentialsUpdated": MessageLookupByLibrary.simpleMessage(
      "Referenties bijgewerkt",
    ),
    "actionTypeDeleted": MessageLookupByLibrary.simpleMessage("Verwijderd"),
    "actionTypeDeletedComment": MessageLookupByLibrary.simpleMessage(
      "Commentaar verwijderd",
    ),
    "actionTypeLockout": MessageLookupByLibrary.simpleMessage("Uitsluiten"),
    "actionTypeLogin": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "actionTypeLogout": MessageLookupByLibrary.simpleMessage("Uitloggen"),
    "actionTypeProvisionFailure": MessageLookupByLibrary.simpleMessage(
      "Apparaat inrichting is mislukt",
    ),
    "actionTypeProvisionSuccess": MessageLookupByLibrary.simpleMessage(
      "Apparaat ingericht",
    ),
    "actionTypeRelationAddOrUpdate": MessageLookupByLibrary.simpleMessage(
      "Relatie bijgewerkt",
    ),
    "actionTypeRelationDeleted": MessageLookupByLibrary.simpleMessage(
      "Relatie verwijderd",
    ),
    "actionTypeRelationsDeleted": MessageLookupByLibrary.simpleMessage(
      "Alle relaties verwijderd",
    ),
    "actionTypeRpcCall": MessageLookupByLibrary.simpleMessage("RPC oproep"),
    "actionTypeSmsSent": MessageLookupByLibrary.simpleMessage("SMS verzonden"),
    "actionTypeSuspended": MessageLookupByLibrary.simpleMessage("Opgeschort"),
    "actionTypeTimeseriesDeleted": MessageLookupByLibrary.simpleMessage(
      "Telemetrie verwijderd",
    ),
    "actionTypeTimeseriesUpdated": MessageLookupByLibrary.simpleMessage(
      "Telemetrie bijgewerkt",
    ),
    "actionTypeUnassignedFromCustomer": MessageLookupByLibrary.simpleMessage(
      "Niet meer toegewezen aan klant",
    ),
    "actionTypeUnassignedFromEdge": MessageLookupByLibrary.simpleMessage(
      "Niet meer toegewezen aan rand",
    ),
    "actionTypeUpdated": MessageLookupByLibrary.simpleMessage("Bijgewerkt"),
    "actionTypeUpdatedComment": MessageLookupByLibrary.simpleMessage(
      "Commentaar bijgewerkt",
    ),
    "activatingAccount": MessageLookupByLibrary.simpleMessage(
      "Account activeren...",
    ),
    "activatingAccountText": MessageLookupByLibrary.simpleMessage(
      "Uw account wordt momenteel geactiveerd.\nEven geduld...",
    ),
    "active": MessageLookupByLibrary.simpleMessage("Actief"),
    "activity": MessageLookupByLibrary.simpleMessage("Activiteit"),
    "addCommentMessage": MessageLookupByLibrary.simpleMessage(
      "Voeg een commentaar toe...",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Adres"),
    "address2": MessageLookupByLibrary.simpleMessage("Adres 2"),
    "alarmAcknowledgeText": MessageLookupByLibrary.simpleMessage(
      "Weet u zeker dat u het alarm wilt bevestigen?",
    ),
    "alarmAcknowledgeTitle": MessageLookupByLibrary.simpleMessage(
      "Alarm bevestigen",
    ),
    "alarmClearText": MessageLookupByLibrary.simpleMessage(
      "Weet u zeker dat u het alarm wilt wissen?",
    ),
    "alarmClearTitle": MessageLookupByLibrary.simpleMessage("Alarm wissen"),
    "alarmSeverityList": MessageLookupByLibrary.simpleMessage(
      "Alarm ernst lijst",
    ),
    "alarmStatusList": MessageLookupByLibrary.simpleMessage(
      "Alarm status lijst",
    ),
    "alarmTypeList": MessageLookupByLibrary.simpleMessage("Alarm type lijst"),
    "alarmTypes": MessageLookupByLibrary.simpleMessage("Alarm types"),
    "alarms": m1,
    "all": MessageLookupByLibrary.simpleMessage("Alle"),
    "allDevices": MessageLookupByLibrary.simpleMessage("Alle apparaten"),
    "allowAccess": MessageLookupByLibrary.simpleMessage("Toegang toestaan"),
    "alreadyHaveAnAccount": MessageLookupByLibrary.simpleMessage(
      "Heeft u al een account?",
    ),
    "anEmptyRequestDataReceived": MessageLookupByLibrary.simpleMessage(
      "Lege verzoek data ontvangen.",
    ),
    "anyType": MessageLookupByLibrary.simpleMessage("Elk type"),
    "apiUsageState": MessageLookupByLibrary.simpleMessage("API gebruik status"),
    "appTitle": MessageLookupByLibrary.simpleMessage("BlueStar"),
    "areYouSure": MessageLookupByLibrary.simpleMessage("Weet u het zeker?"),
    "asset": MessageLookupByLibrary.simpleMessage("Activa"),
    "assetName": MessageLookupByLibrary.simpleMessage("Activa naam"),
    "assetProfile": MessageLookupByLibrary.simpleMessage("Activa profiel"),
    "assets": MessageLookupByLibrary.simpleMessage("Activa"),
    "assignedToCustomer": MessageLookupByLibrary.simpleMessage(
      "Toegewezen aan klant",
    ),
    "assignedToMe": MessageLookupByLibrary.simpleMessage("Toegewezen aan mij"),
    "assignee": MessageLookupByLibrary.simpleMessage("Toegewezene"),
    "auditLogDetails": MessageLookupByLibrary.simpleMessage(
      "Audit log details",
    ),
    "auditLogs": MessageLookupByLibrary.simpleMessage("Audit logs"),
    "backupCodeAuthDescription": MessageLookupByLibrary.simpleMessage(
      "Voer een van uw backup codes in.",
    ),
    "backupCodeAuthPlaceholder": MessageLookupByLibrary.simpleMessage(
      "Backup code",
    ),
    "bleHelpMessage": MessageLookupByLibrary.simpleMessage(
      "Om uw nieuwe apparaat in te stellen, zorg ervoor dat de Bluetooth van uw telefoon is ingeschakeld en binnen bereik van uw nieuwe apparaat",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuleren"),
    "cannotEstablishSession": m2,
    "cantLaunchUrlLink": m3,
    "changePassword": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord wijzigen",
    ),
    "chooseRegion": MessageLookupByLibrary.simpleMessage("Kies regio"),
    "city": MessageLookupByLibrary.simpleMessage("Stad"),
    "claimingDevice": MessageLookupByLibrary.simpleMessage("Apparaat claimen"),
    "claimingDeviceDone": MessageLookupByLibrary.simpleMessage(
      "Apparaat claimen voltooid",
    ),
    "claimingMessageSuccess": MessageLookupByLibrary.simpleMessage(
      "Apparaat is\nsuccessvol geclaimd",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("Wissen"),
    "cleared": MessageLookupByLibrary.simpleMessage("Gewist"),
    "close": MessageLookupByLibrary.simpleMessage("Sluiten"),
    "codeVerificationFailed": MessageLookupByLibrary.simpleMessage(
      "Code verificatie mislukt!",
    ),
    "confirmNotRobotMessage": MessageLookupByLibrary.simpleMessage(
      "U moet bevestigen dat u geen robot bent",
    ),
    "confirmation": MessageLookupByLibrary.simpleMessage("Bevestiging"),
    "confirmingWifiConnection": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi verbinding bevestigen",
    ),
    "connectToDevice": MessageLookupByLibrary.simpleMessage(
      "Verbinden met apparaat",
    ),
    "connectToTheWifiYouUsuallyUse": MessageLookupByLibrary.simpleMessage(
      "Verbind met de Wi-Fi die u gewoonlijk gebruikt",
    ),
    "connectToWifiSimilarToWifiname": m4,
    "connectingToDevice": MessageLookupByLibrary.simpleMessage(
      "Verbinden met apparaat",
    ),
    "connectionError": MessageLookupByLibrary.simpleMessage("Verbindingsfout"),
    "connectionToTheWifiNetworkFailednpleaseEnsureThatYour": m5,
    "continueText": MessageLookupByLibrary.simpleMessage("Doorgaan"),
    "country": MessageLookupByLibrary.simpleMessage("Land"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Account aanmaken"),
    "createPassword": MessageLookupByLibrary.simpleMessage(
      "Maak een wachtwoord aan",
    ),
    "critical": MessageLookupByLibrary.simpleMessage("Kritiek"),
    "currentPassword": MessageLookupByLibrary.simpleMessage(
      "Huidig wachtwoord",
    ),
    "currentPasswordRequireText": MessageLookupByLibrary.simpleMessage(
      "Huidig wachtwoord is vereist.",
    ),
    "customer": MessageLookupByLibrary.simpleMessage("Klant"),
    "customers": MessageLookupByLibrary.simpleMessage("Klanten"),
    "dashboards": m6,
    "days": MessageLookupByLibrary.simpleMessage("dagen"),
    "delete": MessageLookupByLibrary.simpleMessage("Verwijderen"),
    "deleteComment": MessageLookupByLibrary.simpleMessage(
      "Commentaar verwijderen",
    ),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "deviceList": MessageLookupByLibrary.simpleMessage("Apparaat lijst"),
    "deviceNotAbleToFindWifiNearby": MessageLookupByLibrary.simpleMessage(
      "Apparaat kan Wi-Fi in de buurt niet vinden",
    ),
    "deviceNotFoundMessage": MessageLookupByLibrary.simpleMessage(
      "Apparaten niet gevonden. Zorg ervoor dat de Bluetooth van uw telefoon is ingeschakeld en binnen bereik van uw nieuwe apparaat.",
    ),
    "deviceProfile": MessageLookupByLibrary.simpleMessage("Apparaat profiel"),
    "deviceProvisioning": MessageLookupByLibrary.simpleMessage(
      "Apparaat inrichten",
    ),
    "devices": m7,
    "duration": MessageLookupByLibrary.simpleMessage("Duur"),
    "edge": MessageLookupByLibrary.simpleMessage("Rand"),
    "edit": MessageLookupByLibrary.simpleMessage("Bewerken"),
    "edited": MessageLookupByLibrary.simpleMessage("Bewerkt"),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "emailAuthDescription": m8,
    "emailAuthPlaceholder": MessageLookupByLibrary.simpleMessage("E-mail code"),
    "emailInvalidText": MessageLookupByLibrary.simpleMessage(
      "Ongeldig e-mail formaat.",
    ),
    "emailRequireText": MessageLookupByLibrary.simpleMessage(
      "E-mail is vereist.",
    ),
    "emailVerification": MessageLookupByLibrary.simpleMessage(
      "E-mail verificatie",
    ),
    "emailVerificationInstructionsText": MessageLookupByLibrary.simpleMessage(
      "Volg de instructies in de e-mail om uw aanmeldprocedure te voltooien. Let op: als u de e-mail een tijdje niet heeft gezien, controleer dan uw \'spam\' map of probeer de e-mail opnieuw te verzenden door op de \'Opnieuw verzenden\' knop te klikken.",
    ),
    "emailVerificationSentText": MessageLookupByLibrary.simpleMessage(
      "Een e-mail met verificatie details is verzonden naar het opgegeven e-mailadres ",
    ),
    "emailVerified": MessageLookupByLibrary.simpleMessage(
      "E-mail geverifieerd",
    ),
    "entityType": MessageLookupByLibrary.simpleMessage("Entiteit type"),
    "entityView": MessageLookupByLibrary.simpleMessage("Entiteit weergave"),
    "europe": MessageLookupByLibrary.simpleMessage("Europa"),
    "europeRegionShort": MessageLookupByLibrary.simpleMessage("Frankfurt"),
    "exitDeviceProvisioning": MessageLookupByLibrary.simpleMessage(
      "Apparaat inrichting verlaten",
    ),
    "failedToConnectToServer": MessageLookupByLibrary.simpleMessage(
      "Verbinding met server is mislukt",
    ),
    "failedToLoadAlarmDetails": MessageLookupByLibrary.simpleMessage(
      "Laden van alarm details is mislukt",
    ),
    "failedToLoadTheList": MessageLookupByLibrary.simpleMessage(
      "Laden van de lijst is mislukt",
    ),
    "failureDetails": MessageLookupByLibrary.simpleMessage("Fout details"),
    "fatalApplicationErrorOccurred": MessageLookupByLibrary.simpleMessage(
      "Fatale applicatie fout opgetreden:",
    ),
    "fatalError": MessageLookupByLibrary.simpleMessage("Fatale fout"),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "firebaseIsNotConfiguredPleaseReferToTheOfficialFirebase":
        MessageLookupByLibrary.simpleMessage(
          "Firebase is niet geconfigureerd.\nRaadpleeg de officiële Firebase documentatie voor\nbegeleiding hoe dit te doen.",
        ),
    "firstName": MessageLookupByLibrary.simpleMessage("Voornaam"),
    "firstNameRequireText": MessageLookupByLibrary.simpleMessage(
      "Voornaam is vereist.",
    ),
    "firstNameUpper": MessageLookupByLibrary.simpleMessage("Voornaam"),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hours": MessageLookupByLibrary.simpleMessage("uren"),
    "imNotARobot": MessageLookupByLibrary.simpleMessage("Ik ben geen robot"),
    "inactive": MessageLookupByLibrary.simpleMessage("Inactief"),
    "inactiveUserAlreadyExists": MessageLookupByLibrary.simpleMessage(
      "Inactieve gebruiker bestaat al",
    ),
    "inactiveUserAlreadyExistsMessage": MessageLookupByLibrary.simpleMessage(
      "Er is al een geregistreerde gebruiker met ongeverifieerd e-mailadres.\nKlik op \'Opnieuw verzenden\' knop als u de verificatie e-mail opnieuw wilt verzenden.",
    ),
    "indeterminate": MessageLookupByLibrary.simpleMessage("Onbepaald"),
    "invalidPasswordLengthMessage": MessageLookupByLibrary.simpleMessage(
      "Uw wachtwoord moet minimaal 6 karakters lang zijn",
    ),
    "isRequiredText": MessageLookupByLibrary.simpleMessage("is vereist."),
    "label": MessageLookupByLibrary.simpleMessage("Label"),
    "lastName": MessageLookupByLibrary.simpleMessage("Achternaam"),
    "lastNameRequireText": MessageLookupByLibrary.simpleMessage(
      "Achternaam is vereist.",
    ),
    "lastNameUpper": MessageLookupByLibrary.simpleMessage("Achternaam"),
    "listIsEmptyText": MessageLookupByLibrary.simpleMessage(
      "De lijst is momenteel leeg.",
    ),
    "login": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "loginNotification": MessageLookupByLibrary.simpleMessage(
      "Log in op uw account",
    ),
    "loginWith": MessageLookupByLibrary.simpleMessage("Inloggen met"),
    "logoDefaultValue": MessageLookupByLibrary.simpleMessage("BlueStar Logo"),
    "logout": MessageLookupByLibrary.simpleMessage("Uitloggen"),
    "major": MessageLookupByLibrary.simpleMessage("Belangrijk"),
    "markAllAsRead": MessageLookupByLibrary.simpleMessage(
      "Alles als gelezen markeren",
    ),
    "markAsRead": MessageLookupByLibrary.simpleMessage("Als gelezen markeren"),
    "mfaProviderBackupCode": MessageLookupByLibrary.simpleMessage(
      "Backup code",
    ),
    "mfaProviderEmail": MessageLookupByLibrary.simpleMessage("E-mail"),
    "mfaProviderSms": MessageLookupByLibrary.simpleMessage("SMS"),
    "mfaProviderTopt": MessageLookupByLibrary.simpleMessage(
      "Authenticatie app",
    ),
    "minor": MessageLookupByLibrary.simpleMessage("Klein"),
    "minutes": MessageLookupByLibrary.simpleMessage("minuten"),
    "mobileDashboardShouldBeConfiguredInDeviceProfile":
        MessageLookupByLibrary.simpleMessage(
          "Mobiel dashboard moet geconfigureerd zijn in apparaat profiel!",
        ),
    "more": MessageLookupByLibrary.simpleMessage("Meer"),
    "newPassword": MessageLookupByLibrary.simpleMessage("Nieuw wachtwoord"),
    "newPassword2": MessageLookupByLibrary.simpleMessage(
      "Nieuw wachtwoord bevestigen",
    ),
    "newPassword2RequireText": MessageLookupByLibrary.simpleMessage(
      "Nieuw wachtwoord nogmaals is vereist.",
    ),
    "newPasswordRequireText": MessageLookupByLibrary.simpleMessage(
      "Nieuw wachtwoord is vereist.",
    ),
    "newUserText": MessageLookupByLibrary.simpleMessage("Nieuwe gebruiker?"),
    "next": MessageLookupByLibrary.simpleMessage("Volgende"),
    "no": MessageLookupByLibrary.simpleMessage("Nee"),
    "noAlarmsFound": MessageLookupByLibrary.simpleMessage(
      "Geen alarmen gevonden",
    ),
    "noDashboardsFound": MessageLookupByLibrary.simpleMessage(
      "Geen dashboards gevonden",
    ),
    "noNotificationsFound": MessageLookupByLibrary.simpleMessage(
      "Geen notificaties gevonden",
    ),
    "noResultsFound": MessageLookupByLibrary.simpleMessage(
      "Geen resultaten gevonden",
    ),
    "northAmerica": MessageLookupByLibrary.simpleMessage("Noord-Amerika"),
    "northAmericaRegionShort": MessageLookupByLibrary.simpleMessage(
      "N. Virginia",
    ),
    "notFound": MessageLookupByLibrary.simpleMessage("Niet gevonden"),
    "notImplemented": MessageLookupByLibrary.simpleMessage(
      "Niet geïmplementeerd!",
    ),
    "notificationRequest": MessageLookupByLibrary.simpleMessage(
      "Notificatie verzoek",
    ),
    "notificationRule": MessageLookupByLibrary.simpleMessage(
      "Notificatie regel",
    ),
    "notificationTarget": MessageLookupByLibrary.simpleMessage(
      "Notificatie doel",
    ),
    "notificationTemplate": MessageLookupByLibrary.simpleMessage(
      "Notificatie sjabloon",
    ),
    "notifications": m9,
    "openAppSettings": MessageLookupByLibrary.simpleMessage(
      "App instellingen openen",
    ),
    "openAppSettingsToGrantPermissionMessage": m10,
    "openSettingsAndGrantAccessToCameraToContinue":
        MessageLookupByLibrary.simpleMessage(
          "Open instellingen en geef toegang tot camera om door te gaan",
        ),
    "openWifiSettings": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi instellingen openen",
    ),
    "or": MessageLookupByLibrary.simpleMessage("OF"),
    "originator": MessageLookupByLibrary.simpleMessage("Oorsprong"),
    "otaPackage": MessageLookupByLibrary.simpleMessage("OTA pakket"),
    "password": MessageLookupByLibrary.simpleMessage("Wachtwoord"),
    "passwordErrorNotification": MessageLookupByLibrary.simpleMessage(
      "Ingevoerde wachtwoorden moeten hetzelfde zijn!",
    ),
    "passwordForgotText": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord vergeten?",
    ),
    "passwordRequireText": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord is vereist.",
    ),
    "passwordReset": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord resetten",
    ),
    "passwordResetLinkSuccessfullySentNotification":
        MessageLookupByLibrary.simpleMessage(
          "Wachtwoord reset link is succesvol verstuurd!",
        ),
    "passwordResetText": MessageLookupByLibrary.simpleMessage(
      "Voer het e-mailadres in dat bij uw account hoort en we sturen u een e-mail met een link om uw wachtwoord te resetten",
    ),
    "passwordSuccessNotification": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord succesvol gewijzigd",
    ),
    "permissions": MessageLookupByLibrary.simpleMessage("Rechten"),
    "permissionsNotEnoughMessage": m11,
    "phone": MessageLookupByLibrary.simpleMessage("Telefoon"),
    "pleaseFollowTheNextStepsToConnectYourPhoneTo":
        MessageLookupByLibrary.simpleMessage(
          "Volg de volgende stappen om uw telefoon te verbinden met het apparaat",
        ),
    "pleaseFollowTheNextStepsToReconnectnyourPhoneToYour":
        MessageLookupByLibrary.simpleMessage(
          "Volg de volgende stappen om uw telefoon\nopnieuw te verbinden met uw gewone Wi-Fi",
        ),
    "pleaseScanQrCodeOnYourDevice": MessageLookupByLibrary.simpleMessage(
      "Scan QR code op uw apparaat",
    ),
    "plusAlarmType": MessageLookupByLibrary.simpleMessage("+ Alarm type"),
    "popTitle": m12,
    "postalCode": MessageLookupByLibrary.simpleMessage("Postcode"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacybeleid"),
    "profile": MessageLookupByLibrary.simpleMessage("Profiel"),
    "profileSuccessNotification": MessageLookupByLibrary.simpleMessage(
      "Profiel succesvol bijgewerkt",
    ),
    "provisionedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "Apparaat is succesvol ingericht",
    ),
    "pushNotificationsAreNotConfiguredpleaseContactYourSystemAdministrator":
        MessageLookupByLibrary.simpleMessage(
          "Push notificaties zijn niet geconfigureerd.\nNeem contact op met uw systeembeheerder.",
        ),
    "queue": MessageLookupByLibrary.simpleMessage("Wachtrij"),
    "ready": MessageLookupByLibrary.simpleMessage("Klaar"),
    "refresh": MessageLookupByLibrary.simpleMessage("Vernieuwen"),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Herhaal uw wachtwoord",
    ),
    "requestPasswordReset": MessageLookupByLibrary.simpleMessage(
      "Wachtwoord reset aanvragen",
    ),
    "requestedEntityDoesNotExists": MessageLookupByLibrary.simpleMessage(
      "Gevraagde entiteit bestaat niet.",
    ),
    "resend": MessageLookupByLibrary.simpleMessage("Opnieuw verzenden"),
    "resendCode": MessageLookupByLibrary.simpleMessage(
      "Code opnieuw verzenden",
    ),
    "resendCodeWait": m13,
    "reset": MessageLookupByLibrary.simpleMessage("Resetten"),
    "retry": MessageLookupByLibrary.simpleMessage("Opnieuw proberen"),
    "returnToDashboard": MessageLookupByLibrary.simpleMessage(
      "Terug naar dashboard",
    ),
    "returnToTheAppAndTapReadyButton": MessageLookupByLibrary.simpleMessage(
      "Ga terug naar de app en tik op de Klaar knop",
    ),
    "routeNotDefined": m14,
    "rpc": MessageLookupByLibrary.simpleMessage("RPC"),
    "ruleChain": MessageLookupByLibrary.simpleMessage("Regel ketting"),
    "ruleNode": MessageLookupByLibrary.simpleMessage("Regel node"),
    "scanACode": MessageLookupByLibrary.simpleMessage("Scan een code"),
    "scanQrCode": MessageLookupByLibrary.simpleMessage("QR code scannen"),
    "search": MessageLookupByLibrary.simpleMessage("Zoeken"),
    "searchResults": MessageLookupByLibrary.simpleMessage("Zoekresultaten"),
    "searchUsers": m15,
    "seconds": MessageLookupByLibrary.simpleMessage("seconden"),
    "selectRegion": MessageLookupByLibrary.simpleMessage("Selecteer regio"),
    "selectUser": MessageLookupByLibrary.simpleMessage("Selecteer gebruikers"),
    "selectWayToVerify": MessageLookupByLibrary.simpleMessage(
      "Selecteer een manier om te verifiëren",
    ),
    "selectWifiNetwork": MessageLookupByLibrary.simpleMessage(
      "Selecteer Wi-Fi netwerk",
    ),
    "sendingWifiCredentials": MessageLookupByLibrary.simpleMessage(
      "Wi-Fi referenties verzenden",
    ),
    "severity": MessageLookupByLibrary.simpleMessage("Ernst"),
    "signIn": MessageLookupByLibrary.simpleMessage("Inloggen"),
    "signUp": MessageLookupByLibrary.simpleMessage("Aanmelden"),
    "smsAuthDescription": m16,
    "smsAuthPlaceholder": MessageLookupByLibrary.simpleMessage("SMS code"),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan",
    ),
    "somethingWentWrongRollback": MessageLookupByLibrary.simpleMessage(
      "Er is iets misgegaan... Terugdraaien",
    ),
    "startTime": MessageLookupByLibrary.simpleMessage("Start tijd"),
    "stateOrProvince": MessageLookupByLibrary.simpleMessage(
      "Staat / Provincie",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "systemAdministrator": MessageLookupByLibrary.simpleMessage(
      "Systeem beheerder",
    ),
    "tbResource": MessageLookupByLibrary.simpleMessage("Bron"),
    "tenant": MessageLookupByLibrary.simpleMessage("Tenant"),
    "tenantAdministrator": MessageLookupByLibrary.simpleMessage(
      "Tenant beheerder",
    ),
    "tenantProfile": MessageLookupByLibrary.simpleMessage("Tenant profiel"),
    "termsOfUse": MessageLookupByLibrary.simpleMessage("Gebruiksvoorwaarden"),
    "title": MessageLookupByLibrary.simpleMessage("Titel"),
    "toggleCamera": MessageLookupByLibrary.simpleMessage("Camera omschakelen"),
    "toggleFlash": MessageLookupByLibrary.simpleMessage("Flits omschakelen"),
    "toptAuthPlaceholder": MessageLookupByLibrary.simpleMessage("Code"),
    "totpAuthDescription": MessageLookupByLibrary.simpleMessage(
      "Voer de beveiligingscode in van uw authenticatie app.",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Probeer opnieuw"),
    "tryAnotherWay": MessageLookupByLibrary.simpleMessage(
      "Probeer een andere manier",
    ),
    "tryRefiningYourQuery": MessageLookupByLibrary.simpleMessage(
      "Probeer uw zoekopdracht te verfijnen",
    ),
    "tryRefreshing": MessageLookupByLibrary.simpleMessage(
      "Probeer te vernieuwen",
    ),
    "type": MessageLookupByLibrary.simpleMessage("Type"),
    "unableConnectToDevice": MessageLookupByLibrary.simpleMessage(
      "Kan niet verbinden met apparaat",
    ),
    "unableConnectToWifiBecauseNetworksWasntFoundByDevice": m17,
    "unableToUseCamera": MessageLookupByLibrary.simpleMessage(
      "Kan camera niet gebruiken",
    ),
    "unacknowledged": MessageLookupByLibrary.simpleMessage("Niet bevestigd"),
    "unassigned": MessageLookupByLibrary.simpleMessage("Niet toegewezen"),
    "unknownError": MessageLookupByLibrary.simpleMessage("Onbekende fout."),
    "unread": MessageLookupByLibrary.simpleMessage("Ongelezen"),
    "update": MessageLookupByLibrary.simpleMessage("Bijwerken"),
    "updateRequired": MessageLookupByLibrary.simpleMessage("Update vereist"),
    "updateTo": m18,
    "url": MessageLookupByLibrary.simpleMessage("Url"),
    "user": MessageLookupByLibrary.simpleMessage("Gebruiker"),
    "username": MessageLookupByLibrary.simpleMessage("gebruikersnaam"),
    "users": MessageLookupByLibrary.simpleMessage("Gebruikers"),
    "verificationCodeIncorrect": MessageLookupByLibrary.simpleMessage(
      "Verificatie code is onjuist",
    ),
    "verificationCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Ongeldig verificatie code formaat",
    ),
    "verificationCodeManyRequest": MessageLookupByLibrary.simpleMessage(
      "Te veel verzoeken om verificatie code te controleren",
    ),
    "verifyYourIdentity": MessageLookupByLibrary.simpleMessage(
      "Verifieer uw identiteit",
    ),
    "viewAll": MessageLookupByLibrary.simpleMessage("Alles bekijken"),
    "viewDashboard": MessageLookupByLibrary.simpleMessage("Dashboard bekijken"),
    "warning": MessageLookupByLibrary.simpleMessage("Waarschuwing"),
    "widgetType": MessageLookupByLibrary.simpleMessage("Widget type"),
    "widgetsBundle": MessageLookupByLibrary.simpleMessage("Widgets bundel"),
    "wifiHelpMessage": m19,
    "wifiPassword": MessageLookupByLibrary.simpleMessage("Wi-Fi wachtwoord"),
    "wifiPasswordMessage": m20,
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
  };
}
