
# Add your own localization to ThingsBoard Mobile Application
## Overview

You can add your own locale or improve existing translations to make the app accessible to users in your preferred language.

## Supported Languages

Currently, the ThingsBoard app supports the following languages:

* English
* Arabic
* Chinese (Taiwan)
* Chinese (Simplified)

## Adding Your Own Localization

Follow these steps to add a new language or improve existing translations:

### Step 1: Navigate to Localization Files

Navigate to the lib/l10n directory in your project. You will see files like:

* `intl_ar.arb`
* `intl_en.arb`
* And other language files

### Step 2: Create Your Language File

Add a new .arb file with your translation using the format:

`intl_(languageCode).arb`

For example:

* `intl_es.arb` for Spanish
* `intl_fr.arb` for French
* `intl_de.arb` for German

### Step 3: Add Translations

1. Copy the contents of the intl_en.arb file into your newly created file
2. Start translating the English text to your target language
3. Keep the keys unchanged, only translate the values

Example structure:
```
{
  "appTitle": "Your App Title Translation",
  "login": "Your Login Translation",
  "password": "Your Password Translation"
}
```

### Step 4: Learn More About Flutter Internationalization

For detailed information about Flutter’s internationalization system, we recommend reading the official Internationalizing Flutter apps guide.

## Testing Your Localization
We recommend installing the Flutter Intl extension, which automatically tracks localization changes and regenerates localization files.

## Alternative Method (Without Extension)
If you prefer not to install the extension, you can use the manual approach:

### Add intl_utils to your project’s dev dependencies:

```
fvm flutter pub add -d intl_utils
```

### Generate localization files after each change:
```
fvm dart run intl_utils:generate
```
Run this command after each change in your localization files to integrate those changes into your app.
