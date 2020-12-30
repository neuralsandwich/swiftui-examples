//
//  AppDelegatesApp.swift
//  Shared
//
//  Created by Sean Jones on 29/12/2020.
//

import SwiftUI
import UserNotifications

#if os(macOS)
// Implementation of the AppKit's NSApplicationDelegate.
// This allows us to handling incoming notifications
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		print("Application is starting up. NSApplicationDelegate applicationDidFinishLaunching.")
		
		UNUserNotificationCenter.current().delegate = self
	}
}
#elseif os(iOS)
// Implementation of the UIKits's UIApplicationDelegate.
// This allows us to handling incoming notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
	) -> Bool {
		print("Application is starting up. UIApplicationDelegate didFinishLaunchingWithOptions.")
		
		UNUserNotificationCenter.current().delegate = self
		
		return true
	}
}
#endif

// Using an extension to AppDelegate allows us to add our notification handling to either depending on the platform
extension AppDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		// Any incoming user notification will be set to display as a banner
		// By default whilst an application is running the notification presentation style will be set to None
		// We want to see our notification, even if our application is in the foreground.
		completionHandler(.banner)
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		
		switch response.actionIdentifier {
			case UNNotificationDefaultActionIdentifier:
				// The user tapped the notifcation, bringing us to the foreground
				print("Default identifier: \(response.actionIdentifier)")
				fallthrough
				
			case AppNotificationOpenIdentifier:
				// The user has tapped the open action on the notification
				print("Default/Open identifier: \(response.actionIdentifier)")
				// Send a notification via the Foundation NotificationCenter
				// if the user selected the open action
				NotificationCenter.default.post(name: NSNotification.Name("Detail"), object: nil)
				
			case UNNotificationDismissActionIdentifier, AppNotificationDismissIdentifier:
				// The user dismissed our notification or tapped our dismiss action on the notification
				print("Dismiss identifier: \(response.actionIdentifier)")
				
			default:
				// We recieved an unexpected value, so we will ignore it
				print("Unknown action: \(response.actionIdentifier)")
				break
		}
		
		// Always call the completionHandler
		completionHandler()
	}
}

@main
struct AppDelegatesApp: App {
	// Use the correct ApplicationDelegateAdaptor for the right platform
	#if os(macOS)
	@NSApplicationDelegateAdaptor var delegate: AppDelegate
	#elseif os(iOS)
	@UIApplicationDelegateAdaptor var delegate: AppDelegate
	#endif
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
