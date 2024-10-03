//
//  MapsRequestPermissonsButtonView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 30.09.24.
//

import SwiftUI

struct MapsRequestPermissonsButtonView: View {
	@EnvironmentObject private var locationManager: LocationPermissionManager

	@State private var showDebugPopup: Bool = false

    var body: some View {
		Section {
			HStack {
				Button {
					locationManager.requestPermission()
					locationManager.requestLocation()
				} label: {
					Label("Request Location Permission", systemImage: "questionmark")
				}
			}
		} header: {
			HStack {
				Text(locationManager.authorizationStatusString)
				Spacer()
				Button {
					showDebugPopup.toggle()
				} label: {
					HStack {
						Image(systemName: "info.circle")
					}
				}
				.popover(isPresented: $showDebugPopup) {
					Form {
						Section {
							if let error = locationManager.error {
								Text("Error: \(error.localizedDescription)")
									.foregroundColor(.red)
							}
						}
					}
					.frame(width: 300, height: 200)
					.presentationCompactAdaptation(.popover)
				}
			}
		}
    }
}

#Preview {
    MapsRequestPermissonsButtonView()
}
