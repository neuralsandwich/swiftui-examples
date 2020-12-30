//
//  ContentView.swift
//  Shared
//
//  Created by Sean Jones on 29/12/2020.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
	
	@State var show = false
	
	var body: some View {
		NavigationView {
			ZStack {
				NavigationLink(destination: DetailView(show: self.$show), isActive: self.$show) {
					Text("")
				} // Hide this NavigationLink so it is not displayed as a button on macOS
				.hidden()
				
				VStack(spacing: 20.0) {
					Button("Request Permissions") {
						self.request()
					}
					
					Button("Schedule Notification") {
						self.send()
					}
				}
			}.onAppear {
				// Subscribe to any notifications from Foundations NotificationCenter named "Detail"
				// When we receive this notification we will display DetailView
				//
				// NotificationCenter from Foundation is not the same as UNUserNotificationCenter.
				NotificationCenter.default.addObserver(forName: NSNotification.Name("Detail"), object: nil, queue: .main) { (_) in
					self.show = true
				}
			}
		}
	}
	
	func request() {
		// Present the dialog requesting permission to display alerts, sounds and badges.
		// If we already have permission this does nothing
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if let error = error {
				print(error)
			}
		}
	}
	
	func send() {
		// We clear all pending notifications to avoid accidently scheduling many at once
		// This is fine for this example but you should think before copying this to your application.
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		
		let content = UNMutableNotificationContent()
		content.title = "Example Notification"
		content.subtitle = "Example Subtitle"
		content.sound = UNNotificationSound.default
		
		// These actions will be displayed when the user interacts with the notification.
		// Selecting open will bring this app to the foreground and open the DetailView.
		let open = UNNotificationAction(identifier: AppNotificationOpenIdentifier, title: "Open", options: .foreground)
		let dismiss = UNNotificationAction(identifier: AppNotificationDismissIdentifier, title: "Dismiss", options: [])
		
		// We specify '.customDismissAction' so we are notified if the user dimisses our notification
		let categoryIdentifier = "systems.half.AppDelegatesNotificationCategoryActionsIdentifier"
		let categories = UNNotificationCategory(identifier: categoryIdentifier, actions: [open, dismiss], intentIdentifiers: [], options: .customDismissAction)
		UNUserNotificationCenter.current().setNotificationCategories([categories])
		
		// Set our notification to the category so we can use our actions when it is displayed
		content.categoryIdentifier = categoryIdentifier
		
		// Set our notification to trigger in 2 seconds
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
		
		// Add our notification to the UserNotification system
		UNUserNotificationCenter.current().add(request)
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

struct DetailView: View {
	
	@Binding var show: Bool
	
	var body: some View {
		Text("Detail")
	}
}
