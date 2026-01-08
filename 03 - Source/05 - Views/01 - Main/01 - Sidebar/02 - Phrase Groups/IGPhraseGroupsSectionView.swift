//
//  IGPhraseGroupsSectionView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-09-21.
//

import SwiftUI
import SwiftData

struct IGPhraseGroupsSection: View {
    
    @Environment(IGAppModel.self) private var app
    
    @Query private var groups: [IGGroup]
    private let designKey: IGDesignKey?
    
    init(_ designKey: IGDesignKey? = nil) {
        self.designKey = designKey
        if let designKey {
            let rawKey = designKey.rawValue
            _groups = Query(filter: #Predicate<IGGroup> { group in
                group.designLinks.contains { $0.rawDesignKey == rawKey}
            }, sort: [SortDescriptor<IGGroup>(\.name)])
        } else {
            _groups = Query(sort: [SortDescriptor<IGGroup>(\.name)])
        }
    }
    
    var body: some View {
        Section(header: Text("Phrase Groups")) {
            IGAllPhrasesSidebarItem(designKey: designKey).tag(IGContentSelection.allPhrases)
            
            ForEach(groups) { group in
                IGGroupSidebarItem(group, designKey: designKey)
                    .tag(IGContentSelection.group(group))
            }
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    
    MainView()
        .environment(app)
}


