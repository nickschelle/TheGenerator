//
//  IGModelActionButton.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-19.
//

import SwiftUI
import SwiftData

struct IGModelActionButton<Model: PersistentModel>: View {

    @Environment(IGAppModel.self) private var app

    private let primaryModel: Model?
    private let selection: [Model]
    private let confirmation: IGConfirmationContent?
    private let systemImage: String
    private let action: ([Model]) -> Void
    private let titleBuilder: (String) -> String

    init(
        _ model: Model? = nil,
        selection: some Collection<Model>,
        systemImage: String,
        confirmation: IGConfirmationContent? = nil,
        titleBuilder: @escaping (String) -> String,
        action: @escaping ([Model]) -> Void
    ) {
        self.primaryModel = model
        self.selection = Array(selection)
        self.systemImage = systemImage
        self.confirmation = confirmation
        self.action = action
        self.titleBuilder = titleBuilder
    }

    init(
        _ model: Model? = nil,
        selection: some Collection<Model>,
        actionTitle: String,
        systemImage: String,
        confirmation: IGConfirmationContent? = nil,
        action: @escaping ([Model]) -> Void
    ) {
        self.primaryModel = model
        self.selection = Array(selection)
        self.systemImage = systemImage
        self.confirmation = confirmation
        self.action = action
        self.titleBuilder = { "\(actionTitle) \($0)" }
    }
    
    init(
        _ model: Model? = nil,
        selected: Model?,
        systemImage: String,
        confirmation: IGConfirmationContent? = nil,
        titleBuilder: @escaping (String) -> String,
        action: @escaping (Model) -> Void
    ) {
        // Store the provided explicit model
        self.primaryModel = model

        // Store selection in a 1-element-array or empty array
        if let selected {
            self.selection = [selected]
        } else {
            self.selection = []
        }

        self.systemImage = systemImage
        self.confirmation = confirmation
        self.titleBuilder = titleBuilder

        // Wrap the single-model action into multi-array form
        self.action = { models in
            if let first = models.first {
                action(first)
            }
        }
    }
    
    init(
        _ model: Model? = nil,
        selected: Model?,
        actionTitle: String,
        systemImage: String,
        confirmation: IGConfirmationContent? = nil,
        action: @escaping (Model) -> Void
    ) {
        // Store the provided explicit model
        self.primaryModel = model

        // Store selection in a 1-element-array or empty array
        if let selected {
            self.selection = [selected]
        } else {
            self.selection = []
        }

        self.systemImage = systemImage
        self.confirmation = confirmation
        self.titleBuilder = { "\(actionTitle) \($0)" }

        // Wrap the single-model action into multi-array form
        self.action = { models in
            if let first = models.first {
                action(first)
            }
        }
    }

    // MARK: - Computed

    private var isDisabled: Bool {
        primaryModel == nil && selection.isEmpty
    }

    private var selectedModels: [Model] {
        guard let primary = primaryModel else { return selection }
        return selection.contains(primary) ? selection : [primary]
    }

    private var title: String {
        let count = selectedModels.count
        let noun = Model.displayName(with: count, includeNumberBelowTwo: false)
        return titleBuilder(noun)
    }

    // MARK: - Body

    var body: some View {
        Button(title, systemImage: systemImage, action: handleTap)
            .disabled(isDisabled)
    }

    // MARK: - Actions

    private func handleTap() {
        if var sheet = confirmation {
            sheet.title = "\(title)?"
            sheet.titleVisibility = .visible
            sheet.onConfirm = { action(selectedModels) }
            app.showConfirmation(sheet)
        } else {
            action(selectedModels)
        }
    }
}
