//
//  CalendarView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//
import SwiftUI
import EventKit

struct CalendarMainView: View {
	@EnvironmentObject private var calendarManager: CalendarManager
	
	@State private var isShowingAddEventSheet: Bool = false
    
	var body: some View {
		Form {
			RequestCalendarAccessView()
			
			CalendarListView()
			
			
			
			.navigationTitle("Calendar Events")
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button {
					isShowingAddEventSheet.toggle()
				} label: {
					Image(systemName: "plus")
				}
			}
		}
		.sheet(isPresented: $isShowingAddEventSheet) {
			ModifyEventSheetView(ekEvent: EKEvent(eventStore: calendarManager.eventStore), isNewEvent: true)
		}
    }
}

#Preview {
	CalendarMainView()
}
