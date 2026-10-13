//
//  DigitPadView.swift
//  NumberPicker
//
//  Created by David Kennedy on 18/06/2026.
//

#if os(iOS)

import SwiftUI

public struct DigitPadView: View {
    
    // MARK: - Constants
    
    private let maxDigits = String(Int.max).count - 1
    
    // MARK: - State

    @State private var isConstrained = false
    
    @State private var firstKeypress: Bool = true
    @State private var digits: [Int] = []
    @State private var isNegative: Bool = false
    
    private var withActionRequest = false
    private var onActionRequest: ((NumberPicker.ActionRequest)->Void)?
        
    private var digitString: String {
        var string = digits.map(String.init).joined()
        if isNegative { string.insert("-", at: string.startIndex) }
        return string
    }
    
    /// When there are no digits, we use a Zero Width Space (U+200B) instead of an emptystring, so that the text height is maintaned.
    private var textValue: String {
        digits.isEmpty ? "\u{200B}" : digitString
    }
    
    private var accessibilityValue: String {
        digits.isEmpty ? "empty" : digitString
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
        GeometryReader { proxy in
            
            let size = proxy.size
            
            HStack {
                VStack {
                    inputField
                    numberPad
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                updateProxyChange(proxy)
            }
            .onChange(of: size) {
                updateProxyChange(proxy)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .onAppear {
            syncDigitsFromWorkingValue()
        }
        .onChange(of: value) {
            syncDigitsFromWorkingValue()
        }
    }
        
    // MARK: Input Field
    
    private var inputField: some View {
                
        VStack {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .onTapGesture {
                        if let onActionRequest {
                            onActionRequest(.keyboard)
                        }
                    }
                HStack {
                    Spacer()
                    tokenView(textValue)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 10)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
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
        .accessibilityAction(named: "Edit with keyboard", isEnabled: withActionRequest) {
            if let onActionRequest {
                onActionRequest(.keyboard)
            }
        }
    }
        
    private func tokenView(_ text: String) -> some View {
        Text(text)
            .font(.default).monospacedDigit()
            .dynamicTypeSize(...DynamicTypeSize.accessibility4)
            .foregroundStyle(.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.accentColor.opacity(0.15))
            )
    }
    
    // MARK: Number Pad
    
    private var numberPad: some View {
        let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 5), count: 3)
        return LazyVGrid(columns: columns, spacing: isConstrained ? 2 : 3) {
            ForEach(1...9, id: \.self) { n in
                numberButton(n)
            }
            emptyCell()
            numberButton(0)
            deleteButton()
        }
    }

    private func numberButton(_ n: Int) -> some View {
        Button {
            if firstKeypress {
                replaceAllDigits(with: n)
            } else {
                appendDigit(n)
            }
            announceCurrentValue()
        } label: {
            Text("\(n)")
                .font(.system(size: 28)).monospacedDigit()
                .fixedSize()
                .padding(.vertical, isConstrained ? -8 : 0)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color(.systemBackground))
        .foregroundStyle(Color(.label))
        .accessibilityLabel("\(n)")
        .accessibilityAddTraits([.isKeyboardKey])
        .accessibilityInputLabels(["\(n)"])
    }
    
    private func deleteButton() -> some View {
        Button {
            if firstKeypress {
                deleteAllDigits()
            } else {
                deleteDigit()
            }
            announceCurrentValue()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 28))
                .padding(.vertical, isConstrained ? 1 : 4)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete")
        .accessibilityAddTraits([.isKeyboardKey])
        .accessibilityInputLabels(["Delete"])
    }
    
    private func emptyCell() -> some View {
        Color.clear
    }
    
    // MARK: - Actions
    
    private func updateProxyChange(_ proxy: GeometryProxy) {
        if UIDevice.current.userInterfaceIdiom != .phone { return }
        isConstrained = (proxy.ratio == 2)
    }

    // MARK: Synchronising Values
    
    /// Sync the `digits` array with the individual digits from `workingValue`.
    ///
    /// Examples:
    ///
    /// | `value`  | `digits`    |
    /// |-----------|--------------|
    /// | `0`           | `[0]`           |
    /// | `1`           | `[1]`           |
    /// | `123`       | `[1,2,3]`  |
    /// | {`nil`}    | `[]`             |
    ///
    private func syncDigitsFromWorkingValue() {
        guard let value else { digits.removeAll(); isNegative = false; return }
        
        let signum = value.signum()
        isNegative = (signum == -1) ? true : false

        let stringValue = String(value)
        digits = stringValue.compactMap { $0.wholeNumberValue }
    }

    /// Sync `value` with the value represented by the `digits` array.
    ///
    /// Examples:
    ///
    /// | `digits`  | `value`  |
    /// |------------|---------------------|
    /// | `[0]`         | `0`                          |
    /// | `[1]`         | `1`                          |
    /// |`[1,2,3]` | `123`                      |
    /// | `[]`           |  {`nil`}                  |
    ///
    private func syncWorkingValueFromDigits() {
        guard !digits.isEmpty else { value = nil; isNegative = false; return }
        var updatedValue = digits.reduce(0) { $0 * 10 + $1 }
        if isNegative {
            updatedValue = -updatedValue
        }
                
        if value != updatedValue {
            value = updatedValue
        }
    }

    // MARK: First Keypress
    
    private func replaceAllDigits(with n: Int) {
        guard firstKeypress else { return }
        digits = [n]
        isNegative = false
        syncWorkingValueFromDigits()
        firstKeypress = false
    }

    private func deleteAllDigits() {
        guard firstKeypress else { return }
        digits.removeAll()
        isNegative = false
        syncWorkingValueFromDigits()
        firstKeypress = false
    }

    // MARK: Subsequent Keypresses

    private func appendDigit(_ n: Int) {
        guard !firstKeypress else { return }
        if digits.count < maxDigits {
            digits.append(n)
            syncWorkingValueFromDigits()
            firstKeypress = false
        }
    }
    
    private func deleteDigit() {
        guard !firstKeypress else { return }
        if !digits.isEmpty {
            digits.removeLast()
            syncWorkingValueFromDigits()
            firstKeypress = false
        }
    }
    
    // MARK: Accessibility

    private func announceCurrentValue() {
        // Post an announcement so VoiceOver reads the updated value after an action
        var announcement = AttributedString("\(accessibilityValue)")
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
    }
    
    private func incrementValue() {
        guard value != nil else { return }
        self.value = value! + 1
        syncDigitsFromWorkingValue()
    }
    
    private func decrementValue() {
        guard value != nil else { return }
        self.value = value! - 1
        syncDigitsFromWorkingValue()
    }
    
}

#Preview("Digit Pad View") {
    
    @Previewable @State var value: Int? = 42

    ZStack {
        Color.init(uiColor: UIColor.secondarySystemBackground)
            .ignoresSafeArea()
        DigitPadView(value: $value)
    }
    
}

#endif
