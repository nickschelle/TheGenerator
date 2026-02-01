//
//  IGDesignSectionView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-02-01.
//

import SwiftUI
import SwiftData

struct IGDesignSection: View {
    
    @Environment(IGAppSettings.self) private var settings
    
    private let revisionMap: [IGRecordKey: [IGRecord?]]
    private let title: String

    init(_ title: String, revisionMap: [IGRecordKey: [IGRecord?]]) {
        self.revisionMap = revisionMap
        self.title = title
    }
    
    private var sectionTitle: String {
        guard settings.workspace.workspace.designKey != nil else  {
            return "\(title) Images"
        }
        return "Images"
        
    }
    
    private var recordKeys: [IGRecordKey] {
        Array(revisionMap.keys).sorted()
    }
    
    var body: some View {
        Section(sectionTitle) {
            ForEach(recordKeys,id: \.self) { recordKey in
                if let revisions = revisionMap[recordKey] {
                    if revisions.count == 1 && revisions[0] == nil {
                        IGDesignSectionRow(
                            recordKey.displayValue(includeDesign: false),
                            revision: 0,
                            isNew: true
                        )
                        .padding(4)
                    } else {
                        IGRevisionSection(revisions, for: recordKey)
                    }
                }
            }
        }
    }
    

}

#Preview {
    IGDesignSection("Title", revisionMap: [:])
}
