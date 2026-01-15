//
//  IGUploadQueueView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI
import SwiftData

struct IGUploadQueue: View {
    
    private let replacedRaw = IGRecordStatus.replacedInFolder.rawValue
    
    var body: some View {
        
        IGQueue(
            "Upload Queue",
            predicate: #Predicate<IGRecord> {
                $0.dateRendered != nil &&
                $0.dateUploaded == nil &&
                $0.rawStatus != replacedRaw
            }
        )
    }
}

#Preview {
    IGUploadQueue()
}
