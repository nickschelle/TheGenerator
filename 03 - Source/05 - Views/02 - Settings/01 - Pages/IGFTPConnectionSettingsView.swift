//
//  IGFTPConnectionSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-07.
//

import SwiftUI

struct IGFTPConnectionSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGFTPConfig = .load()
    
    var body: some View {
        Group {
            Section("FTP Connection") {
                TextField("Host", text: $tempConfig.host)
                    .textFieldStyle(.roundedBorder)
                TextField("Port", value: $tempConfig.port, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                Toggle("Use TLS", isOn: $tempConfig.useTLS)
                    .toggleStyle(.switch)
                TextField("Remote Path", text: $tempConfig.remoteBasePath)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tempConfig.remoteBasePath) { _, newValue in
                        if !newValue.isEmpty && !newValue.hasPrefix("/") {
                            tempConfig.remoteBasePath = "/" + newValue
                        }
                    }
            }
        }
        .onAppear{
            tempConfig = settings.ftp
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    settings.ftp = tempConfig
                    settings.saveFTP()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    @Previewable @State var settings: IGAppSettings = .init()
    Form {
        IGFTPConnectionSettings()
            .environment(app)
            .environment(settings)
    }
    .formStyle(.grouped)
}
