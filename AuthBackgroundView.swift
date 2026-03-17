//
//  AuthBackgroundView.swift
//  Tickme2
//
//  Created by Matala on 2026-02-21.
//

import Foundation
import SwiftUI

struct AuthBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.45, blue: 0.40),
                Color(red: 0.10, green: 0.25, blue: 0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
