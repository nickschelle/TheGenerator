//
//  IGFTPSignInSettingsView.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-15.
//

import SwiftUI

struct IGFTPSignInSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGFTPConfig = .load()
    @State private var isSecure: Bool = true
    
    var body: some View {
        Section("FTP Sign-In") {
            
            TextField("Username", text: $tempConfig.username)
                .textFieldStyle(.roundedBorder)
            LabeledContent("Password") {
                HStack(alignment: .center) {
                    Group {
                        if isSecure {
                            SecureField("Password", text: $tempConfig.password)
                        } else {
                            TextField("Password", text: $tempConfig.password)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .labelsHidden()
                    
                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                    }
                    .buttonStyle(.plain)
                    .help(isSecure ? "Show Password" : "Hide Password")
                }
            }
        }
        .onAppear{
            tempConfig = settings.ftp
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    app.completeFTPLogin()
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    settings.ftp = tempConfig
                    settings.saveFTP()
                    app.completeFTPLogin(success: settings.ftp)
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
        IGFTPSignInSettings()
            .environment(app)
            .environment(settings)
    }
    .formStyle(.grouped)
}
