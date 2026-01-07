//
//  IGContentListView.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-23.
//

import SwiftUI
import SwiftData

struct IGContentList<
    Item: PersistentModel & Hashable,
    ForEachContent: View,
    ListContent: View
>: View {
    
    @Environment(IGAppModel.self) private var app
    @Query private var items: [Item]
    
    @Binding private var selection: Set<IGDetailSelection>
    
    private let title: String
    private let forEachContent: (Item) -> ForEachContent
    private let listContent: ListContent

    private var subtitle: String {
        guard !items.isEmpty else { return "No items"}
        let countString = "\(items.count)"
        let itemsString = items.count == 1 ? "item" : "items"
        return countString + " " + itemsString
    }

    init(
        _ title: String,
        descriptor: FetchDescriptor<Item>,
        selection: Binding<Set<IGDetailSelection>>,
        @ViewBuilder forEachContent: @escaping (Item) -> ForEachContent,
        @ViewBuilder listContent: () -> ListContent = { EmptyView() },
    ) {
        self.title = title
        self._items = Query(descriptor)
        self._selection = selection
        self.forEachContent = forEachContent
        self.listContent = listContent()
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(items) { item in
                forEachContent(item)
            }
            listContent
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationSubtitle(subtitle)
    }
}
