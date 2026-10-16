//
//  UserDefaults+Extensions.swift
//  NumberPicker
//
//  Created by David Kennedy on 07/10/2026.
//

#if os(iOS)

import Foundation

// MARK: - Defaults Key Constants

struct DefaultsKey {
    static let numberPickerEntryMethod = "NumberPickerEntryMethod"
}

// MARK: - Properties

extension UserDefaults {
    
    /// [User Defaults - CA92.1: Access info from same app, per documentation](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)

    var numberPickerEntryMethod: NumberPicker.EntryMethod {
        get {
            let string = string(forKey: DefaultsKey.numberPickerEntryMethod) ?? ""
            return NumberPicker.EntryMethod(rawValue: string) ?? NumberPicker.EntryMethod.pad
        }
        set {
            let rawValue = newValue.rawValue
            set(rawValue, forKey: DefaultsKey.numberPickerEntryMethod)
        }
    }
    
}

#endif
