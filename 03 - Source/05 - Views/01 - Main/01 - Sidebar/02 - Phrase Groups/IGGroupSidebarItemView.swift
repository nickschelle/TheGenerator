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

    @Query var links: [IGGroupPhraseLink]
    
    @State private var isHovered: Bool = false
    @State private var showMenuPopover = false
    
    private let group: IGGroup
    
    init(_ group: IGGroup) {
        self.group = group
        let groupID = group.id
        _links = Query(filter: #Predicate<IGGroupPhraseLink> { $0.group?.id == groupID })
    }
    
    var body: some View {
        IGSidebarItem(group.name, systemImage: "rectangle.stack", count: links.count)
        .contextMenu {
           IGEditGroupButton(group)
           IGDeleteGroupsButton(group)
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    IGGroupSidebarItem(IGGroup("Group"))
        .environment(app)
}
