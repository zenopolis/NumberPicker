# NumberPicker

<div align="center">
  
![version](https://img.shields.io/badge/version-0.1.0_alpha-green) 
![package manager, swift PM](https://img.shields.io/badge/package_manager-Swift_PM-green)
![Apple Platforms, iOS 26+](https://img.shields.io/badge/Platforms-iOS_26+%20-blue.svg?style=flat&logo=apple&logoColor=white)
![swift 5](https://img.shields.io/badge/swift-5-blue)
![license MIT](https://img.shields.io/badge/license-MIT-lightgrey)

</div>

__NumberPicker__ provides an accessibility-compatible number picker for SwiftUI. The user can pick between two views: a number pad and a system numeric keyboard with a text field. NumberPicker will return to the last view the user chose when they invoke the picker again.  


![Three screenshots showing NumberPicker in action. The first image shows the number pad and the accessible input field. The second image shows the keyboard view. The third image shows the number pad with Voice Control.](https://github.com/user-attachments/assets/c9faae3b-152a-40f7-8c1a-19e92a73b160)

## Content

1. [Accessibility Support](#accessibility-support)
2. [Requirements](#requirements)
    - [Current Limitations](#current-limitations)
3. [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Manually](#manually)
4. [Usage Examples](#usage-examples)
    - [From a Main Screen](#from-a-main-screen)
    - [From a Sheet](#from-a-sheet)
    - [Direct Access to Views](#direct-access-to-views)
5. [Author](#author)
6. [License](#license)

## Accessibility Support

 * VoiceOver
 * Voice Control
 * Larger Text
 * Dark Interface
 * Differentiate Without Color Alone
 * Sufficient Contrast
 * Reduced Motion

> __Note__: May not be suitable for Assistive Access.

## Requirements

- iOS 26+
- Swift 5+

### Current Limitations

This version of NumberPicker is designed to work with positive integer values only. 

## Installation

### Swift Package Manager

You can use the [Swift Package Manager](https://docs.swift.org/latest/documentation/packagemanagerdocs/) to install `NumberPicker` by adding it to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "NumberPicker",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/zenopolis/NumberPicker", from: "0.1.0"),
    ]
)
```

### Manually

To manually add this library to your project, drag the `Sources` folder into the project tree.

## Usage examples

### From a Main Screen

Use the number picker to get an integer value. The folowing code displays a button - that when pressed - shows the users prefered number picker as a sheet.

``` swift
import SwiftUI
import NumberPicker

struct ContentView: View {
        
    @Binding var value: Int
    @State var newValue: Int? =  nil
        
    var body: some View {
        VStack {
            Spacer()
            Text("[\(value)]")
                .font(.largeTitle.bold())
            Spacer()
            NumberPicker(title: "Change Value", value: $newValue) {
                Text("Open Keypad")
            }
            Spacer()
        }
        .onAppear {
            newValue = value
        }
        .onChange(of: newValue) {
            if let newValue {
                value = newValue
            }
        }
        Spacer()
    }
    
}
```

You can use the `.onChange(of:)` callback to validate the value returned by the number picker.

---

### From a Sheet

[You should close one Sheet before displaying another](https://developer.apple.com/design/human-interface-guidelines/sheets). To help with this, the two number picker views can be invoked independently as sheets. 

When you use this approach, you have to manage the presentation state yourself.

__Note__: Using this approach adds a back button to the NumberPicker views. When the back button is tapped, it is a signal to you that the original (calling) sheet should be re-opened.

``` swift
import SwiftUI
import NumberPicker

struct ContentView: View {
    
    @Binding var value: Int
    @State var newValue: Int? =  nil

    enum PresentedSheet: String, Identifiable {
        case configurationView, digitPad, keyboardView
        var id: String { rawValue }
    }
    
    @State var presentedSheet: PresentedSheet?
    
    var body: some View {
        VStack {
            Spacer()
            Text("[\(value)]")
                .font(.largeTitle.bold())
            Spacer()
            Button {
                presentedSheet = .configurationView
            } label: {
                Text("Open Sheet")
            }
            Spacer()
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .configurationView:
                ConfigurationView(value: $value, newValue: $newValue, presentedSheet: $presentedSheet)
            case .digitPad:
                DigitPadSheet(title: "Change Value", value: $newValue) { dismissalMethod in
                    onNumberPickerDismissal(method: dismissalMethod)
                }
            case .keyboardView:
                NumericKeyboardSheet(title: "Change Value", value: $newValue) { dismissalMethod in
                    onNumberPickerDismissal(method: dismissalMethod)
                }
            }
        }
    }
    
    func onNumberPickerDismissal(method: NumberPicker.DismissalMethod) {
        switch method {
        case .closeButton, .other:
            updateValue()
            presentedSheet = nil
        case .backButton:
            updateValue()
            presentedSheet = .configurationView
        case .requestDigitPad:
            presentedSheet = .digitPad
        case .requestKeyboard:
            presentedSheet = .keyboardView
        }
    }
    
    func updateValue() {
        if let newValue {
            value = newValue
        }
    }
    
}
```

Here is the associated sheet that uses the number picker:

``` swift
struct ConfigurationView: View {
    
    @Binding var value: Int
    @Binding var newValue: Int?

    @Binding var presentedSheet: SheetExampleView.PresentedSheet?

    var body: some View {
        NavigationStack {
            HStack {
                Text("Value ")
                Button {
                    newValue = value
                    let inputMethod = NumberPicker.requestedInputMethod
                    switch inputMethod {
                    case .pad:
                        presentedSheet = .digitPad
                    case .keyboard:
                        presentedSheet = .keyboardView
                    }
                } label: {
                    Text("\(value)")
                }
            }
            .font(.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) {
                        presentedSheet = nil
                    }
                }
            }
        }
    }
    
}
```

### Direct Access to Views

You can also access the number picker views - without sheets - directly.

``` swift
import SwiftUI
import NumberPicker

struct ConfigurationView: View {
    
    @Binding var value: Int
    @State var newValue: Int? =  nil

    var body: some View {
        DigitPadView(value: $newValue)
        .onAppear {
            newValue = value
        }
        .onChange(of: newValue) {
            if let newValue {
                value = newValue
            }
        }
    }
    
}

```

To use the numeric keyboard view, replace `DigitPadView(value: $newValue)` with `NumericKeyboardView(value: $newValue)`.

## Author
__NumberPicker__ was created by [David Kennedy](https://zenopolis.com/contact/).

## License
__NumberPicker__ is available under the MIT license. See the LICENSE file for more info.
