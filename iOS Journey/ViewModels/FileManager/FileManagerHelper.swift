//
//  FileManagerHelper.swift
//  iOS Journey
//
//  Created by MAC on 28/03/25.
//

import Foundation

actor FileManagerHelper {
    
    static let shared = FileManagerHelper()
    private let fileManager = FileManager.default
    
    // Path to Cache Directory
    private var cacheDirectory: URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    // Path to Video Folder
    private var videoFolderURL: URL {
        let videoFolder = cacheDirectory.appendingPathComponent("VideoCache")
        if !fileManager.fileExists(atPath: videoFolder.path) {
            try? fileManager.createDirectory(at: videoFolder, withIntermediateDirectories: true, attributes: nil)
        }
        return videoFolder
    }
    
    // Save Video Data
    func saveVideoData(from url: URL) async -> URL? {
        let fileName = url.lastPathComponent
        let destinationURL = videoFolderURL.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("File already exists at \(destinationURL)")
            return destinationURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try data.write(to: destinationURL)
            print("Video saved successfully at \(destinationURL)")
            return destinationURL
        } catch {
            print("Failed to save video: \(error)")
            return nil
        }
    }
    
    // Retrieve Video URL
    func getVideoURL(fileName: String) -> URL? {
        let videoURL = videoFolderURL.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: videoURL.path) ? videoURL : nil
    }
    
    // Delete Video
    func deleteVideo(fileName: String) async {
        let videoURL = videoFolderURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: videoURL.path) {
            do {
                try fileManager.removeItem(at: videoURL)
                print("Video deleted successfully")
            } catch {
                print("Failed to delete video: \(error)")
            }
        }
    }
    
    // Clear All Cached Videos
    func clearVideoCache() async {
        do {
            try fileManager.removeItem(at: videoFolderURL)
            print("All cached videos deleted.")
        } catch {
            print("Failed to clear video cache: \(error)")
        }
    }
}

