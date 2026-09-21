import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications
import Firebase
import Foundation   


@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    var mapkey = ""
    private var thermalEventSink: FlutterEventSink?
    private var thermalMethodChannel: FlutterMethodChannel?

    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   FirebaseApp.configure()
          
      let rootViewController = window?.rootViewController as! FlutterViewController
      
    
      let locationChannel = FlutterMethodChannel(name: "ConstantValues",
                                                        binaryMessenger: rootViewController.binaryMessenger)
             locationChannel.setMethodCallHandler({
                 (call: FlutterMethodCall, result: @escaping FlutterResult) in


           if(call.method == "getsecuritykey"){
                     result(Bundle.main.infoDictionary!["graphql_api_key"] as! String)
                 } else if(call.method == "setMapKey"){
                   if let jsonResult = call.arguments as? Dictionary<String, AnyObject> {
                       let googleMapsApiKey =  jsonResult["key"] as? String ?? ""
                       GMSServices.provideAPIKey(googleMapsApiKey)
                   }
                }
                 else if(call.method == "appversion"){
                     result(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                 }

             })

      let thermalChannel = FlutterMethodChannel(name: "thermal",
                                               binaryMessenger: rootViewController.binaryMessenger)
      thermalMethodChannel = thermalChannel
      thermalChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
          if call.method == "getThermalState" {
              result(self?.currentThermalState())
          } else {
              result(FlutterMethodNotImplemented)
          }
      })

      let thermalEventChannel = FlutterEventChannel(name: "thermal_events",
                                                   binaryMessenger: rootViewController.binaryMessenger)
      thermalEventChannel.setStreamHandler(self)

      if #available(iOS 10.0, *) {
               UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
           }
           GeneratedPluginRegistrant.register(with: self)
      
      NotificationCenter.default.addObserver(
          forName: ProcessInfo.thermalStateDidChangeNotification,
          object: nil,
          queue: nil
      ) { _ in
          let currentState = self.currentThermalState()
          print("Thermal state changed to: \(currentState)")
          self.thermalEventSink?(currentState)
          self.thermalMethodChannel?.invokeMethod("thermalStateChanged", arguments: currentState)
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func currentThermalState() -> String {
      switch ProcessInfo.processInfo.thermalState {
      case .nominal: return "nominal"
      case .fair: return "fair"
      case .serious: return "serious"
      case .critical: return "critical"
      @unknown default: return "unknown"
      }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      thermalEventSink = events
      events(currentThermalState())
      return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
      thermalEventSink = nil
      return nil
  }
}
