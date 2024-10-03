//
//  RequestCalendarAccessView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 03.10.24.
//

import SwiftUI

struct RequestCalendarAccessView: View {
	@EnvironmentObject private var calendarManager: CalendarManager

    var body: some View {
		Section {
			Button {
				calendarManager.requestCalendarAccess()
			} label: {
				Label("Request Calendar Access", systemImage: "calendar")
			}
		} header: {
			if calendarManager.authorizationStatus == .fullAccess {
				Text("Access Granted")
			} else {
				Text("Not Granted")
			}
		}
    }
}

#Preview {
    RequestCalendarAccessView()
}
