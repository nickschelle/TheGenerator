//
//  IGImagePreviewView.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-23.
//


import SwiftUI

struct IGImagePreview: View {

    /// Already-loaded image from IHLoadedPNG
    let image: NSImage?

    /// Optional error message from the loader
    let error: String?

    var body: some View {
        Group {
            if let error {
                Text(error)
                    .foregroundStyle(.red)
                    .padding()

            } else if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()

            } else {
                ProgressView()
            }
        }
    }
}
