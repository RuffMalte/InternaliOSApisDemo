//
//  ModfiyEventSheetView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 03.10.24.
//

import SwiftUI
import EventKit

struct ModifyEventSheetView: View {
	var ekEvent: EKEvent
	var isNewEvent: Bool
	@EnvironmentObject private var calendarManager: CalendarManager
	@Environment(\.dismiss) private var dismiss
	
	@State private var title: String
	@State private var startDate: Date
	@State private var endDate: Date
	@State private var isAllDay: Bool
	@State private var notes: String
	@State private var location: String
	@State private var calendar: EKCalendar?
	
	init(ekEvent: EKEvent, isNewEvent: Bool) {
		self.ekEvent = ekEvent
		self.isNewEvent = isNewEvent
		_title = State(initialValue: ekEvent.title ?? "")
		_startDate = State(initialValue: ekEvent.startDate ?? Date())
		_endDate = State(initialValue: ekEvent.endDate ?? Date().addingTimeInterval(3600))
		_isAllDay = State(initialValue: ekEvent.isAllDay)
		_notes = State(initialValue: ekEvent.notes ?? "")
		_location = State(initialValue: ekEvent.location ?? "")
		_calendar = State(initialValue: ekEvent.calendar)
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("Event Details")) {
					TextField("Title", text: $title)
					DatePicker("Start", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
					DatePicker("End", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
					Toggle("All-day", isOn: $isAllDay)
				}
				
				Section(header: Text("Additional Information")) {
					TextField("Location", text: $location)
					TextEditor(text: $notes)
						.frame(height: 100)
				}
				
				Section(header: Text("Calendar")) {
					Picker("Calendar", selection: $calendar) {
						Text(calendarManager.eventStore.calendars(for: .event).first?.title ?? "No Calendar Found")
							.tag(nil as EKCalendar?)
						ForEach(calendarManager.eventStore.calendars(for: .event), id: \.self) { calendar in
							Text(calendar.title).tag(calendar as EKCalendar?)
						}
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						saveEvent()
						dismiss()
					} label: {
						Text("Save")
							.bold()
					}
				}
				
				ToolbarItem(placement: .cancellationAction) {
					Button(role: .cancel) {
						dismiss()
					} label: {
						Text("Cancel")
					}
				}
			}
			.navigationTitle(isNewEvent ? "New Event" : "Edit Event")
		}
	}
	
	private func saveEvent() {
		ekEvent.title = title
		ekEvent.startDate = startDate
		ekEvent.endDate = endDate
		ekEvent.isAllDay = isAllDay
		ekEvent.notes = notes
		ekEvent.location = location
		ekEvent.calendar = calendar ?? calendarManager.eventStore.defaultCalendarForNewEvents
		
		if isNewEvent {
			calendarManager.addEvent(ekEvent)
		} else {
			calendarManager.updateEvent(ekEvent)
		}
	}
}

//#Preview {
//    ModfiyEventSheetView()
//}
