//
//  ContentView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var phrases: [IHPhrase]
    @State private var newValue: String = ""
    @Query private var groups: [IHGroup]
    @State private var newName: String = ""
    
    var body: some View {
        VStack {
            TextField("Phrase Value", text: $newValue)
            Button("Add Phrase", action: addPhrase)
                .disabled(newValue.isEmpty)
            List {
                ForEach(phrases) { phrase in
                    Text(phrase.value)
                        .contextMenu{
                            Button("Delete") {
                                self.deletePhrase(phrase)
                            }
                        }
                }
            }
            TextField("Group Name", text: $newName)
            Button("Add Group", action: addGroup)
                .disabled(newName.isEmpty)
            List {
                ForEach(groups) { group in
                    Text(group.name)
                        .contextMenu{
                            Button("Delete") {
                                self.deleteGroup(group)
                            }
                        }
                }
            }
        }
    }
    
    private func addPhrase() {
        let result = IHPhraseManager.newPhrase(newValue, in: context)
        if case .success(let phrase) = result {
           
        } else if case .failure(let error) = result {
            print(error)
        }
        
        newValue = ""
    }
    
    private func deletePhrase(_ phrase: IHPhrase) {
        IHPhraseManager.deletePhrases([phrase], in: context)
        try? context.save()
    }
    
    private func addGroup() {
        let result = IHGroupManager.newGroup(newName, in: context)
        if case .success(let created) = result {
            if created {
                
            } else {
                
            }
        } else if case .failure(let error) = result {
            print(error)
        }
        
        newValue = ""
    }
    
    private func deleteGroup(_ group: IHGroup) {
        let result = IHGroupManager.deleteGroups([group], in: context)
        if case .failure(let error) = result {
            print(error)
        }
    }
    
    
}

#Preview {
    ContentView()
}
