//
//  IGTagView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-24.
//

import SwiftUI

struct IGTagView: View {

    @State private var isHovered: Bool = false

    let value: String
    let color: Color
    let isPreset: Bool
    let actionType: IGTagActionType?

    init(
        _ value: String,
        in color: Color = Color(nsColor: .systemFill),
        isPreset: Bool = false,
        actionType: IGTagActionType? = nil
    ) {
        self.value = value
        self.color = color
        self.isPreset = isPreset
        self.actionType = actionType
    }

    private var actionTypeHint: String {
        guard let type = actionType else {
            return isPreset ? "Auto Tag" : "Custom Tag"
        }

        switch type {
        case .add: return "Tap to add tag"
        case .remove: return "Tap to remove tag"
        case .delete: return "Tap to delete tag"
        }
    }

    var body: some View {
        Group {
            if isPreset {
                Text(value)
                    .font(.caption.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassEffect(.clear.tint(color.opacity(0.25)))
                    .padding(2)
            } else {
                ZStack {
                    Text(value)
                        .opacity(isHovered ? 0 : 1)

                    if let actionType, isHovered {
                        Image(systemName: actionType.icon)
                    }
                }
                .font(.caption.bold())
                .padding(.horizontal, isHovered ? 14 : 12)
                .padding(.vertical, isHovered ? 10 : 8)
                .contentShape(Rectangle())
                .glassEffect(
                    .regular.tint(
                        isHovered
                        ? (actionType?.color ?? color).opacity(0.50)
                        : color.opacity(0.25)
                    )
                )
                .padding(isHovered ? 0 : 2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover {
            guard !isPreset && actionType != nil else { return }
            isHovered = $0
        }
        .accessibilityLabel(Text(value))
        .accessibilityHint(Text(actionTypeHint))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        IGTagView("Travel", in: .blue, isPreset: true, actionType: .add)
        IGTagView("Cooking", in: .blue, actionType: .remove)
        IGTagView("Ideas", actionType: .delete)
        IGTagView("Ideas", actionType: .add)
        IGTagView("Ideas")
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.thinMaterial)
}
