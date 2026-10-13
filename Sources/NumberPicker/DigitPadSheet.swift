//
//  DigitPadSheet.swift
//  NumberPicker
//
//  Created by David Kennedy on 18/06/2026.
//

#if os(iOS)

import SwiftUI

public struct DigitPadSheet: View {
        
    // MARK: - State

    private static var dismissMethod: NumberPicker.DismissalMethod = .other

    @Environment(\.dismiss) private var dismiss

    @State private var isConstrained = false
    
    private var withBackButton = false
    private var onDismiss: ((NumberPicker.DismissalMethod)->Void)?
    
    // MARK: - Parameters
    
    var title: LocalizedStringKey
    @Binding var value: Int?
    @Binding var activeInputMethod: NumberPicker.InputMethod?
    
    // MARK: - Lifecycle
    
    public init(title: LocalizedStringKey, value: Binding<Int?>, onDismiss: ((NumberPicker.DismissalMethod)->Void)?) {
        self._activeInputMethod = .constant(nil)
        self.title = title
        self._value = value
        self.onDismiss = onDismiss
        self.withBackButton = true
        Self.dismissMethod = .other
    }
    
    init(_ activeInputMethod: Binding<NumberPicker.InputMethod?> = .constant(nil), title: LocalizedStringKey, value: Binding<Int?>) {
        self._activeInputMethod = activeInputMethod
        self.title = title
        self._value = value
        self.withBackButton = false
    }
    
    // MARK: - View
        
    @ScaledMetric(relativeTo: .body) private var extraHeight = 21

    public var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                
                let size = proxy.size
                
                DigitPadView(value: $value) { action in
                    if action == .keyboard {
                        requestKeyboard()
                    }
                }
                .onAppear {
                    updateProxyChange(proxy)
                }
                .onChange(of: size) {
                    updateProxyChange(proxy)
                }
            }
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.height(isConstrained ? 276 + extraHeight : 319 + extraHeight)])
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
                    Button("", systemImage: "keyboard") {
                        requestKeyboard()
                    }
                    .accessibilityLabel("Show keyboard")
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

    private func updateProxyChange(_ proxy: GeometryProxy) {
        if UIDevice.current.userInterfaceIdiom != .phone { return }
        isConstrained = (proxy.ratio == 2)
    }
    
    private func requestKeyboard() {
        if onDismiss != nil {

            let inputMethod = NumberPicker.InputMethod.keyboard
            UserDefaults.standard.numberPickerInputMethod = inputMethod
            
            Self.dismissMethod = .requestKeyboard
            dismiss()
            
        } else {
            activeInputMethod = .keyboard
        }
    }
    
}

#Preview("Digit Pad Sheet") {
    
    @Previewable @State var presentSheet = true
    @Previewable @State var value: Int? = 42

    Button {
        presentSheet.toggle()
    } label: {
        Text("Open Digit Pad")
    }
    .buttonStyle(.bordered)
    .sheet(isPresented: $presentSheet) {
        NavigationStack {
            DigitPadSheet(title: "Digit Pad", value: $value)
        }
    }

}

#endif
