//
//  IGUploadQueueView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-03.
//

import SwiftUI
import SwiftData

struct IGUploadQueue: View {
    
    @Environment(IGAppModel.self) private var app
    
    private let replacedRaw = IGRecordStatus.replacedInFolder.rawValue
    
    var body: some View {
        IGQueue(
            .upload,
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
