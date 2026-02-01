//
//  IGDesignSectionRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-31.
//

import SwiftUI

struct IGDesignSectionRow: View {
    
    private let title: String
    private let revision: Int
    private let isNew: Bool
    
    init(_ title: String, revision: Int, isNew: Bool) {
        self.title = title
        self.revision = revision
        self.isNew = isNew
    }
    var body: some View {
        Label {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundStyle(isNew ? .secondary : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Text(revision.spelledOutRevision)
                    .foregroundStyle(isNew ? Color(nsColor: .tertiaryLabelColor) : Color.accentColor)
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
    IGDesignSectionRow("Hi", revision: 2, isNew: true)
}
