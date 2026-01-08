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
                    let designConfig = settings.designConfig(for: key)
                    IGSettingsRowView(
                        key.displayName,
                        subtitle: "\(designConfig.displayActiveThemeCount(for:  key.design)) Themes at \(designConfig.displaySize)",
                        systemName: "rectangle.3.group.fill",
                        color: .accentColor,
                        action: { selectedSetting = .design(key) }
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
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()

    IGSettingsView()
        .environment(app)
        .environment(settings)
}

enum selectedSettings: Identifiable {
    case design(IGDesignKey), metadata, tags, ftpConnection, ftpSignIn
    
    var id: String {
        switch self {
        case .design(let key): "design: \(key.rawValue)"
        case .metadata: "metadata"
        case .tags: "tags"
        case .ftpConnection: "ftpConnection"
        case .ftpSignIn: "ftpSignIn"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .design(let key): IGDesignSettings(key)
        case .metadata: IGMetadataSettings()
        case .tags: IGDefaultTagSettings()
        case .ftpConnection: IGFTPConnectionSettings()
        case .ftpSignIn: IGFTPSignInSettings()
        }
    }
}
