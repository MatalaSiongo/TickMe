//
//  EditTextView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct EditTextView: View {
    let title: String
    @Binding var value: String
    var placeholder: String
    var keyboard: UIKeyboardType = .default

    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""

    var body: some View {
        Form {
            Section {
                TextField(placeholder, text: $draft)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.words)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    value = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear { draft = value }
    }
}
