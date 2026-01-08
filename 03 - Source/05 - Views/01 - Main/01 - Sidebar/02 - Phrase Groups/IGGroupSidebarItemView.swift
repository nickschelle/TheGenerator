//
//  IGGroupSidebarItemView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-21.
//

import SwiftUI
import SwiftData

struct IGGroupSidebarItem: View {
    
    @Environment(IGAppModel.self) private var app

    @Query var phrases: [IGPhrase]
    
    @State private var isHovered: Bool = false
    @State private var showMenuPopover = false
    
    private let group: IGGroup
    
    init(_ group: IGGroup, designKey: IGDesignKey? = nil) {
        self.group = group
        let groupID = group.id
        if let rawKey = designKey?.rawValue {
            _phrases = Query(filter: #Predicate<IGPhrase> { phrase in
                phrase.groupLinks.contains {
                    $0.group?.id == groupID
                }
                &&
                phrase.designLinks.contains {
                    $0.rawDesignKey == rawKey
                }
            })
        } else {
            _phrases = Query(filter: #Predicate<IGPhrase> { phrase in
                phrase.groupLinks.contains {
                    $0.group?.id == groupID
                }
            })
        }
    }
    
    var body: some View {
        IGSidebarItem(group.name, systemImage: "rectangle.stack", count: phrases.count)
        .contextMenu {
            if app.selectedGroups.isEmpty {
                IGEditGroupButton(group)
            } else {
                IGEditTagsButton(selection: app.selectedGroups)
            }
            IGDeleteGroupsButton(group)
           
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGGroupSidebarItem(IGGroup("Group"))
        .environment(app)
}
