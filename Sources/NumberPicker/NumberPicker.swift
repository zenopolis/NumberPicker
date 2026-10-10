//
//  NumberPicker.swift
//  NumberPicker
//
//  Created by David Kennedy on 09/10/2026.
//

import SwiftUI

public struct NumberPicker: View {
    
    // MARK: - Enumerations
    
    public enum InputMethod: String, Identifiable, Sendable, RawRepresentable {
        case pad, keyboard
        public var id: Int { hashValue }
    }

    public enum DismissalMethod: String, Identifiable, Sendable, RawRepresentable {
        case requestKeyboard, requestDigitPad, backButton, closeButton, other
        public var id: Int { hashValue }
    }
    
    public typealias ActionRequest = InputMethod
    
    // MARK: - Properties

    public static var requestedInputMethod: InputMethod {
        return UserDefaults.standard.numberPickerInputMethod
    }

    private var viewModel = ViewModel()
    
    private var inputMethod: InputMethod? {
        viewModel.inputMethod
    }
    
    var title: LocalizedStringKey
    @Binding var value: Int?
    var label: AnyView
    
    @State var newValue: Int?
    
    // MARK: - Lifecycle

    public init<Label: View>(title: LocalizedStringKey, value: Binding<Int?>, @ViewBuilder label: () -> Label) {
        self.title = title
        self._value = value
        self.label = AnyView(label())
    }

    // MARK: - View

    public var body: some View {
        
        @Bindable var model = viewModel

        Button {
            newValue = value
            model.inputMethod = Self.requestedInputMethod
        } label: {
            label
        }
        .sheet(isPresented: $model.isActive) {
            sheet(title: title, value: $newValue)
        }
        .onChange(of: model.isActive) {
            if !model.isActive {
                value = newValue
            }
        }
    }
    
    // MARK: View Builder
    
    @MainActor @ViewBuilder
    private func sheet(title: LocalizedStringKey, value: Binding<Int?>) -> some View {
        
        @Bindable var model = viewModel
        
        switch inputMethod {
        case .pad, .none:
            DigitPadSheet($model.inputMethod, title: title, value: value)
        case .keyboard:
            NumericKeyboardSheet($model.inputMethod, title: title, value: value)
        }
    }
    
}

#Preview("Number Picker") {
    @Previewable @State var value: Int? = 42
    NumberPicker(title: "Number Picker", value: $value) {
        Text("Open Number Picker")
    }
}
