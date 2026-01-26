//
//  IGQueueStatusView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-25.
//

import SwiftUI

struct IGQueueStatus: View {
    
    @Environment(IGAppModel.self) private var app
    
    private let processType: IGImageProcess
    
    init(_ processType: IGImageProcess) {
        self.processType = processType
    }
    
    private var state: IGProcessState {
        switch processType {
        case .render: app.generationState
        case .upload: app.uploadState
        }
    }
    
    private var symbol: String { state.symbol }
    
    private var description: String {
        state == .working
        ? processType.workingDescription
        : state.description
    }
    
    private var message: String? {
        switch processType {
        case .render: app.generationMessage
        case .upload: app.uploadMessage
        }
    }
    
    private var progress: Double? {
        switch processType {
        case .render: app.generationProgress
        case .upload: app.uploadProgress
        }
    }
    
    var body: some View {
        if state != .idle {
            Group {
                Divider().padding(0)
                if let progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                }
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: symbol)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(description)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(message ?? "")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    IGQueueStatus(.render)
        .frame(width: 400, height: 400)
        .environment(app)
    
}
