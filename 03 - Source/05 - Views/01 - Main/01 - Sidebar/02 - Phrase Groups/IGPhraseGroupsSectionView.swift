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
    
    init() {
        _groups = Query(
            sort: [SortDescriptor<IGGroup>(\.name)])
    }
    
    var body: some View {
        Section(header: Text("Phrase Groups")) {
            IGAllPhrasesSidebarItem().tag(IGContentSelection.allPhrases)
            
            ForEach(groups) { group in
                IGGroupSidebarItem(group)
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


