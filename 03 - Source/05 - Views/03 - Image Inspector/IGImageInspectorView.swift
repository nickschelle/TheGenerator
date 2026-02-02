//
//  IGImageInspectorView.swift
//  IHeartEverything
//

import SwiftUI

struct IGImageInspector: View {

    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    @Binding private var fileName: String?

    @State private var loaded: IGLoadedPNG? = nil
    @State private var loadError: String? = nil
    @State private var metadata: IGImageMetadata?
    @State private var backgrounColor: Color = .gray

    init(_ fileName: Binding<String?>) {
        self._fileName = fileName
    }

    // MARK: - URL Resolution

    private var folderURL: URL? {
        settings.location.resolvedURL
    }
    
    // MARK: - Body

    var body: some View {
        Group {
            if let loaded {
                // --- IMAGE PREVIEW ---
                IGImagePreview(
                    image: loaded.image,
                    error: nil
                )
                
            } else if let loadError {
                Text(loadError)
                    .foregroundStyle(.red)
                    .padding()
                
            } else {
                // --- LOADER ---
                ProgressView("Loading PNG…")
                    .task { await loadPNG() }
            }
        }
        .background(backgrounColor)
        .padding()
        .toolbar {
            ToolbarItemGroup {
                Button("Info") {
                    metadata = loaded?.metadata
                }
                ColorPicker("Background", selection: $backgrounColor)
            }
            
        }
        .sheet(item: $metadata) { metadata in
            IGImageMetadataView(metadata)
        }
    }

    // MARK: - PNG Loading

    @MainActor
    private func loadPNG() async {

        guard let fileName else {
            loadError = "Invalid or missing file URL."
            return
        }

        guard let folderURL else {
            loadError = "Missing folder URL (security scope)."
            return
        }

        do {
            loaded = try await IGImageManager.loadPNG(
                named: fileName,
                in: folderURL
            )
        } catch {
            loadError = error.localizedDescription
        }
    }
}
