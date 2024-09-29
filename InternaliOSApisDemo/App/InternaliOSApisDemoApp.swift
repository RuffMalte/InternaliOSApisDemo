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
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(reminderManager)
        }
    }
}
