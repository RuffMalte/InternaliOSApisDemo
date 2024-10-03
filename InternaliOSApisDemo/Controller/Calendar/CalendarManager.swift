//
//  CalendarViewModel.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//


import SwiftUI
import EventKit
import Observation

@Observable
class CalendarManager: ObservableObject {
	var events: [EKEvent] = []
	var authorizationStatus: EKAuthorizationStatus = .notDetermined
	
	private let eventStore = EKEventStore()
	
	init() {
		updateAuthorizationStatus()
		
	}
	
	func updateAuthorizationStatus() {
		DispatchQueue.main.async {
			self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
			if self.authorizationStatus == .fullAccess {
				self.fetchEvents()
			}
		}
	}
	
	func requestCalendarAccess() {
		eventStore.requestFullAccessToEvents { [weak self] granted, error in
			DispatchQueue.main.async {
				self?.updateAuthorizationStatus()
				if granted {
					self?.fetchEvents()
				} else {
					print("Access to calendar denied")
				}
			}
		}
	}
	
	func fetchEvents() {
		let startDate = Date()
		let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
		let calendars = eventStore.calendars(for: .event)
		let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
		let fetchedEvents = eventStore.events(matching: predicate)
		
		DispatchQueue.main.async {
			self.events = fetchedEvents.sorted { $0.startDate < $1.startDate }
		}
	}
}
