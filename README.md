
An updater package for updating flutter apps

## Features

-- Normal update
-- Force update
-- Skip incremental updates
-- Download and install updates directly

## Getting started

App needs to be initialized on app startup with BitUpdaterInit().

## Usage

Just call BitUpdater() with required and optional parameters and you are done.

## Additional information

The package is still in WIP. 

## Configuration

# iOS

Add any URL schemes passed to canLaunchUrl as LSApplicationQueriesSchemes entries in your Info.plist file.

Example:

``` <key>LSApplicationQueriesSchemes</key>
<array>
<string>https</string>
<string>http</string>
</array>
```

# Android

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
