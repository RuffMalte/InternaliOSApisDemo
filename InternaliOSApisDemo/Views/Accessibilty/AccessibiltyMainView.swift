//
//  AccessibiltyMainView.swift
//  InternaliOSApisDemo
//
//  Created by Malte Ruff on 02.10.24.
//

import SwiftUI

struct AccessibiltyMainView: View {
	@State private var isToggleOn = false
	@State private var sliderValue = 0.5
	@State private var stepperValue = 0
	@State private var isFocused = false
	@Environment(\.sizeCategory) var sizeCategory
	
	var body: some View {
		Form {
			Section {
				Image(systemName: "accessibility")
					.resizable()
					.frame(width: 100, height: 100)
					.accessibilityLabel("Accessibility icon")
					.accessibilityRemoveTraits(.isImage)
					.accessibilityAddTraits(.isButton)
				
				Button(action: {
					print("Button tapped")
				}) {
					Text("Tap me")
				}
				.accessibilityHint("Tapping this button will print a message")
				
				Toggle("Enable feature", isOn: $isToggleOn)
					.accessibilityValue(isToggleOn ? "Enabled" : "Disabled")
				
				Slider(value: $sliderValue)
					.accessibilityValue(String(format: "%.0f percent", sliderValue * 100))
					.accessibilityAdjustableAction { direction in
						switch direction {
						case .increment:
							sliderValue = min(sliderValue + 0.1, 1.0)
						case .decrement:
							sliderValue = max(sliderValue - 0.1, 0.0)
						@unknown default:
							break
						}
					}
				
				Stepper("Adjust value", value: $stepperValue, in: 0...10)
					.accessibilityValue("\(stepperValue)")
				
				Text("This is some important information")
					.accessibilityElement(children: .ignore)
					.accessibilityLabel("Important information")
					.accessibilityAddTraits(.isStaticText)
				
				HStack {
					Text("Group of items")
					Spacer()
					Image(systemName: "star.fill")
					Image(systemName: "heart.fill")
					Image(systemName: "bell.fill")
				}
				.accessibilityElement(children: .combine)
				.accessibilityLabel("Group with star, heart, and bell icons")
				
				
				Text("Custom Representation")
					.accessibilityRepresentation {
						Text("This is a custom accessibility representation")
					}
				
				Text("Additional Info")
					.accessibilityChildren {
						Text("This is additional accessibility information")
					}
				
			} header: {
				Text("Accessibility Demo")
					.accessibilityAddTraits(.isHeader)
			}
			
			Section(header: Text("Font Sizes")) {
				Text("Default Text")
				
				Text("Dynamic Type Size")
					.font(.system(size: 20, weight: .regular, design: .default))
					.dynamicTypeSize(...DynamicTypeSize.accessibility5)
				
				Text("Current Dynamic Type: \(sizeCategory.description)")
					.font(.footnote)
			}
		}
		.navigationTitle("Accessibility Demo")

	}
}

extension ContentSizeCategory {
	var description: String {
		switch self {
		case .extraSmall: return "Extra Small"
		case .small: return "Small"
		case .medium: return "Medium"
		case .large: return "Large"
		case .extraLarge: return "Extra Large"
		case .extraExtraLarge: return "Extra Extra Large"
		case .extraExtraExtraLarge: return "Extra Extra Extra Large"
		case .accessibilityMedium: return "Accessibility Medium"
		case .accessibilityLarge: return "Accessibility Large"
		case .accessibilityExtraLarge: return "Accessibility Extra Large"
		case .accessibilityExtraExtraLarge: return "Accessibility Extra Extra Large"
		case .accessibilityExtraExtraExtraLarge: return "Accessibility Extra Extra Extra Large"
		@unknown default: return "Unknown"
		}
	}
}
#Preview {
    AccessibiltyMainView()
}
