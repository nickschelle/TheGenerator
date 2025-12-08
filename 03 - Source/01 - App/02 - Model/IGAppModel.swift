//
//  IGAppModel.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-12-08.
//

import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
final class IGAppModel {
    
    // MARK: - Core Data Stack
    let container: ModelContainer
    let context: ModelContext
    //let imageManager: IHImageManager
    
    //var activeSheet: IHAppSheet?
    /*
    var isShowingConfirmation: Bool = false
    var confirmationContent: IHConfirmationContent = .defaultValue
    
    func showConfirmation(_ content: IHConfirmationContent) {
        confirmationContent = content
        isShowingConfirmation = true
    }
    
    var selectedContents: Set<IHContentSelection> = []
    var selectedContent: IHContentSelection? {
        guard selectedContents.count == 1 else { return nil }
        return selectedContents.first
    }
    var selectedGroup: IHGroup? {
        selectedContent?.group
    }
    var selectedGroups: Set<IHGroup> {
        get {
            Set(selectedContents.compactMap(\.group))
        }
        set {
            selectedContents = Set(newValue.map { IHContentSelection.group($0) })
        }
    }
    
    var selectedDetails: Set<IHDetailSelection> = []
    var selectedDetail: IHDetailSelection? {
        guard selectedDetails.count == 1 else { return nil }
        return selectedDetails.first
    }
    
    var selectedRecords: Set<IHRecord> {
        get {
            Set(selectedDetails.compactMap(\.record))
        }
        set {
            selectedDetails = Set(newValue.map { IHDetailSelection.record($0) })
        }
    }
    
    var selectedRecord: IHRecord? {
        selectedDetail?.record
    }

    var selectedPhrases: Set<IHPhrase> {
        get {
            Set(selectedDetails.compactMap(\.phrase))
        }
        set {
            selectedDetails = Set(newValue.map { IHDetailSelection.phrase($0) })
        }
    }
    
    var selectedPhrase: IHPhrase? {
        selectedDetail?.phrase
    }
    
    var detailPath: NavigationPath = NavigationPath()
    
    var phraseToEdit: IHPhrase?
    var isAddingPhrase: Bool = false
    
    var inspectorRecord: IHRecord?
    
    var locationImportInProgress: Bool = false
    var onLocationImportSuccess: ((URL) -> Void)?
    var onLocationImportFailure: (() -> Void)?
    
    var ftpLoginInProgress: Bool = false
    var onFTPLoginSuccess: ((IHFTPConfig) -> Void)?
    var onFTPLoginFailure: (() -> Void)?

    var generationState: IHImageGenerationState = .idle
    var generationMessage: String?
    var generationProgress: Double?
    
    var uploadState: IHImageUploadState = .idle
    var uploadMessage: String?
    var uploadProgress: Double?
     */
     
    // MARK: - Init
    init(inMemory: Bool = false) {
        container = IGModelContainerManager.makeContainer()
        context = container.mainContext
       // imageManager = IHImageManager()
    }
    
    /*
    func ensureLocationAvailableOrImport(
        using location: IHLocationConfig,
        onSuccess: @escaping (URL) -> Void,
        onFailure: @escaping () -> Void
    ) {
        // If the bookmark is valid, return immediately
        if let url = location.resolvedURL {
            onSuccess(url)
            return
        }

        // Otherwise begin the UI-driven import workflow
        self.onLocationImportSuccess = onSuccess
        self.onLocationImportFailure = onFailure
        self.locationImportInProgress = true
    }
    
    func ensureFTPLoginAvailableOrPrompt(
        using ftp: IHFTPConfig,
        onSuccess: @escaping (IHFTPConfig) -> Void,
        onFailure: @escaping () -> Void
    ) {
        // If credentials already exist, return immediately
        if !ftp.username.isEmpty,
           !ftp.password.isEmpty
        {
            onSuccess(ftp)
            return
        }

        // Trigger UI workflow to collect FTP login details
        self.onFTPLoginSuccess = onSuccess
        self.onFTPLoginFailure = onFailure
        ftpLoginInProgress = true
        self.activeSheet = .ftpSignIn
    }
    
    func completeFTPLogin(success ftp: IHFTPConfig? = nil) {
        if let ftp {
            onFTPLoginSuccess?(ftp)
        } else {
            onFTPLoginFailure?()
        }
        onFTPLoginSuccess = nil
        onFTPLoginFailure = nil
        ftpLoginInProgress = false
    }
     */
}



