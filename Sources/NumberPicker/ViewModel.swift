//
//  ViewModel.swift
//  NumberPicker
//
//  Created by David Kennedy on 09/10/2026.
//

import Foundation

@MainActor @Observable public class ViewModel: @unchecked Sendable {
    
    var isActive: Bool = false
    
    var inputMethod: NumberPicker.InputMethod? = nil {
        didSet {
            isActive = (inputMethod != nil)
            guard let inputMethod else { return }
            UserDefaults.standard.numberPickerInputMethod = inputMethod
        }
    }
    
}
