//
//  IGConfirmationContent.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-10-24.
//

import Foundation
import SwiftUI

struct IGConfirmationContent {
    var title: String
    var titleVisibility: Visibility
    var message: AnyView
    var confirmTitle: String
    var confirmRole: ButtonRole
    var onConfirm: () -> Void
    
    init(
        _ title: String = "",
        visibility: Visibility = .visible,
        confirmTitle: String = "OK",
        confirmRole: ButtonRole = .confirm,
        onConfirm: @escaping () -> Void = {},
        @ViewBuilder message: () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.titleVisibility = visibility
        self.message = AnyView(message())
        self.confirmTitle = confirmTitle
        self.confirmRole = confirmRole
        self.onConfirm = onConfirm
    }
    
    @ViewBuilder
    var actions: some View {
        Button("Cancel", role: .cancel) { }
        Button(confirmTitle, role: confirmRole, action: onConfirm)
    }
    
    static var defaultValue: IGConfirmationContent {
        IGConfirmationContent("Are You Sure")
    }
}
