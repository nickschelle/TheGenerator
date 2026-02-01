//
//  IGPhraseDetailHeaderView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-06.
//

import SwiftUI

struct IGPhraseDetailHeader: View {
    
    @Environment(IGAppSettings.self) private var settings
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding private var selectedTheme: String
    @State private var isShowingThemePicker: Bool = false
    
    private let phrase: IGPhrase
    
    init(_ phrase: IGPhrase, selectedTheme: Binding<String>) {
        self.phrase = phrase
        self._selectedTheme = selectedTheme
    }
    
    private var formattedPhraeValue: String {
        settings.workspace.workspace.designKey?.displayText(phrase.value) ?? phrase.value
    }
    
    private var designKey: IGDesignKey? {
        settings.workspace.workspace.designKey
    }
    
    private var themes: [any IGDesignTheme]? {
        guard let designKey else {
            return nil
        }

        var themes = designKey.themes

        if let activeIDs = settings.designConfigs[designKey]?.activeThemeIDs {
            themes = themes.filter { activeIDs.contains($0.id) }
        }
        
        return themes
    }
    
    private var background: Color {
        if let designKey,
            let theme = try? designKey.design.theme(rawValue: selectedTheme) {
            return theme.preferredBackground.backgroundColor
        }
        return .clear
    }
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if let designKey, let themes, !themes.isEmpty {
                    IGImageRecordThumbnail(
                        phrase.value,
                        design: designKey,
                        theme: selectedTheme
                    )
                    .padding(12)
                    .background(background)
                    .clipShape(Circle())
                    .shadow(radius: 8)
                    .frame(height: 120)
                    .onTapGesture(perform: {
                        isShowingThemePicker = true
                    })
                    .popover(isPresented: $isShowingThemePicker, arrowEdge: .trailing) {
                            Picker("Preview Theme", selection: $selectedTheme) {
                                ForEach(themes, id: \.id) { theme in
                                    Text(theme.displayName)
                                        .tag(theme.rawValue)
                                }
                            }
                            .pickerStyle(.radioGroup) // great on macOS
                            .padding()
                        }
                    
                }
                Text(formattedPhraeValue)
                    .font(.largeTitle)
                
            }
            Spacer()
        }
    }
}

#Preview {
    @Previewable @State var app: IGAppModel = .init()
    IGPhraseDetailHeader(IGPhrase("Pugs Poop"), selectedTheme: .constant(""))
        .frame(width: 400, height: 400)
        .environment(app)
    
}
