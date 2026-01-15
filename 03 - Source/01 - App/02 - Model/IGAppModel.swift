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
    
    var appError: IGAppError?
    
    var activeSheet: IGAppSheet?
 
    var isShowingConfirmation: Bool = false
    var confirmationContent: IGConfirmationContent = .defaultValue
    
    func showConfirmation(_ content: IGConfirmationContent) {
        confirmationContent = content
        isShowingConfirmation = true
    }

    var selectedContents: Set<IGContentSelection> = []
    var selectedContent: IGContentSelection? {
        guard selectedContents.count == 1 else { return nil }
        return selectedContents.first
    }
    var selectedGroup: IGGroup? {
        selectedContent?.group
    }
    var selectedGroups: Set<IGGroup> {
        get {
            Set(selectedContents.compactMap(\.group))
        }
        set {
            selectedContents = Set(newValue.map { IGContentSelection.group($0) })
        }
    }
  
    var selectedDetails: Set<IGDetailSelection> = []
    var selectedDetail: IGDetailSelection? {
        guard selectedDetails.count == 1 else { return nil }
        return selectedDetails.first
    }
    
    var selectedPhrases: Set<IGPhrase> {
        get {
            Set(selectedDetails.compactMap(\.phrase))
        }
        set {
            selectedDetails = Set(newValue.map { IGDetailSelection.phrase($0) })
        }
    }
    
    var selectedPhrase: IGPhrase? {
        selectedDetail?.phrase
    }
    
    var selectedRecords: Set<IGRecord> {
        get {
            Set(selectedDetails.compactMap(\.record))
        }
        set {
            selectedDetails = Set(newValue.map { IGDetailSelection.record($0) })
        }
    }
    
    var selectedRecord: IGRecord? {
        selectedDetail?.record
    }
    
    var detailPath: NavigationPath = NavigationPath()
    
    var phraseToEdit: IGPhrase?
    var isAddingPhrase: Bool = false
    /*
    var inspectorRecord: IHRecord?
    */
    var locationImportInProgress: Bool = false
    var onLocationImportSuccess: ((URL) -> Void)?
    var onLocationImportFailure: (() -> Void)?
    
    var ftpLoginInProgress: Bool = false
    var onFTPLoginSuccess: ((IGFTPConfig) -> Void)?
    var onFTPLoginFailure: (() -> Void)?
/*
    var generationState: IGImageGenerationState = .idle
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
    

    func ensureLocationAvailableOrImport(
        using location: IGLocationConfig,
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
        using ftp: IGFTPConfig,
        onSuccess: @escaping (IGFTPConfig) -> Void,
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
    
    func completeFTPLogin(success ftp: IGFTPConfig? = nil) {
        if let ftp {
            onFTPLoginSuccess?(ftp)
        } else {
            onFTPLoginFailure?()
        }
        onFTPLoginSuccess = nil
        onFTPLoginFailure = nil
        ftpLoginInProgress = false
    }
}



