//
//  ReminderMediumCellView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 28.09.24.
//

import SwiftUI
import EventKit

struct ReminderMediumCellView: View {
	
	var reminder: EKReminder
	
	let toggleAction: () -> Void
	let deleteAction: () -> Void
	
	@State private var isShowingDetailSheet: Bool = false
	
    var body: some View {
		HStack {
			
			Button {
				toggleAction()
			} label: {
				if reminder.isCompleted {
					Image(systemName: "checkmark.circle.fill")
				} else {
					Image(systemName: "circle")
				}
			}
			.buttonStyle(.plain)
			.foregroundStyle(reminder.isCompleted ? Color.accentColor : Color.gray)
			.font(.title3)
			
			VStack(alignment: .leading) {
				HStack {
					Text(reminder.priorityDisplay)
						.foregroundStyle(.tint)
					Text(reminder.title)
				}
				if let notes = reminder.notes {
					Text(notes)
						.font(.footnote)
						.foregroundStyle(.gray)
						.lineLimit(2)
				}
				
				if let dueDate = reminder.dueDateComponents {
					if let date = Calendar.current.date(from: dueDate) {
						let now = Date()
						let isToday = Calendar.current.isDateInToday(date)
						let isPast = date < now
						
						Text(date.formatted(
							.dateTime
								.day(.defaultDigits)
								.month(.defaultDigits)
								.year(.defaultDigits)
								.hour()
								.minute()
						))
						.font(.footnote)
						.foregroundColor(isToday || isPast ? .red : .gray)
					}
				}
				
			}
			.foregroundStyle(reminder.isCompleted ? Color.gray : Color.primary)
		}
		.contextMenu {
			Button(role: .destructive) {
				deleteAction()
			} label: {
				Label("Delete", systemImage: "trash")
			}
			Button {
				isShowingDetailSheet.toggle()
			} label: {
				Label("Edit", systemImage: "pencil")
			}

		}
		.sheet(isPresented: $isShowingDetailSheet) {
			ModifyReminderView(reminder: reminder)
		}
    }
}

//#Preview {
//	ReminderMediumCellView()
//}
