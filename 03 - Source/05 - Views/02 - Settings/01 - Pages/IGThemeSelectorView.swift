//
//  IGThemeSelectorView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2026-01-07.
//

import SwiftUI

struct IGThemeSelectorView<Theme: IGTheme>: View {
    
    @Binding private var selection: Set<String>
    private var themes: [Theme]
    
    
    init(_ selection: Binding<Set<String>>, themes: Set<Theme>) {
        self._selection = selection
        self.themes = Array(themes).sorted { $0.displayName < $1.displayName }
    }
    
    
    var body: some View {
        List(selection: $selection) {
            ForEach(themes) { theme in
                Text(theme.displayName).tag(theme.id)
            }
        }
    }
}

#Preview {
    IGThemeSelectorView(.constant([]), themes: Set<IHeartPhraseTheme>.init())
}
