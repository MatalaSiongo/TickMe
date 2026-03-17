//
//  InboxView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        VStack(spacing: 14) {
            // Replace this with your existing task list UI + logic
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .frame(height: 140)
                .overlay(
                    VStack(alignment: .leading, spacing: 10) {
                        Text("• Sample Task")
                            .foregroundStyle(.white)
                        Text("5 Dec, 10:00")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    .padding()
                    , alignment: .topLeading
                )
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 12)
    }
}
