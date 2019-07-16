//  Copyright © 2019 The nef Authors.

import Foundation

class PreferencesDataSource {
    
    let fileManager: FileManager
    
    init(fileManager: FileManager) {
        self.fileManager = fileManager
        buildFileSystem()
    }
    
    var state: PreferencesModel { retrieveState() ?? self.default }
    
    var `default`: PreferencesModel {
        return PreferencesModel(showLines: true,
                                showWatermark: true,
                                font: .firaCode,
                                theme: .dracula,
                                size: .x2,
                                color: .nef)
    }
    
    func persist(model: PreferencesModel) {
        store(state: model)
    }
    
    // MARK: private methods
    private let folderName = "nef"
    private let fileName = "preferences"
    
    private var file: URL? { appFolder?.appendingPathComponent("\(fileName).json", isDirectory: false) }
    private var appFolder: URL? {
        let root = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let app = root?.appendingPathComponent(folderName, isDirectory: true)
        return app
    }
    
    private func buildFileSystem() {
        guard let appFolder = appFolder else { return }
        guard !fileManager.fileExists(atPath: appFolder.path) else { return }
        
        try? fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true, attributes: nil)
        store(state: self.default)
    }
    
    private func store(state: PreferencesModel) {
        guard let file = file,
              let data = try? JSONEncoder().encode(state) else { return }
        
        removeFile(file)
        fileManager.createFile(atPath: file.path, contents: data, attributes: nil)
    }
    
    private func retrieveState() -> PreferencesModel? {
        guard let file = file,
              let data = fileManager.contents(atPath: file.path),
              let model = try? JSONDecoder().decode(PreferencesModel.self, from: data) else { return nil }
        
        return model
    }
    
    private func removeFile(_ url: URL) {
        guard fileManager.fileExists(atPath: url.path) else { return }
        try? fileManager.removeItem(at: url)
    }
}
