//
//  IGSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-03-06.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import LocalAuthentication

struct IGSettingsView: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    
    @State private var selectedSetting: selectedSettings?
  
    @State private var isShowingFileSelector: Bool = false
    @State private var isLocked: Bool = true

    @Query private var tags: [IGTag]
    
    init() {
        let rawScope = IGTagScope.defaults.rawValue
        _tags = Query(
            filter: #Predicate<IGTag> { $0.rawScope == rawScope },
            sort: [SortDescriptor(\.value)]
        )
    }
    private var allTags: Set<IGTag> {
        settings.presetTags.union(tags)
    }
    var body: some View {
        Form {
            Section("Designs") {
                ForEach(IGDesignKey.allCases) { key in
                    let designConfig: IGDesignConfig = key.loadConfig()
                    IGSettingsRowView(
                        key.displayName,
                        subtitle: "\(designConfig.displayActiveThemeCount(for:  key.design)) Themes at \(designConfig.displaySize)",
                        systemName: "rectangle.3.group.fill",
                        color: .accentColor,
                        action: { selectedSetting = .template }
                    )
                }
            }
            Section("Globals") {
                IGSettingsRowView(
                    "Metadata",
                    systemName: "list.bullet",
                    color: .accentColor,
                    secondary: {
                        Text("The default Metadata applied to all images")
                    },
                    action: { selectedSetting = .metadata }
                )
           
                VStack {
                    IGSettingsRowView(
                        "Tags",
                        systemName: "tag.fill",
                        color: .accentColor,
                        secondary: {
                            Text("The default tags applied to all images")
                        },
                        action: { selectedSetting = .tags }
                    )
                    IGTagList(allTags)
                }
            }
            
            Section() {
                IGSettingsRowView(
                    "Output Folder",
                    subtitle: settings.location.displayPath ?? "No folder selected",
                    systemName: "folder.fill",
                    color: .accentColor,
                    action: { isShowingFileSelector = true }
                )
            }
            Section("FTP") {
               
                IGSettingsRowView(
                    "Connection",
                    subtitle: "\(settings.ftp.host)\(settings.ftp.remoteBasePath)",
                    systemName: "network",
                    color: .accentColor,
                    action: { selectedSetting = .ftpConnection }
                )
                IGSettingsRowView(
                    "Sign-In",
                    subtitle: "Username and Password",
                    systemName: isLocked ? "lock.fill" : "lock.open.fill",
                    color: .accentColor,
                    action: {
                        if isLocked && settings.ftp.hasStoredPassword {
                            authenticate { success in
                                if success {
                                    isLocked = false
                                    selectedSetting = .ftpSignIn
                                }
                            }
                        } else {
                            selectedSetting = .ftpSignIn
                        }
                    }
                )
            }
          //  IGSettingsAdmin()
        }
        .formStyle(.grouped)
        .onAppear {
            if settings.ftp.hasStoredPassword {
                isLocked = true
            } else {
                isLocked = false
            }
        }
        .sheet(item: $selectedSetting) { item in
            Form {
                item.view
            }
            .formStyle(.grouped)
        }
        .fileImporter(
            isPresented: $isShowingFileSelector,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let folder = urls.first else { return }
                if folder.startAccessingSecurityScopedResource() {
                    defer { folder.stopAccessingSecurityScopedResource() }
                    settings.location = settings.location.withFolderURL(folder)
                    settings.saveLocation()
                }
            case .failure(let error):
                print("⚠️ Failed to pick folder:", error)
            }
        }
    }
    
    private func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Authenticate to view your FTP Sign-In") {
                success, _ in
                DispatchQueue.main.async { completion(success) }
            }
        } else {
            completion(true)
        }
    }
    
    private func eraseAllModels() {
        do {
            try app.context.delete(model: IGPhrase.self)
            try app.context.delete(model: IGGroup.self)
            try app.context.delete(model: IGRecord.self)
            try app.context.delete(model: IGTag.self)
            try app.context.delete(model: IGGroupPhraseLink.self)
            try app.context.delete(model: IGSourceTagLink.self)

            try app.context.save()
            print("🧹 Successfully erased all models.")
        } catch {
            print("⚠️ Failed to erase models:", error)
        }
        
    }
    /*
    private func resetSettingsToDefaults() {
        let settingsTags = app.context.tags(at: .defaults)
        for tag in settingsTags {
            app.context.delete(tag)
        }
        try? app.context.save()
        settings.resetSettings()
        
        print("🔄 Settings have been reset to factory defaults.")
    }
     */
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()

    IGSettingsView()
        .environment(app)
        .environment(settings)
}

enum selectedSettings: String, Identifiable {
    case template, dimensions, metadata, tags, ftpConnection, ftpSignIn
    
    var id: String { rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .template: Text("Template")//IHTemplateSettings()
        case .dimensions: Text("dimensions") //IHDimensionsSettings()
        case .metadata: IGMetadataSettings()
        case .tags: IGDefaultTagSettings()
        case .ftpConnection: IGFTPConnectionSettings()
        case .ftpSignIn: IGFTPSignInSettings()
        }
    }
}
