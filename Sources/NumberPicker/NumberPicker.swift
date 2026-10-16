//
//  NumberPicker.swift
//  NumberPicker
//
//  Created by David Kennedy on 09/10/2026.
//

import SwiftUI

/**
 A control for the entry of a positive integer value.
 
 Use `NumberPicker` when you want to provide a view that allows the user to enter an arbitrary positive integer with a highly varied range of possible values. The view binds to an `Int?` value, returning `nil` when the user deletes or otherwise invalidates the entry.
  
The `NumberPicker` API can be imported into your SwiftUI code with the following import statement.
 
 ```swift
 import NumberPicker
 ```
 
 The following example creates a basic `NumberPicker`, which appears on iOS as a button. This example limits ???. When the user taps or clicks the button, a digit pad view animates in, from which the user can enter a value. When the user dismisses the digit pad view, the view updates the bound optional integer.
 
 ```swift
 @State var value: Int? =  nil

 var body: some View {
    NumberPicker(title: "Enter Value", value: $value) {
        Text("Open Number Picker")
    }
 }
 ```
 
 Typically, you use `NumericPicker` with an existing `Int` value, passing an `Int?` copy of this value to the number picker. This allows the returned value to be validated before accepting it.
 
 The following example uses an integer value for the title for the number picker button. It passes a copy of the value to the number picker, and validates the result when the number picker provides a new value.

```swift
 @Binding var value: Int
 @State var newValue: Int? =  nil
     
 var body: some View {
     HStack {
         Text("Value: ")
         NumberPicker(title: "Change Value", value: $newValue) {
             Text("\(value)")
         }
         .onAppear {
             // create a temporary copy of the value
             newValue = value
         }
         .onChange(of: newValue) {
             // validate the result
             if let newValue {
                 value = newValue
             }
         }
     }
 }
```
 */
public struct NumberPicker: View {
    
    // MARK: - Enumerations
    
    public enum EntryMethod: String, Identifiable, Sendable, RawRepresentable {
        case pad, keyboard
        public var id: Int { hashValue }
    }

    public enum DismissalMethod: String, Identifiable, Sendable, RawRepresentable {
        case requestKeyboard, requestDigitPad, backButton, closeButton, other
        public var id: Int { hashValue }
    }
    
    public typealias ActionRequest = EntryMethod
    
    // MARK: - Properties
    
    /**
     The last number picker entry method used by the user, one of either the Digital Pad or the Numeric Keyboard.
     
     This static property provides a direct access to the entryMethod value stored in user defaults.
     
     - Returns:
        - `.pad` if the users last used number picker entry method is the Digital Pad (_default_).
        - `.keyboard` if the users last used number picker entry method is the Numeric Keyboard.
     */
    public static var entryMethod: EntryMethod {
        get { return UserDefaults.standard.numberPickerEntryMethod }
        set { UserDefaults.standard.numberPickerEntryMethod = newValue }
    }

    private var viewModel = ViewModel()
    
    private var inputMethod: EntryMethod? {
        viewModel.entryMethod
    }
    
    var title: LocalizedStringKey
    @Binding var value: Int?
    var label: AnyView
    
    @State var newValue: Int?
    
    // MARK: - Lifecycle

    /**
     Creates an instance that allows the user to change an integer with an arbitrary value.
          
     - Parameters:
        - title: The title displayed in the number picker.
        - value: The integer value being displayed and updated. Returns `nil` if the user deletes or invalidates the number picker entry.
        - label: A view that behaves like a button and launches the number picker.
     */
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
            model.entryMethod = Self.entryMethod
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
            DigitPadSheet($model.entryMethod, title: title, value: value)
        case .keyboard:
            NumericKeyboardSheet($model.entryMethod, title: title, value: value)
        }
    }
    
}

#Preview("Number Picker") {
    @Previewable @State var value: Int? = 42
    NumberPicker(title: "Number Picker", value: $value) {
        Text("Open Number Picker")
    }
}
