//
//  IGNewPhraseButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-21.
//

import SwiftUI

struct IGNewPhraseButton: View {
    
    enum Context {
        case toolbar
        case commands
        
        var symbol: String {
            switch self {
            case .toolbar: "plus"
            case .commands: "plus.circle"
            }
        }
    }
    
    @Environment(IGAppModel.self) private var app
    private let context: Context
    
    init(_ context: Context = .toolbar) {
        self.context = context
    }
    
    var body: some View {
        Button("New Phrase", systemImage: context.symbol, action: newPhrase)
    }
    
    func newPhrase() {
        app.isAddingPhrase = true
    }
}

#Preview {
    
    @Previewable @State var app: IGAppModel = .init()
    
    IGNewPhraseButton(.commands)
        .environment(app)
}
