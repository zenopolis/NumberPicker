//
//  NumericKeyboardView.swift
//  NumberPicker
//
//  Created by David Kennedy on 21/08/2026.
//

#if os(iOS)

import SwiftUI

/// Useful resource:
/// * __Fatbobman's Blog__:  [SwiftUI TextField Advanced — Events, Focus, and Keyboard](https://fatbobman.com/en/posts/textfield-event-focus-keyboard/)

public struct NumericKeyboardView: View {
    
    // MARK: - Constants
    
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.roundingMode = .ceiling
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    // MARK: - State
        
    @FocusState private var isFocused: Bool
    
    @State private var text: String = ""
    @State private var selection: TextSelection?

    private var withActionRequest = false
    private var onActionRequest: ((NumberPicker.ActionRequest)->Void)?

    private var accessibilityValue: String {
        text.isEmpty ? "empty" : text
    }

    // MARK: - Parameters
    
    @Binding var value: Int?
    
    // MARK: - Lifecycle
    
    public init(value: Binding<Int?>, onActionRequest: ((NumberPicker.ActionRequest)->Void)? = nil) {
        self._value = value
        self.onActionRequest = onActionRequest
        self.withActionRequest = (onActionRequest != nil)
    }
    
    // MARK: - View

    public var body: some View {
        ZStack  {
            Color(uiColor: .secondarySystemBackground).edgesIgnoringSafeArea(.all)
            VStack {
                TextField("", text: $text, selection: $selection)
                    .focused($isFocused)
                    .padding()
                    .padding(.horizontal, 6)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
                    .keyboardType(.numbersAndPunctuation)
                    .autocorrectionDisabled()
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .accessibilityLabel("")
                    .accessibilityValue(accessibilityValue)
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .decrement:
                            decrementValue()
                        case .increment:
                            incrementValue()
                        default:
                            break
                        }
                    }
                    .accessibilityAction(named: "Edit without keyboard", isEnabled: withActionRequest) {
                        if let onActionRequest {
                            onActionRequest(.pad)
                        }
                    }
                    .safeAreaPadding()
                    .onAppear {
                        syncTextFromValue()
                        isFocused = true
                    }
                    .onChange(of: text) {
                        syncValueFromText()
                    }
                    .onChange(of: isFocused) {
                        
                        if isFocused { // select text on appear
                            
                            selection = TextSelection(range: text.startIndex..<text.endIndex)
                            
                        } else { // synchronise and close
                            
                            syncValueFromText()
                            //activeInputMethod = nil
                        }
                        
                    }
                Spacer()
            }
        }
    }
    
    // MARK: - Actions
        
    private func syncValueFromText() {
        
        /// When tested, NumberFormatter rounding did not work as expected,
        /// so we do the rounding here...
        
        guard let number = formatter.number(from: text)?.doubleValue else { value = nil; return }
        let integral = number.rounded(.toNearestOrAwayFromZero)
        
        let integer = Int(truncating: integral as NSNumber)

        value = integer
    }
    
    private func syncTextFromValue() {
        text = formatter.string(from: NSNumber(value: value ?? 0)) ?? ""
    }
    
    // MARK: Accessibility

    private func incrementValue() {
        guard let value else { return }
        self.value = value + 1
        syncTextFromValue()
    }
    
    private func decrementValue() {
        guard let value, value > 0 else { return }
        self.value = value - 1
        syncTextFromValue()
    }

    
}

#Preview("Numeric Keyboard View") {
    
    @Previewable @State var value: Int? = 42

    NavigationStack {
        ZStack {
            Color.init(uiColor: UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            NumericKeyboardView(value: $value)
        }
    }

}

#endif
