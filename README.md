# NumberPicker

<div align="center">
  
![version](https://img.shields.io/badge/version-0.2.1_beta-green) 
![package manager, swift PM](https://img.shields.io/badge/package_manager-Swift_PM-green)
![Apple Platforms, iOS 26+](https://img.shields.io/badge/Platforms-iOS_26+%20-blue.svg?style=flat&logo=apple&logoColor=white)
![swift 5](https://img.shields.io/badge/swift-5-blue)
![license MIT](https://img.shields.io/badge/license-MIT-lightgrey)

</div>

__NumberPicker__ provides an accessibility-compatible SwiftUI control that lets the user enter a numeric value using either a keypad or the system keyboard.

The number picker will remember the user’s preferred entry method between uses.

__Usage:__ A Stepper control is usually chosen for small, limited adjustments, but it is less suitable for values that may change by large or arbitrary amounts. NumberPicker can assist here, either alongside a Stepper or as a substitute when the user needs more free range over their input.

![Three screenshots showing the number picker in action. The first image shows the keypad entry. The second image shows numeric keyboard entry. The third image shows the keypad entry with Voice Control labels.](https://github.com/user-attachments/assets/d2dfaef7-70f4-4bae-91f9-9961ffeec2cf)

## Content

1. [Accessibility Support](#accessibility-support)
2. [Requirements](#requirements)
    - [Current Limitations](#current-limitations)
3. [Installation](#installation)
    - [Swift Package Manager](#swift-package-manager)
    - [Manually](#manually)
4. [Usage Examples](#usage-examples)
    - [NumberPicker](#numberpicker-example)
    - [DigitPad and NumericKeyboard Views](#digitpad-and-numerickeyboard-views)
    - [Number Picker Default](#number-picker-default)
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

This version of the number picker is designed to work with positive integer values only. 

## Installation

### Swift Package Manager

You can use the [Swift Package Manager](https://docs.swift.org/latest/documentation/packagemanagerdocs/) to install `NumberPicker` by adding it to your `Package.swift` file:

```swift

import PackageDescription

let package = Package(
    name: "NumberPicker",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/zenopolis/NumberPicker", from: "0.2.1"),
    ]
)
```

### Manually

To manually add this library to your project, drag the `Sources` folder into the project tree.

## Usage examples

### <a id="numberpicker-example"></a>NumberPicker

Using the number picker to get an integer value. 

The following code displays a button – that when pressed – shows the number picker with the user’s preferred entry method.

``` swift

import SwiftUI
import NumberPicker

struct NumberPickerExample: View {
        
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
    
}
```

---

### DigitPad and NumericKeyboard Views

You can also access the views presented by the number picker directly. 

The following example directly accesses the `DigitPad` view.

``` swift

import SwiftUI
import NumberPicker

struct DigitPadExample: View {
    
    @Binding var value: Int
    @State var newValue: Int? =  nil

    var body: some View {
        DigitPad(value: $newValue)
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

To use the `NumericKeyboard` view, replace `DigitPad(value: $newValue)` in the example with `NumericKeyboard(value: $newValue)`.

---

### Number Picker Default

`NumberPicker` stores the entry method, either `.pad` or `.keyboard`, the user last used when they invoked the number picker. When they next use the picker, the same entry method is presented. 
The entry method value is stored in user defaults and can be accessed via the `entryMethod` static propery.

```swift

// Read default
let entryMethod = NumberPicker.entryMethod

// Set default
NumberPicker.entryMethod = .pad
```

## Author

__NumberPicker__ was created by [David Kennedy](https://zenopolis.com/contact/).

## License

__NumberPicker__ is available under the MIT license. See the LICENSE file for more info.
