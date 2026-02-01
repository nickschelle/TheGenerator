//
//  IGPhraseDetailRecordSectionView.swift
//  IHeartEverything
//
//  Created by Nick Schelle on 2025-11-07.
//

import SwiftUI
import SwiftData

struct IGPhraseDetailRecordSection: View {
    
    @Environment(IGAppSettings.self) private var settings
    @Query private var records: [IGRecord]
    
    private let phrase: IGPhrase
    
    init(_ phrase: IGPhrase) {
        self.phrase = phrase
        let phraseID = phrase.id
        _records = Query(FetchDescriptor(predicate: #Predicate {
            $0.phrase?.id == phraseID
        }))
    }
        
    var revisionGroups: IGRevisionMap {
        IGRecordManager.organizeRecordsByRevision(records, for: phrase)
    }
    
    var designKeys: [IGDesignKey] {
        guard let designKey = settings.workspace.workspace.designKey else  {
            return IGDesignKey.allCases
        }
        return [designKey]
    }

    var body: some View {
        ForEach(designKeys) { designKey in
            if let revisionGroup = revisionGroups[designKey] {
                IGDesignSection(designKey.displayName, revisionMap: revisionGroup)
            }
        }
    }
}

#Preview {
    @Previewable @State var settings: IGAppSettings = .init()
    IGPhraseDetailRecordSection(IGPhrase("Poop"))
        .frame(width: 400, height: 400)
        .environment(settings)
}
