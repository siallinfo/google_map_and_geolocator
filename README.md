# Live Location Map

A Flutter app that follows the device's current location on Google Maps, refreshes
the position every 10 seconds, and draws the route between location updates. Use
the layers menu to switch between normal, satellite, terrain, and hybrid views.
Tap the marker to see its coordinates.

## Google Maps API key

Enable the Maps SDK for Android and Maps SDK for iOS for your Google Cloud
project, and restrict the key to this app's Android and iOS identifiers.

- **Android:** Add `MAPS_API_KEY=your_key` to `android/local.properties`.
- **iOS:** Create `ios/Flutter/GoogleMaps.xcconfig` with
  `GOOGLE_MAPS_API_KEY=your_key`.

These local configuration files are excluded from version control. The key is
embedded in the mobile app at build time, so restrict it to the platform SDKs and
application identifiers instead of treating it as a server-side secret.

## Run

```sh
flutter pub get
flutter run
```

The app requests foreground location permission. Location access is used only
while the app is open; updates are fetched every 10 seconds.
