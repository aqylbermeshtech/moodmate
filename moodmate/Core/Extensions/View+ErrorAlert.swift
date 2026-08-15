//
//  View+ErrorAlert.swift
//  moodmate
//

import SwiftUI

extension View {
    /// The app's single convention for surfacing a ViewModel's
    /// `errorMessage: String?` as a dismissible alert.
    func errorAlert(_ errorMessage: Binding<String?>) -> some View {
        alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: { errorMessage.wrappedValue != nil },
                set: { if !$0 { errorMessage.wrappedValue = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage.wrappedValue ?? "")
        }
    }
}
