//
//  DeviceManagementView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI

struct DeviceManagementView: View {
    var body: some View {
        List {
            Section("This Device") {
                infoRow("Device Name", UIDevice.current.name)
                infoRow("Model", UIDevice.current.model)
                infoRow("System", "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)")
            }
        }
        .navigationTitle("Device Management")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
    }
}
