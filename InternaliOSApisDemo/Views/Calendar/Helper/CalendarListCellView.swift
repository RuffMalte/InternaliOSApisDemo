//
//  CalendarListCellView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 03.10.24.
//

import SwiftUI
import EventKit

struct CalendarListCellView: View {
	
	let event: EKEvent
	
	@State private var isShowingEditSheet: Bool = false
	@EnvironmentObject private var calendarManager: CalendarManager

    var body: some View {
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
		.contextMenu{
			Button {
				isShowingEditSheet.toggle()
			} label: {
				Label("Edit", systemImage: "pencil")
			}
			Button(role: .destructive) {
				calendarManager.deleteEvent(event)
			} label: {
				Label("Delete", systemImage: "trash")
			}


		}
		.sheet(isPresented: $isShowingEditSheet) {
			ModifyEventSheetView(ekEvent: event, isNewEvent: false)
		}
    }
}

//#Preview {
//    CalendarListCellView()
//}
