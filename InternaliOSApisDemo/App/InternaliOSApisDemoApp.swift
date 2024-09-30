//
//  InternaliOSApisDemoApp.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//

import SwiftUI

@main
struct InternaliOSApisDemoApp: App {
	
	@StateObject private var reminderManager = ReminderManager()
	
	@StateObject private var locationManager = LocationPermissionManager()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(reminderManager)
				.environmentObject(locationManager)
        }
    }
}
