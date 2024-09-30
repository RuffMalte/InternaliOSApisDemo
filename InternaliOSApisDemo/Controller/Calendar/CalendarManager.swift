//
//  CalendarViewModel.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//


import SwiftUI
import EventKit

class CalendarManager: ObservableObject {
    @Published var events: [EKEvent] = []
    private let eventStore = EKEventStore()
    
    init() {
        requestCalendarAccess()
    }
    
    private func requestCalendarAccess() {
		eventStore.requestFullAccessToEvents() { [weak self] granted, error in
            if granted {
                DispatchQueue.main.async {
                    self?.fetchEvents()
                }
            } else {
                print("Access to calendar denied")
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
