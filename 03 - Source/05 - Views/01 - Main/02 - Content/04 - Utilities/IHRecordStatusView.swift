//
//  IGRecordStatusView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-23.
//

import SwiftUI

struct IGRecordStatusView: View {
    
    private let record: IGRecord
    
    init(_ record: IGRecord) {
        self.record = record
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: record.status.symbol)
                .foregroundStyle(.secondary)
            Text(record.status.description)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    IGRecordStatusView(IGRecord(phrase: IGPhrase("Cool")))
}
