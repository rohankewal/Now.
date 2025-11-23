//
//  ExportManager.swift
//  Now
//
//  Created by Rohan Kewalramani on 11/23/25.
//

import SwiftUI
import UniformTypeIdentifiers

// Defines the structure of the file we are exporting
struct JournalBackupFile: FileDocument {
    // We tell iOS this file contains JSON data
    static var readableContentTypes: [UTType] { [.json] }
    
    var jsonString: String = ""
    
    init(text: String) {
        self.jsonString = text
    }
    
    // Required by FileDocument
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            jsonString = String(decoding: data, as: UTF8.self)
        }
    }
    
    // This creates the actual file when the user clicks Export
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(jsonString.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

// A simple codable struct to make the JSON clean
struct ExportableEntry: Codable {
    let date: Date
    let moodLabel: String
    let moodScore: Double
    let prompt: String
    let content: String
}
