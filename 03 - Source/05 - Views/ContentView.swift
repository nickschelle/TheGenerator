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
    @Query private var phrases: [IGPhrase]
    @State private var newValue: String = ""
    @Query private var groups: [IGGroup]
    @State private var newName: String = ""
    @State private var selectedGroups: Set<IGGroup> = []
    
    var body: some View {
        VStack {
            TextField("Phrase Value", text: $newValue)
            Button("Add Phrase", action: addPhrase)
                .disabled(newValue.isEmpty)
            List {
                ForEach(phrases) { phrase in
                    HStack {
                        Text(phrase.value)
                        Spacer()
                        Text(phrase.dateModified.displayString)
                    }
                        .contextMenu{
                            Button("Delete") {
                                self.deletePhrase(phrase)
                            }
                            Button("Add to Group") {
                                self.addToGroups(phrase)
                            }
                            .disabled(selectedGroups.isEmpty)
                            Button("Remove from Group") {
                                self.removeFromGroups(phrase)
                            }
                            .disabled(selectedGroups.isEmpty)
                        }
                }
            }
            TextField("Group Name", text: $newName)
            Button("Add Group", action: addGroup)
                .disabled(newName.isEmpty)
            List(selection: $selectedGroups) {
                ForEach(groups) { group in
                    HStack {
                        Text(group.name)
                        Spacer()
                        Text(group.dateModified.displayString)
                    }
                    .tag(group)
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
        do {
            let phrase = try IGPhraseManager.newPhrase(newValue, in: context)
            try context.save()
        } catch {
            print("Failed to add Phrase: \(error)")
        }
        newValue = ""
    }
    
    private func deletePhrase(_ phrase: IGPhrase) {
        do {
            try IGPhraseManager.deletePhrases([phrase], in: context)
            try context.save()
        } catch {
            print("Failed to delete phrase: \(error)")
        }
    }
    
    private func addGroup() {
        do {
            if try !IGGroupManager.newGroup(newName, in: context) {
                print("already exists")
            } else {
                try context.save()
                newName = ""
            }
        } catch {
           print("Failed to add group: \(error)")
       }
    }
    
    private func addToGroups(_ phrase: IGPhrase) {
        do {
            IGGroupManager.add([phrase], to: selectedGroups, in: context)
            try context.save()
        } catch {
            print("Failed to add phrase to group: \(error)")
        }
    }
    
    private func removeFromGroups(_ phrase: IGPhrase) {
        do {
            try IGGroupManager.remove([phrase], from: selectedGroups, in: context)
            try context.save()
        } catch {
            print("Failed to remove phrase from group: \(error)")
        }
    }
    
    private func deleteGroup(_ group: IGGroup) {
        do {
            try IGGroupManager.deleteGroups([group], in: context)
            try context.save()
        }catch {
               print("Failed to delete group: \(error)")
           }
    }
    
    
}

#Preview {
    ContentView()
}
