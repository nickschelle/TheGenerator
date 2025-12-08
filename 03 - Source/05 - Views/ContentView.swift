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
    @State private var selectedGroups: Set<IHGroup> = []
    
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
            let phrase = try IHPhraseManager.newPhrase(newValue, in: context)
            try context.save()
        } catch {
            print("Failed to add Phrase: \(error)")
        }
        newValue = ""
    }
    
    private func deletePhrase(_ phrase: IHPhrase) {
        do {
            try IHPhraseManager.deletePhrases([phrase], in: context)
            try context.save()
        } catch {
            print("Failed to delete phrase: \(error)")
        }
    }
    
    private func addGroup() {
        do {
            if try !IHGroupManager.newGroup(newName, in: context) {
                print("already exists")
            } else {
                try context.save()
                newName = ""
            }
        } catch {
           print("Failed to add group: \(error)")
       }
    }
    
    private func addToGroups(_ phrase: IHPhrase) {
        do {
            IHGroupManager.add([phrase], to: selectedGroups, in: context)
            try context.save()
        } catch {
            print("Failed to add phrase to group: \(error)")
        }
    }
    
    private func removeFromGroups(_ phrase: IHPhrase) {
        do {
            try IHGroupManager.remove([phrase], from: selectedGroups, in: context)
            try context.save()
        } catch {
            print("Failed to remove phrase from group: \(error)")
        }
    }
    
    private func deleteGroup(_ group: IHGroup) {
        do {
            try IHGroupManager.deleteGroups([group], in: context)
            try context.save()
        }catch {
               print("Failed to delete group: \(error)")
           }
    }
    
    
}

#Preview {
    ContentView()
}
