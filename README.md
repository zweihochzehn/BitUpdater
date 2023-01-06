
An updater package for updating flutter apps

## Features

-- Normal update
-- Force update
-- Skip incremental updates
-- Download and install updates directly

## Getting started

App needs to be initialized on app startup with BitUpdaterInit().

## Usage
The URL passed to the BitUpdater has to start with 'http' and end with '/', otherwise you will get an error.
The package checks the device platform and adds 'android', 'ios' or 'web' as endpoint to the URL so do not include the endpoint in the URL.

Json Structure:

{
"minVersion": "2.2.1",
"latestVersion": "3.0.3",
"updateUrl": "https://bitrise.io/1234",
"platform": "ANDROID",
}

Make sure that the versioning for latestVersion and minVersion includes major, minor and patch versioning like in the example above.
If the versioning is wrong, updater shows a message saying:
"Wrong versioning info from server. Versioning does not match. Make sure versioning is formatted with MAJOR, MINOR and PATCH. Example: 3.0.0"));
If the versions endpoint is not configured, package will throw an error with the server response but the app will continue to function as expected.

Afterwards just call BitUpdater() with required and optional parameters and you are done.
Call BitUpdater().checkServerForUpdateAndShowDialog() if you want to show an update dialog.
If you need the flexibility then just call BitUpdater().checkServerForUpdate() which returns an UpdateModel
object that has all the info you need to build your own widgets.

## Configuration

### Dependencies

Add url_launcher and get_it  packages to pubspec.yaml

### iOS

Add any URL schemes passed to canLaunchUrl as LSApplicationQueriesSchemes entries in your Info.plist file.

Example:

``` <key>LSApplicationQueriesSchemes</key>
<array>
<string>https</string>
<string>http</string>
</array>
```

### Android

Starting from API 30 Android requires package visibility configuration 
in your AndroidManifest.xml.
A <queries> element must be added to your manifest as a child of the root element.

```
<queries>
  <!-- If your app opens https URLs -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
  <!-- If your app makes calls -->
  <intent>
    <action android:name="android.intent.action.DIAL" />
    <data android:scheme="tel" />
  </intent>
  <!-- If your sends SMS messages -->
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="smsto" />
  </intent>
  <!-- If your app sends emails -->
  <intent>
    <action android:name="android.intent.action.SEND" />
    <data android:mimeType="*/*" />
  </intent>
</queries>
```
