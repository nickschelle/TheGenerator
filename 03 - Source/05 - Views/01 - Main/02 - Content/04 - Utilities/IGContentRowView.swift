//
//  IGContentRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-23.
//

import SwiftUI

struct IGContentRow<Content: View>: View {

    private let title: String
    private let systemImage: String
    private let content: Content
    
    init(
        _ title: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) {
        self.content = content()
        self.systemImage = systemImage
        self.title = title
    }
    
    var body: some View {
        Label(title: {
            Text(title)
            Spacer()
            content
        }, icon: {
            Image(systemName: systemImage)
                .frame(width: 16, height: 16, alignment: .center)
        })
        .labelStyle(.titleAndIcon)
        .padding(.vertical, 4)
    }
}

#Preview {
    IGContentRow("Row Name", systemImage: "arrow.up")
        .padding()
}
