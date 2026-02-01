//
//  IGImageRecordThumbnailView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-06.
//


import SwiftUI

struct IGImageRecordThumbnail: View {

    private let phrase: String
    private let designKey: IGDesignKey
    private let rawTheme: String
    private let size: CGSize

    @State private var thumbnail: CGImage?
    @State private var renderTask: Task<Void, Never>?

    init(
        _ phrase: String,
        design: IGDesignKey,
        theme rawTheme: String,
        size: CGSize = CGSize(width: 300, height: 300)
    ) {
        self.phrase = phrase
        self.designKey = design
        self.rawTheme = rawTheme
        self.size = size
    }

    var body: some View {
        Group {
            if let image = thumbnail {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .task(id: renderID) {
            await renderThumbnail()
        }
    }

    // Any change here re-triggers render
    private var renderID: String {
        "\(phrase)|\(designKey.rawValue)|\(rawTheme)|\(Int(size.width))x\(Int(size.height))"
    }

    private func renderThumbnail() async {
        renderTask?.cancel()

        let design = designKey.design
        
        renderTask = Task.detached(priority: .userInitiated) {
            do {
                
                let image = try await design.renderImage(
                    of: phrase,
                    at: size,
                    with: rawTheme
                )

                await MainActor.run {
                    self.thumbnail = image
                }
            } catch {
                // Optional: log thumbnail failures
                await MainActor.run {
                    self.thumbnail = nil
                }
            }
        }

        await renderTask?.value
    }
}

#Preview {
    
    IGImageRecordThumbnail("Cool", design: IGDesignKey.iHeartPhrase, theme: "")
        .padding()
        .frame(width: 400, height: 400)
}
