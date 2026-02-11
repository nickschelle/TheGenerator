//
//  IGGroupDesignMenu.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-08.
//

import SwiftUI
import SwiftData

struct IGGroupDesignMenu: View {
    
    @Environment(IGAppModel.self) private var app
    
    private let group: IGGroup?
    
    init(_ group: IGGroup? = nil) {
        self.group = group
    }
    
    private var selection: Set<IGGroup> {
        guard let group else { return app.selectedGroups }
        return app.selectedGroups.contains(group) ? app.selectedGroups : [group]
    }
    
    var designs: [IGDesignKey] {
        IGDesignKey.allCases
    }
    
    var body: some View {
        if selection.isEmpty {
            Button("Designs", systemImage: "rectangle.3.group", action: {}).disabled(true)
        } else {
            Menu("Designs", systemImage: "rectangle.3.group") {
                ForEach(designs) { designKey in
                    let groupsWithDesign: [IGGroup] = selection.filter { group in
                        group.designLinks.contains { link in
                            link.designKey == designKey
                        }
                    }
                    let status: IGMatchStatus = IGMatchStatus.evaluate(selection: selection, in: groupsWithDesign)
                    Button(designKey.displayName, systemImage: status.systemImage) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            updateSelected(status, with: designKey)
                        }
                    }
                }
            }
        }
    }
    
    private func updateSelected(_ status: IGMatchStatus, with key: IGDesignKey) {
        do {
            withAnimation(.easeInOut(duration: 0.15)) {
                switch status {
                case .all:
                    key.disconnect(selection, in: app.context)
                case .some, .none:
                    key.connect(
                        selection,
                        in: app.context
                    )
                }
            }
            try app.context.save()
        } catch {
            app.appError = .groupFailure(
                "Failed to connect/disconnect groups to/from Design: \(error)"
            )
        }
    }
}
