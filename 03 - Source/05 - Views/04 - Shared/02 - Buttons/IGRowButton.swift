//
//  IGRowButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-19.
//

import SwiftUI

struct IGRowButton<Content: View>: View {

    // MARK: - Stored Properties

    let action: (() -> Void)?
    @ViewBuilder let content: () -> Content

    // MARK: - Body

    @ViewBuilder
    var body: some View {
        if let action {
            Button(action: action) {
                HStack {
                    content()
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                        .font(.footnote.weight(.semibold))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
        } else {
            content()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        IGRowButton(action: { }) {
            Text("With action")
        }

        IGRowButton(action: nil) {
            Text("Static (no action)")
        }
    }
    .padding()
    .frame(width: 260)
}
