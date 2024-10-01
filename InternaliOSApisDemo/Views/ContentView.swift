//
//  ContentView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 26.09.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		NavigationStack {
			Form {
				Section {
					
					NavigationLink {
						RemindersMainView()
					} label: {
						DemoItemListView(icon: "list.bullet", iconBackground: .red, title: "Reminders")
					}

					
					NavigationLink {
						CalendarView()
					} label: {
						DemoItemListView(icon: "calendar", iconBackground: .blue, title: "Calendar")
					}
				}
				
				Section {
					NavigationLink {
						MapsMainView()
					} label: {
						DemoItemListView(icon: "map.fill", iconBackground: .yellow, title: "MapKit")

					}
				}
				
				Section {
					NavigationLink {
						TranslationMainView()
					} label: {
						DemoItemListView(icon: "globe", iconBackground: .blue, title: "Translation")
					}

				}
				
				Section {
					NavigationLink {
						HealthKitDemoView()
					} label: {
						DemoItemListView(icon: "heart.fill", iconBackground: .red, title: "HealthKit")

					}
					NavigationLink {
						
					} label: {
						DemoItemListView(icon: "figure.run", iconBackground: .green, title: "Workouts")
						
					}
				}
				
				Section {
					NavigationLink {
						
					} label: {
						DemoItemListView(icon: "photo.fill", iconBackground: .black, title: "Photos")
						
					}
					NavigationLink {
						
					} label: {
						DemoItemListView(icon: "camera.fill", iconBackground: .gray, title: "Camera")
						
					}
				}
				
			}
			.navigationTitle("Internal iOS APIs Demo")
		}
    }
}

struct DemoItemListView: View {
	
	var icon: String
	var iconBackground: Color
	var title: String
	
	var body: some View {
		HStack {
			ZStack {
				RoundedRectangle(cornerRadius: 5)
					.frame(width: 30, height: 30)
					.foregroundStyle(iconBackground)
				
				Image(systemName: icon)
					.foregroundStyle(.white)
					.font(.title3)
				
			}
			
			Text(title)
		}
	}
}

#Preview {
    ContentView()
}
