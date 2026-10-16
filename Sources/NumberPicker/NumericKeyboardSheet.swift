//
//  NumericKeyboardSheet.swift
//  NumberPicker
//
//  Created by David Kennedy on 21/08/2026.
//

#if os(iOS)

import SwiftUI

struct NumericKeyboardSheet: View {
        
    // MARK: - State
    
    private static var dismissMethod: NumberPicker.DismissalMethod = .other

    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isFocused: Bool
    
    @State private var text: String = ""
    @State private var selection: TextSelection?
    
    private var withBackButton = false
    private var onDismiss: ((NumberPicker.DismissalMethod)->Void)?

    // MARK: - Parameters
    
    var title: LocalizedStringKey
    @Binding var value: Int?
    @Binding var activeInputMethod: NumberPicker.EntryMethod?
    
    // MARK: - Lifecycle
    
    init(title: LocalizedStringKey, value: Binding<Int?>, onDismiss: ((NumberPicker.DismissalMethod)->Void)?) {
        self._activeInputMethod = .constant(nil)
        self.title = title
        self._value = value
        self.onDismiss = onDismiss
        withBackButton = true
        Self.dismissMethod = .other
    }
    
    init(_ activeInputMethod: Binding<NumberPicker.EntryMethod?> = .constant(nil), title: LocalizedStringKey, value: Binding<Int?>) {
        self.title = title
        self._value = value
        self._activeInputMethod = activeInputMethod
        withBackButton = false
    }

    // MARK: - View

    var body: some View {
        NavigationStack {
            NumericKeyboard(value: $value) { action in
                if action == .pad {
                    requestDigitPad()
                }
            }
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(150)])
            .presentationCompactAdaptation(.none)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if withBackButton {
                        Button("", systemImage: "chevron.backward") {
                            Self.dismissMethod = .backButton
                            dismiss()
                        }
                    }
                }
                ToolbarItem {
                    Button("", systemImage: "keyboard.chevron.compact.down") {
                        requestDigitPad()
                    }
                    .accessibilityLabel("Dismiss keyboard")
                }
                ToolbarItem {
                    Button(role: .close) {
                        Self.dismissMethod = .closeButton
                        dismiss()
                    }
                    .accessibilityLabel("Done")
                }
            }
            .onDisappear {
                if let onDismiss {
                    onDismiss(Self.dismissMethod)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func requestDigitPad() {
        if onDismiss != nil {
            
            let inputMethod = NumberPicker.EntryMethod.pad
            UserDefaults.standard.numberPickerEntryMethod = inputMethod

            Self.dismissMethod = .requestDigitPad
            dismiss()

        } else {
            activeInputMethod = .pad
        }
    }
    
}

#Preview("Numeric Keyboard Sheet") {
    
    @Previewable @State var presentSheet = true
    @Previewable @State var value: Int? = 42

    Button {
        presentSheet.toggle()
    } label: {
        Text("Open Numeric Keyboard")
    }
    .buttonStyle(.bordered)
    .sheet(isPresented: $presentSheet) {
        NavigationStack {
            NumericKeyboardSheet(title: "Numeric Keyboard", value: $value)
        }
    }
    
}

#endif
