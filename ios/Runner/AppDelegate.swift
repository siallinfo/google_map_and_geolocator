import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard
      let mapsAPIKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String,
      !mapsAPIKey.isEmpty
    else {
      fatalError("Set GOOGLE_MAPS_API_KEY in ios/Flutter/GoogleMaps.xcconfig.")
    }
    GMSServices.provideAPIKey(mapsAPIKey)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
