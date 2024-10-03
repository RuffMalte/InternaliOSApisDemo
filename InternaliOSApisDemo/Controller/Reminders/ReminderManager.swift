//
//  ReminderManager.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//
import SwiftUI
import EventKit
import Observation

@Observable
class Reminders: Identifiable, ObservableObject {
	var id: UUID
	var reminderList: EKCalendar
	var reminders: [EKReminder]
	
	init(id: UUID = UUID(), reminderList: EKCalendar, reminders: [EKReminder]) {
		self.id = id
		self.reminderList = reminderList
		self.reminders = reminders
	}
}

@Observable class ReminderManager: ObservableObject {
	var reminders: [EKReminder] = []
	var reminderLists: [EKCalendar] = []
	var remindersInList: [Reminders] = []
	let store = EKEventStore()
	var sortOption: SortOption = .dueDate
	
	var calendarAccessStatus: EKAuthorizationStatus = .notDetermined
	
	init() {
		setupNotificationObserver()
		checkAuthorizationStatus()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func setupNotificationObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(eventStoreChanged),
			name: .EKEventStoreChanged,
			object: store
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(calendarsChanged),
			name: .EKEventStoreChanged,
			object: nil
		)
	}
	
	func fetchReminderData() {
		fetchReminders()
		fetchReminderLists()
		updateRemindersInList()
	}
	
	@objc private func eventStoreChanged() {
		fetchReminderData()
	}
	
	@objc private func calendarsChanged() {
		fetchReminderData()
	}
	
	func requestAccess(completion: @escaping (Bool) -> Void) {
		store.requestFullAccessToReminders { granted, error in
			DispatchQueue.main.async {
				if granted {
					self.fetchReminderData()
				}
				completion(granted)
			}
		}
	}
	
	private func checkAuthorizationStatus() {
		let status = EKEventStore.authorizationStatus(for: .reminder)
		DispatchQueue.main.async {
			self.calendarAccessStatus = status
		}
	}
	
	//MARK: - reminders
	func fetchReminders() {
		let predicate = store.predicateForReminders(in: nil)
		store.fetchReminders(matching: predicate) { reminders in
			DispatchQueue.main.async {
				self.reminders = reminders ?? []
				self.sortReminders()
				self.updateRemindersInList()
			}
		}
	}
	
	func fetchReminders(from list: EKCalendar? = nil, completion: @escaping ([EKReminder]) -> Void) {
		let predicate: NSPredicate
		if let list = list {
			predicate = store.predicateForReminders(in: [list])
		} else {
			predicate = store.predicateForReminders(in: nil)
		}
		store.fetchReminders(matching: predicate) { reminders in
			DispatchQueue.main.async {
				let fetchedReminders = reminders ?? []
				completion(fetchedReminders)
			}
		}
	}
	
	func addReminder(_ reminder: EKReminder, to list: EKCalendar? = nil, completion: @escaping (Bool, Error?) -> Void) {
		if let list = list {
			reminder.calendar = list
		}
		do {
			try store.save(reminder, commit: true)
			DispatchQueue.main.async {
				self.reminders.append(reminder)
				self.updateRemindersInList()
				completion(true, nil)
			}
		} catch {
			print("Error saving reminder: \(error.localizedDescription)")
			DispatchQueue.main.async {
				completion(false, error)
			}
		}
	}
	
	func updateReminder(_ reminder: EKReminder, newCalendarID: String?, completion: @escaping (Bool, Error?) -> Void) {
		do {
			if let newCalendarID = newCalendarID,
			   let newCalendar = self.reminderLists.first(where: { $0.calendarIdentifier == newCalendarID }),
			   reminder.calendar.calendarIdentifier != newCalendarID {
				reminder.calendar = newCalendar
			}
			
			try store.save(reminder, commit: true)
			DispatchQueue.main.async {
				self.updateRemindersInList()
				completion(true, nil)
			}
		} catch {
			print("Error saving reminder: \(error.localizedDescription)")
			DispatchQueue.main.async {
				completion(false, error)
			}
		}
	}
	
	func deleteReminder(_ reminder: EKReminder, completion: @escaping (Bool, Error?) -> Void) {
		do {
			try store.remove(reminder, commit: true)
			DispatchQueue.main.async {
				self.reminders.removeAll(where: { $0.calendarItemIdentifier == reminder.calendarItemIdentifier })
				self.updateRemindersInList()
				completion(true, nil)
			}
		} catch {
			print("Error deleting reminder: \(error.localizedDescription)")
			DispatchQueue.main.async {
				completion(false, error)
			}
		}
	}
	
	//MARK: - reminder List
	func fetchReminderLists() {
		let calendars = store.calendars(for: .reminder)
		DispatchQueue.main.async {
			self.reminderLists = calendars
			self.updateRemindersInList()
		}
	}
	
	//MARK: - reminders in list
	private func updateRemindersInList() {
		remindersInList = reminderLists.map { list in
			let remindersInThisList = reminders.filter { $0.calendar.calendarIdentifier == list.calendarIdentifier }
			return Reminders(reminderList: list, reminders: remindersInThisList)
		}
	}
}
