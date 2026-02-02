//
//  IGDesignSectionRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-31.
//

import SwiftUI

struct IGDesignSectionRow: View {
    
    enum ImageState {
        case unrendered
        case available
        case missing
    }
    
    private let title: String
    private let revision: Int
    private let imageState: ImageState
    private let onAction: () -> Void
    
    init(_ title: String, revision: Int, imageState: ImageState, onAction: @escaping () -> Void = {}) {
        self.title = title
        self.revision = revision
        self.imageState = imageState
        self.onAction = onAction
    }
    
    private var titleForground: Color {
        switch imageState {
        case .unrendered: .secondary
        default: .primary
        }
    }
    
    private var revisionForground: Color {
        switch imageState {
        case .unrendered: Color(nsColor: .tertiaryLabelColor)
        case .available: .accentColor
        case .missing: .red
        }
    }
    
    private var revisionLable: Text {
        Text(revision.spelledOutRevision)
            .foregroundStyle(revisionForground)
    }
    
    var body: some View {
        Label {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(titleForground)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                if imageState == .available {
                    Button(action: onAction) {
                        revisionLable
                    }.buttonStyle(.plain)
                } else {
                    revisionLable
                }
            }
        } icon: {
            Image(systemName: "photo")
                .imageScale(.medium)
                .frame(width: 18)
                .padding(.trailing, 2)
                .foregroundStyle(.primary)
        }
        .labelStyle(.titleAndIcon)
    }
}

#Preview {
    IGDesignSectionRow("Hi", revision: 2, imageState: .unrendered) {}
}
