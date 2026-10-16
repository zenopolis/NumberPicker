//
//  View+Extensions.swift
//  NumberPicker
//
//  Created by David Kennedy on 09/10/2026.
//

#if os(iOS)

import SwiftUI

extension View {
    
    @ViewBuilder
    func accessibilityAction(named nameResource: LocalizedStringResource, isEnabled: Bool, _ handler: @escaping () -> Void) -> some View {
        if isEnabled {
            self.accessibilityAction(named: nameResource, handler)
        } else {
            self
        }
    }
}

#endif
