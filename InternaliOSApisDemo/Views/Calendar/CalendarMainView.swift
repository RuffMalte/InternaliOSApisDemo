//
//  CalendarView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//
import SwiftUI

struct CalendarMainView: View {
	@EnvironmentObject private var calendarManager: CalendarManager
    
	var body: some View {
		Form {
			RequestCalendarAccessView()
			
			Section {
				List(calendarManager.events, id: \.eventIdentifier) { event in
					VStack(alignment: .leading) {
						Text(event.title)
							.font(.headline)
						Text("\(event.startDate, style: .date) - \(event.endDate, style: .date)")
							.font(.subheadline)
						
						if let location = event.location, !location.isEmpty {
							Text(location)
								.font(.caption)
								.foregroundColor(.secondary)
						}
					}
				}
			}
			
			
			
			.navigationTitle("Calendar Events")
		}
    }
}

#Preview {
	CalendarMainView()
}
