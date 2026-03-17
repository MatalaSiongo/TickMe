//
//  AvatarView.swift
//  Tickme2
//
//  Created by Matala on 2025-12-19.
//

import SwiftUI
import PhotosUI

struct AvatarView: View {
    @Binding var profileItem: PhotosPickerItem?
    @Binding var profileImageData: Data?

    var body: some View {
        VStack(spacing: 18) {
            Group {
                if let data = profileImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable().scaledToFit()
                        .foregroundStyle(.gray.opacity(0.7))
                        .padding(30)
                }
            }
            .frame(width: 160, height: 160)
            .clipShape(Circle())

            PhotosPicker(selection: $profileItem, matching: .images) {
                Text("Choose Photo")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.headerGreen)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            if profileImageData != nil {
                Button(role: .destructive) { profileImageData = nil } label: {
                    Text("Remove Photo")
                }
            }

            Spacer()
        }
        .padding(.top, 30)
        .navigationTitle("Profile Picture")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: profileItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }
}
