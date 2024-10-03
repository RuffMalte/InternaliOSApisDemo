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
	let eventStore = EKEventStore()
	private var notificationObserver: NSObjectProtocol?
	
	init() {
		updateAuthorizationStatus()
		setupNotificationObserver()
	}
	
	deinit {
		removeNotificationObserver()
	}
	
	private func setupNotificationObserver() {
		notificationObserver = NotificationCenter.default.addObserver(
			forName: .EKEventStoreChanged,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.fetchEvents()
		}
	}
	
	private func removeNotificationObserver() {
		if let observer = notificationObserver {
			NotificationCenter.default.removeObserver(observer)
		}
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
	
	func addEvent(_ event: EKEvent) {
		do {
			try eventStore.save(event, span: .thisEvent)
			fetchEvents() // Refresh events after adding a new one
		} catch {
			print("Error saving event: \(error)")
		}
	}
	
	func updateEvent(_ event: EKEvent) {
		do {
			try eventStore.save(event, span: .thisEvent)
			fetchEvents() 
		} catch {
			print("Error updating event: \(error)")
		}
	}
	
	func deleteEvent(_ event: EKEvent) {
		do {
			try eventStore.remove(event, span: .thisEvent)
			fetchEvents()
		} catch {
			print("Error deleting event: \(error)")
		}
	}
}
