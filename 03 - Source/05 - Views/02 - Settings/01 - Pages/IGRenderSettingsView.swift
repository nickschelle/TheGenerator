//
//  IGRenderSettingsView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-28.
//
import SwiftUI

struct IGRenderSettings: View {
    
    @Environment(IGAppModel.self) private var app
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempConfig: IGRenderConfig = .load()
    
    private var customConcurency: Binding<Int> {
        Binding(
            get: { tempConfig.customConcurrency ?? 1 },
            set: { tempConfig.customConcurrency = $0 }
        )
    }
    
    var body: some View {
        Group {
            Section("Rendering") {
                Picker("Performance", selection: $tempConfig.concurrency) {
                    ForEach(IGRenderConcurrency.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .onChange(of: tempConfig.concurrency) {
                    if tempConfig.concurrency != .custom {
                        tempConfig.customConcurrency = nil
                    } else {
                        tempConfig.customConcurrency = 1
                    }
                }
                
                if tempConfig.concurrency.isCustom {
                    Stepper(
                        value: customConcurency,
                        in: 1...ProcessInfo.processInfo.activeProcessorCount,
                        step: 1
                    ) {
                        HStack {
                            Text("Render Workers")
                            Spacer()
                            Text("\(customConcurency.wrappedValue)")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear{
            tempConfig = settings.render
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", role: .confirm) {
                    settings.render = tempConfig
                    settings.saveRender()
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
