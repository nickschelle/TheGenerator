//
//  IGDetailSelection.swift
//  TheGenerator
//
//  Created by Nick Schelle on 2025-11-09.
//

import Foundation

enum IGDetailSelection: Equatable, Hashable, Identifiable {
    case phrase(IGPhrase)
   // case record(IGRecord)
    
    var id: String {
        switch self {
        case .phrase(let phrase): return "phrase:\(phrase.id)"
        //case .record(let record): return "record:\(record.id)"
        }
    }
    
    var phrase: IGPhrase? {
        switch self {
        case .phrase(let phrase): phrase
        //default: nil
        }
    }
    /*
    var record: IHRecord? {
        switch self {
        case .record(let record): record
        default: nil
        }
    }
     */
}
