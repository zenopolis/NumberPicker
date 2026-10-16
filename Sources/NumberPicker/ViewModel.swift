//
//  ViewModel.swift
//  NumberPicker
//
//  Created by David Kennedy on 09/10/2026.
//

#if os(iOS)

import Foundation

@MainActor @Observable public class ViewModel: @unchecked Sendable {
    
    var isActive: Bool = false
    
    var entryMethod: NumberPicker.EntryMethod? = nil {
        didSet {
            isActive = (entryMethod != nil)
            guard let entryMethod else { return }
            UserDefaults.standard.numberPickerEntryMethod = entryMethod
        }
    }
    
}

#endif
