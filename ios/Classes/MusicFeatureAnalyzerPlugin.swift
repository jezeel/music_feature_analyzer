import Flutter
import UIKit
import AVFoundation
import MobileCoreServices
import ImageIO

public class MusicFeatureAnalyzerPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.music_feature_analyzer/audio_metadata",
            binaryMessenger: registrar.messenger()
        )
        let instance = MusicFeatureAnalyzerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        print("✅ MusicFeatureAnalyzerPlugin registered on iOS")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle verifyConnection first
        if call.method == "verifyConnection" {
            let response: [String: Any] = [
                "connected": true,
                "channelName": "com.music_feature_analyzer/audio_metadata",
                "loadingMode": "IOS_PLATFORM",
                "handlerSet": channel != nil,
                "platform": "iOS",
                "pluginVersion": "1.0.1-beta-04"
            ]
            result(response)
            print("verifyConnection response: \(response)")
            return
        }
        
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT",
                                message: "File path is required",
                                details: nil))
            return
        }
        
        switch call.method {
        case "getMetadata":
            getMetadata(filePath: path, result: result)
        case "getAlbumArt":
            getAlbumArt(filePath: path, result: result)
        case "getAlbumArtMimeType":
            getAlbumArtMimeType(filePath: path, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getMetadata(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            var metadata: [String: Any?] = [:]
            
            // Check if file exists
            let fileURL = URL(fileURLWithPath: filePath)
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: filePath) else {
                metadata["error"] = "File does not exist: \(filePath)"
                DispatchQueue.main.async {
                    result(metadata)
                }
                return
            }
            
            // Get file size
            do {
                let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
                if let fileSize = fileAttributes[.size] as? UInt64 {
                    metadata["fileSize"] = Int(min(fileSize, UInt64(Int32.max)))
                }
            } catch {
                print("Error getting file size: \(error)")
            }
            
            // Load AVAsset
            let asset = AVAsset(url: fileURL)
            
            // Get duration
            let duration = asset.duration
            let durationInSeconds = CMTimeGetSeconds(duration)
            metadata["duration"] = Int64(durationInSeconds * 1000) // Convert to milliseconds
            
            // Get common metadata
            metadata.merge(extractCommonMetadata(from: asset)) { (current, _) in current }
            
            // Get bitrate (approximate)
            if let track = asset.tracks(withMediaType: .audio).first {
                let bitrate = track.estimatedDataRate
                metadata["bitrate"] = Int(bitrate)
            }
            
            // Get MIME type from file extension
            metadata["mimeType"] = getMimeTypeFromExtension(filePath: filePath)
            
            // Check if has album art
            metadata["hasAlbumArt"] = hasAlbumArt(in: asset)
            
            DispatchQueue.main.async {
                result(metadata)
            }
        }
    }
    
    private func extractCommonMetadata(from asset: AVAsset) -> [String: Any?] {
        var metadata: [String: Any?] = [:]
        
        let commonMetadata = asset.commonMetadata
        
        for item in commonMetadata {
            guard let key = item.commonKey?.rawValue else { continue }
            
            switch key {
            case AVMetadataKey.commonKeyTitle.rawValue:
                metadata["title"] = item.stringValue
            case AVMetadataKey.commonKeyArtist.rawValue:
                metadata["artist"] = item.stringValue
            case AVMetadataKey.commonKeyAlbumName.rawValue:
                metadata["album"] = item.stringValue
            case AVMetadataKey.id3MetadataKeyAlbumArtist.rawValue,
                 AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue:
                metadata["albumArtist"] = item.stringValue
            case AVMetadataKey.commonKeyType.rawValue:
                // Sometimes genre is stored here
                if metadata["genre"] == nil {
                    metadata["genre"] = item.stringValue
                }
            case AVMetadataKey.id3MetadataKeyContentType.rawValue,
                 AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue:
                metadata["genre"] = item.stringValue
            case AVMetadataKey.commonKeyCreationDate.rawValue,
                 AVMetadataKey.id3MetadataKeyYear.rawValue:
                if let yearString = item.stringValue {
                    // Extract year from date string
                    let year = extractYearFromString(yearString)
                    metadata["year"] = year
                }
            case AVMetadataKey.commonKeyCreator.rawValue,
                 AVMetadataKey.id3MetadataKeyComposer.rawValue:
                metadata["composer"] = item.stringValue
            case AVMetadataKey.id3MetadataKeyWriter.rawValue:
                metadata["writer"] = item.stringValue
            case AVMetadataKey.id3MetadataKeyTrackNumber.rawValue:
                if let trackInfo = item.stringValue {
                    metadata["trackNumber"] = extractTrackNumber(trackInfo)
                }
            case AVMetadataKey.id3MetadataKeyDiscNumber.rawValue,
                 AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue:
                if let discInfo = item.stringValue {
                    metadata["discNumber"] = extractDiscNumber(discInfo)
                }
            default:
                break
            }
        }
        
        // Try to get more metadata from metadataFormats
        for format in asset.availableMetadataFormats {
            let items = asset.metadata(forFormat: format)
            for item in items {
                // Handle iTunes metadata
                if item.key as? String == AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue,
                   metadata["genre"] == nil {
                    metadata["genre"] = item.stringValue
                }
            }
        }
        
        return metadata
    }
    
    private func extractYearFromString(_ dateString: String) -> String? {
        // Try to extract year from various date formats
        let patterns = [
            "\\d{4}", // Just year
            "\\d{4}-\\d{2}-\\d{2}", // YYYY-MM-DD
            "\\d{2}/\\d{2}/\\d{4}" // MM/DD/YYYY
        ]
        
        for pattern in patterns {
            if let range = dateString.range(of: pattern, options: .regularExpression) {
                let matched = String(dateString[range])
                if let year = matched.split(separator: "-").first ?? matched.split(separator: "/").last {
                    return String(year)
                }
            }
        }
        
        return dateString
    }
    
    private func extractTrackNumber(_ trackInfo: String) -> String? {
        // Handle formats like "1/12" or just "1"
        let components = trackInfo.split(separator: "/")
        return String(components.first ?? "")
    }
    
    private func extractDiscNumber(_ discInfo: String) -> String? {
        // Handle formats like "1/2" or just "1"
        let components = discInfo.split(separator: "/")
        return String(components.first ?? "")
    }
    
    private func getMimeTypeFromExtension(filePath: String) -> String {
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        
        switch fileExtension {
        case "mp3":
            return "audio/mpeg"
        case "m4a", "m4p", "m4b":
            return "audio/mp4"
        case "aac":
            return "audio/aac"
        case "wav":
            return "audio/wav"
        case "flac":
            return "audio/flac"
        case "ogg":
            return "audio/ogg"
        case "opus":
            return "audio/opus"
        case "aiff", "aif":
            return "audio/aiff"
        case "caf":
            return "audio/x-caf"
        case "3gp", "3gpp":
            return "audio/3gpp"
        case "amr":
            return "audio/amr"
        case "au":
            return "audio/basic"
        default:
            return "audio/mpeg" // Default fallback
        }
    }
    
    private func hasAlbumArt(in asset: AVAsset) -> Bool {
        let artworkMetadata = AVMetadataItem.metadataItems(
            from: asset.commonMetadata,
            filteredByIdentifier: .commonIdentifierArtwork
        )
        
        return !artworkMetadata.isEmpty
    }
    
    private func getAlbumArt(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileURL = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: fileURL)
            
            // Get artwork metadata
            let artworkMetadata = AVMetadataItem.metadataItems(
                from: asset.commonMetadata,
                filteredByIdentifier: .commonIdentifierArtwork
            )
            
            guard let artworkItem = artworkMetadata.first else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            // Extract image data
            if let imageData = artworkItem.dataValue {
                DispatchQueue.main.async {
                    result(FlutterStandardTypedData(bytes: imageData))
                }
            } else if let image = artworkItem.value as? UIImage,
                      let imageData = image.pngData() {
                DispatchQueue.main.async {
                    result(FlutterStandardTypedData(bytes: imageData))
                }
            } else if let image = artworkItem.value as? UIImage,
                      let imageData = image.jpegData(compressionQuality: 1.0) {
                DispatchQueue.main.async {
                    result(FlutterStandardTypedData(bytes: imageData))
                }
            } else {
                // Try to get artwork from value
                if let value = artworkItem.value as? Data {
                    DispatchQueue.main.async {
                        result(FlutterStandardTypedData(bytes: value))
                    }
                } else {
                    DispatchQueue.main.async {
                        result(nil)
                    }
                }
            }
        }
    }
    
    private func getAlbumArtMimeType(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileURL = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: fileURL)
            
            // Get artwork metadata
            let artworkMetadata = AVMetadataItem.metadataItems(
                from: asset.commonMetadata,
                filteredByIdentifier: .commonIdentifierArtwork
            )
            
            guard let artworkItem = artworkMetadata.first,
                  let imageData = artworkItem.dataValue else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            // Detect MIME type from data
            let mimeType = detectMimeType(from: imageData)
            
            DispatchQueue.main.async {
                result(mimeType)
            }
        }
    }
    
    private func detectMimeType(from data: Data) -> String? {
        guard data.count >= 4 else { return nil }
        
        var header = [UInt8](repeating: 0, count: 4)
        data.copyBytes(to: &header, count: 4)
        
        // JPEG: FF D8 FF
        if header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF {
            return "image/jpeg"
        }
        
        // PNG: 89 50 4E 47
        if header[0] == 0x89 && header[1] == 0x50 && 
           header[2] == 0x4E && header[3] == 0x47 {
            return "image/png"
        }
        
        // GIF: 47 49 46 38
        if header[0] == 0x47 && header[1] == 0x49 && 
           header[2] == 0x46 && header[3] == 0x38 {
            return "image/gif"
        }
        
        // BMP: 42 4D
        if header[0] == 0x42 && header[1] == 0x4D {
            return "image/bmp"
        }
        
        // WebP: RIFF....WEBP
        if data.count >= 12 {
            var webpHeader = [UInt8](repeating: 0, count: 12)
            data.copyBytes(to: &webpHeader, count: 12)
            if webpHeader[0] == 0x52 && webpHeader[1] == 0x49 && 
               webpHeader[2] == 0x46 && webpHeader[3] == 0x46 &&
               webpHeader[8] == 0x57 && webpHeader[9] == 0x45 && 
               webpHeader[10] == 0x42 && webpHeader[11] == 0x50 {
                return "image/webp"
            }
        }
        
        // TIFF: 49 49 2A 00 or 4D 4D 00 2A
        if (header[0] == 0x49 && header[1] == 0x49 && header[2] == 0x2A && header[3] == 0x00) ||
           (header[0] == 0x4D && header[1] == 0x4D && header[2] == 0x00 && header[3] == 0x2A) {
            return "image/tiff"
        }
        
        return "image/jpeg" // Default fallback
    }
}

// Helper extension to get data from AVMetadataItem
extension AVMetadataItem {
    var dataValue: Data? {
        guard let value = value else { return nil }
        
        if let data = value as? Data {
            return data
        }
        
        if let string = value as? String,
           let data = Data(base64Encoded: string) {
            return data
        }
        
        if let dict = value as? [String: Any],
           let data = dict["data"] as? Data {
            return data
        }
        
        return nil
    }
}