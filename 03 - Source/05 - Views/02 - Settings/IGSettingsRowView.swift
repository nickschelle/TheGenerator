//
//  IGSettingsRowView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-14.
//

import SwiftUI

struct IGSettingsRowView<Secondary: View>: View {

    private let title: String
    private let systemName: String
    private let color: Color
    private let secondary: () -> Secondary
    private let action: (() -> Void)?

    // MARK: - Initializers

    init(
        _ title: String,
        systemName: String,
        color: Color,
        @ViewBuilder secondary: @escaping () -> Secondary,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemName = systemName
        self.color = color
        self.action = action
        self.secondary = secondary
    }

    init(
        _ title: String,
        subtitle: String,
        systemName: String,
        color: Color,
        action: (() -> Void)? = nil
    ) where Secondary == Text {
        self.title = title
        self.systemName = systemName
        self.color = color
        self.action = action
        self.secondary = {
            Text(subtitle)
        }
    }
    
    var body: some View {
        if let action {
            IGRowButton(action: action) {
                row
            }
            .buttonStyle(.plain)
            
        } else {
            row
        }
    }
    
    private var row: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {

                Image(systemName: systemName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 16, alignment: .center)
                    .foregroundStyle(.white)
                    .padding(10)
                    .glassEffect(.clear.tint(color.opacity(0.3)), in: RoundedRectangle(cornerRadius: 8, style: .continuous) )
            }
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .padding(.top, 1)
                    secondary()
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    
                }
                Spacer()
            }
        }
    }
}

#Preview {
    IGSettingsRowView("Cool Dude", subtitle: "Things I go to the store to buy", systemName: "trash", color: .red, action: nil)
        .padding(40)
}
