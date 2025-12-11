//
//  IGAddTagButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-24.
//

import SwiftUI

struct IGAddTagButton: View {
    
    @State private var isHovered: Bool = false
    @State private var tempVaue: String = ""
    @State private var isShowingNewTagAlert: Bool = false
    
    private let addTag: (String) -> Void
    private let color: Color
    
    init(color: Color = .accentColor, onAddTag: @escaping (String) -> Void = { _ in }) {
        self.addTag = onAddTag
        self.color = color
    }
    
    var body: some View {
        Button(action: { isShowingNewTagAlert = true }) {
            Image(systemName: "plus")
                .font(.caption.bold())
                .foregroundStyle(color)
                .padding(.horizontal, isHovered ? 14 : 12)
                .padding(.vertical, isHovered ? 10 : 8)
                .overlay(alignment: .center) {
                    Capsule()
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: isHovered ? 2 : 1,
                                dash: [5]
                            )
                        )
                        .foregroundColor(color)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(isHovered ? 0 : 2)
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .accessibilityLabel("Add Tag")
        .accessibilityHint("Opens a dialog to create a new tag")
        .alert("New Tag", isPresented: $isShowingNewTagAlert) {
            TextField("Tag Name", text: $tempVaue)
                .onChange(of: tempVaue) { old, new in
                    let normalized = IGTag.normalizeForInput(new)
                    if normalized != new {
                        tempVaue = normalized
                    }
                }
            Button("Cancel", role: .cancel, action: resetTagName)
            Button("Add", role: .confirm, action: add)
                .disabled(tempVaue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
 
    }
    
    private func resetTagName() {
        tempVaue = ""
    }
    
    private func add() {
        addTag(tempVaue)
        resetTagName()
    }
}

// MARK: - Preview

#Preview {
    IGAddTagButton { newTag in
        print("Added tag:", newTag)
    }
    .padding(30)
    .background(.thinMaterial)
}
