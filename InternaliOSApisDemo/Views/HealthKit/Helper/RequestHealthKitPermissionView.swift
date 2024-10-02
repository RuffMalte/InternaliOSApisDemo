//
//  RequestHealthKitPermissionView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI

struct RequestHealthKitPermissionView: View {
	@EnvironmentObject private var healthKitManager: HealthKitManager
	
    var body: some View {
		Section {
			Button {
				healthKitManager.requestAuthorization()
			} label: {
				Label("Request HealthKit Permission", systemImage: "heart.text.square.fill")
			}
		} header: {
			if healthKitManager.isAuthorized {
				Text("Authorized")
			} else {
				Text("Not Authorized")
			}
		}
		
    }
}

#Preview {
    RequestHealthKitPermissionView()
}
