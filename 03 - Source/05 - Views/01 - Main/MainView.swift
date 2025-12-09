//
//  ContentView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-21.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct MainView: View {
    
    // MARK: - Environment & Bindings

    @Environment(IGAppModel.self) private var app
    //@Environment(IHAppSettings.self) private var settings
    
    // MARK: - Body

    var body: some View {
        @Bindable var app = app
        NavigationSplitView {
            IGSidebar()
        } content: {
            Text("Content View")
            //IHContentView()
        } detail: {
            Text("Detail View")
            //IHDetailView()
        }
        .sheet(item: $app.activeSheet) { sheet in
            sheet.view
        }
        .alert(
            isPresented: .constant(app.appError != nil),
            error: app.appError,
        ) { _ in
            Button("OK", role: .close) { app.appError = nil}
        } message: { error in
            Text(error.errorMessage ?? "")
        }
        .confirmationDialog(
            app.confirmationContent.title,
            isPresented: $app.isShowingConfirmation,
            titleVisibility: app.confirmationContent.titleVisibility,
            actions: { app.confirmationContent.actions },
            message: { app.confirmationContent.message }
        )
        /*
        .fileImporter(
            isPresented: $app.locationImportInProgress,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else {
                    app.onLocationImportFailure?()
                    return
                }

                if folder.startAccessingSecurityScopedResource() {
                    defer { folder.stopAccessingSecurityScopedResource() }
                    settings.location = settings.location.withFolderURL(folder)
                    settings.saveLocation()
                    app.onLocationImportSuccess?(folder)
                } else {
                    print("⚠️ Could not access folder")
                    app.onLocationImportFailure?()
                }

            case .failure(let error):
                print("⚠️ Failed to pick folder:", error)
                app.onLocationImportFailure?()
            }

            app.onLocationImportSuccess = nil
            app.onLocationImportFailure = nil
        }
         */
    }
      
}
 
#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    MainView()
        .environment(app)
}
