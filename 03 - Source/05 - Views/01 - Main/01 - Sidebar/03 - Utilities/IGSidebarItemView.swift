//
//  IGSidebarItemView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI

struct IGSidebarItem: View {
    let title: String
    let systemImage: String
    let badgeCount: Int
    let progress: Double?
    
    init(
        _ title: String,
        systemImage: String,
        count: Int,
        progress: Double? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.badgeCount = count
        self.progress = progress
    }
    
    var body: some View {
        Label {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                    .font(.body)
                
                Spacer()
                
                if let progress {
                    ProgressView(value: progress)
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                } else {
                    Text("\(badgeCount)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        } icon: {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .frame(width: 18)
                .padding(.trailing, 2)
                .foregroundStyle(.primary)
        }
        .labelStyle(.titleAndIcon)
    }
}

#Preview {
    List {
        IGSidebarItem("Phrases", systemImage: "text.quote", count: 128)
        IGSidebarItem("Render Queue", systemImage: "paintbrush.pointed", count: 8, progress: 0.42)
        IGSidebarItem("Uploads", systemImage: "arrow.up.doc", count: 3)
    }
    .listStyle(.sidebar)
    .frame(width: 250)
    .padding()
}
