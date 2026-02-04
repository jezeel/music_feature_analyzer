//
// MusicFeatureAnalyzerPlugin.swift
//
// Flutter plugin for native audio metadata on iOS (AVFoundation).
// Registration: Flutter discovers this plugin via pubspec.yaml (flutter.plugin.platforms.ios.pluginClass)
// and calls register(with:) automatically — no manual AppDelegate changes needed.
//

import Flutter
import UIKit
import AVFoundation

public class MusicFeatureAnalyzerPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?

    /// Called by Flutter's generated plugin registrant when the app starts.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.music_feature_analyzer/audio_metadata",
            binaryMessenger: registrar.messenger()
        )
        let instance = MusicFeatureAnalyzerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "verifyConnection" {
            let response: [String: Any] = [
                "connected": true,
                "channelName": "com.music_feature_analyzer/audio_metadata",
                "loadingMode": "IOS_PLATFORM",
                "handlerSet": channel != nil,
                "platform": "iOS",
                "pluginVersion": "1.0.3"
            ]
            result(response)
            return
        }

        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String,
              !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
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

            do {
                let fileManager = FileManager.default
                guard fileManager.fileExists(atPath: filePath) else {
                    metadata["error"] = "File does not exist: \(filePath)"
                    metadata["mimeType"] = self.getMimeTypeFromExtension(filePath: filePath)
                    DispatchQueue.main.async { result(metadata) }
                    return
                }

                do {
                    if let fileSize = try fileManager.attributesOfItem(atPath: filePath)[.size] as? UInt64 {
                        metadata["fileSize"] = Int(min(fileSize, UInt64(Int32.max)))
                    }
                } catch {
                    metadata["fileSize"] = nil
                }

                let fileURL = URL(fileURLWithPath: filePath)
                let asset = AVAsset(url: fileURL)

                let duration = asset.duration
                let durationInSeconds = CMTimeGetSeconds(duration)
                if durationInSeconds.isFinite && !durationInSeconds.isNaN && durationInSeconds >= 0 {
                    metadata["duration"] = Int64(durationInSeconds * 1000)
                } else {
                    metadata["duration"] = nil
                }

                let common = self.extractCommonMetadata(from: asset)
                metadata.merge(self.sanitizeMetadata(common)) { _, new in new }

                // estimatedDataRate is in bits/sec; convert to kbps for Dart contract
                if let track = asset.tracks(withMediaType: .audio).first {
                    let bps = track.estimatedDataRate
                    metadata["bitrate"] = bps > 0 ? Int(bps / 1000) : nil
                }

                metadata["mimeType"] = self.getMimeTypeFromExtension(filePath: filePath)
                metadata["hasAlbumArt"] = self.hasAlbumArt(in: asset)

                DispatchQueue.main.async { result(metadata) }
            } catch {
                metadata["error"] = "Exception in getMetadata: \(error.localizedDescription)"
                if metadata["mimeType"] == nil {
                    metadata["mimeType"] = self.getMimeTypeFromExtension(filePath: filePath)
                }
                DispatchQueue.main.async { result(metadata) }
            }
        }
    }

    private func extractCommonMetadata(from asset: AVAsset) -> [String: Any?] {
        var metadata: [String: Any?] = [:]
        let commonMetadata = asset.commonMetadata

        for item in commonMetadata {
            guard let key = item.commonKey?.rawValue else { continue }
            let value = item.stringValue

            switch key {
            case AVMetadataKey.commonKeyTitle.rawValue:
                metadata["title"] = value
            case AVMetadataKey.commonKeyArtist.rawValue:
                metadata["artist"] = value
            case AVMetadataKey.commonKeyAlbumName.rawValue:
                metadata["album"] = value
            case "TPE2", AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue:
                metadata["albumArtist"] = value
            case AVMetadataKey.commonKeyType.rawValue:
                if metadata["genre"] == nil { metadata["genre"] = value }
            case AVMetadataKey.id3MetadataKeyContentType.rawValue,
                 AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue:
                metadata["genre"] = value
            case AVMetadataKey.commonKeyCreationDate.rawValue,
                 AVMetadataKey.id3MetadataKeyYear.rawValue:
                if let yearString = value {
                    metadata["year"] = extractYearFromString(yearString)
                    metadata["date"] = yearString
                }
            case AVMetadataKey.commonKeyCreator.rawValue,
                 AVMetadataKey.id3MetadataKeyComposer.rawValue:
                metadata["composer"] = value
            case "TEXT":
                metadata["writer"] = value
            case AVMetadataKey.id3MetadataKeyTrackNumber.rawValue:
                if let trackInfo = value { metadata["trackNumber"] = extractTrackNumber(trackInfo) }
            case "TPOS", AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue:
                if let discInfo = value { metadata["discNumber"] = extractDiscNumber(discInfo) }
            default:
                break
            }
        }

        for format in asset.availableMetadataFormats {
            let items = asset.metadata(forFormat: format)
            for item in items {
                if item.key as? String == AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue,
                   metadata["genre"] == nil {
                    metadata["genre"] = item.stringValue
                }
            }
        }

        return metadata
    }

    /// Sanitize string values: treat "null" or empty as nil (matches Android behavior).
    private func sanitizeMetadata(_ metadata: [String: Any?]) -> [String: Any?] {
        var out: [String: Any?] = [:]
        for (key, value) in metadata {
            if let s = value as? String, (s.isEmpty || s == "null") {
                out[key] = nil
            } else {
                out[key] = value
            }
        }
        return out
    }

    private func extractYearFromString(_ dateString: String) -> String? {
        if let range = dateString.range(of: "\\d{4}", options: .regularExpression) {
            return String(dateString[range])
        }
        let parts = dateString.split(separator: "-")
        if let first = parts.first, first.count == 4 { return String(first) }
        let partsSlash = dateString.split(separator: "/")
        if let last = partsSlash.last, last.count == 4 { return String(last) }
        return dateString.isEmpty ? nil : dateString
    }

    private func extractTrackNumber(_ trackInfo: String) -> String? {
        let parts = trackInfo.split(separator: "/")
        guard let first = parts.first else { return nil }
        return String(first).isEmpty ? nil : String(first)
    }

    private func extractDiscNumber(_ discInfo: String) -> String? {
        let parts = discInfo.split(separator: "/")
        guard let first = parts.first else { return nil }
        return String(first).isEmpty ? nil : String(first)
    }

    private func getMimeTypeFromExtension(filePath: String) -> String {
        let ext = (filePath as NSString).pathExtension.lowercased()
        switch ext {
        case "mp3": return "audio/mpeg"
        case "m4a", "m4p", "m4b": return "audio/mp4"
        case "aac": return "audio/aac"
        case "wav": return "audio/wav"
        case "flac": return "audio/flac"
        case "ogg": return "audio/ogg"
        case "opus": return "audio/opus"
        case "aiff", "aif": return "audio/aiff"
        case "caf": return "audio/x-caf"
        case "3gp", "3gpp": return "audio/3gpp"
        case "amr": return "audio/amr"
        case "au": return "audio/basic"
        case "wma": return "audio/x-ms-wma"
        default: return "audio/mpeg"
        }
    }

    private func hasAlbumArt(in asset: AVAsset) -> Bool {
        let items = AVMetadataItem.metadataItems(
            from: asset.commonMetadata,
            filteredByIdentifier: .commonIdentifierArtwork
        )
        return !items.isEmpty
    }

    private func getAlbumArt(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: filePath) else {
                DispatchQueue.main.async { result(nil) }
                return
            }

            let fileURL = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: fileURL)
            let artworkMetadata = AVMetadataItem.metadataItems(
                from: asset.commonMetadata,
                filteredByIdentifier: .commonIdentifierArtwork
            )

            guard let artworkItem = artworkMetadata.first else {
                DispatchQueue.main.async { result(nil) }
                return
            }

            if let imageData = artworkItem.dataValue {
                DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: imageData)) }
            } else if let image = artworkItem.value as? UIImage, let data = image.pngData() {
                DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: data)) }
            } else if let image = artworkItem.value as? UIImage, let data = image.jpegData(compressionQuality: 1.0) {
                DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: data)) }
            } else if let value = artworkItem.value as? Data {
                DispatchQueue.main.async { result(FlutterStandardTypedData(bytes: value)) }
            } else {
                DispatchQueue.main.async { result(nil) }
            }
        }
    }

    private func getAlbumArtMimeType(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: filePath) else {
                DispatchQueue.main.async { result(nil) }
                return
            }

            let fileURL = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: fileURL)
            let artworkMetadata = AVMetadataItem.metadataItems(
                from: asset.commonMetadata,
                filteredByIdentifier: .commonIdentifierArtwork
            )

            guard let artworkItem = artworkMetadata.first,
                  let imageData = artworkItem.dataValue else {
                DispatchQueue.main.async { result(nil) }
                return
            }

            let mimeType = self.detectMimeType(from: imageData)
            DispatchQueue.main.async { result(mimeType) }
        }
    }

    private func detectMimeType(from data: Data) -> String? {
        guard data.count >= 4 else { return nil }
        var header = [UInt8](repeating: 0, count: 4)
        data.copyBytes(to: &header, count: 4)

        if header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF { return "image/jpeg" }
        if header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47 { return "image/png" }
        if header[0] == 0x47 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x38 { return "image/gif" }
        if header[0] == 0x42 && header[1] == 0x4D { return "image/bmp" }
        if data.count >= 12 {
            var webp = [UInt8](repeating: 0, count: 12)
            data.copyBytes(to: &webp, count: 12)
            if webp[0] == 0x52 && webp[1] == 0x49 && webp[2] == 0x46 && webp[3] == 0x46 &&
               webp[8] == 0x57 && webp[9] == 0x45 && webp[10] == 0x42 && webp[11] == 0x50 {
                return "image/webp"
            }
        }
        if (header[0] == 0x49 && header[1] == 0x49 && header[2] == 0x2A && header[3] == 0x00) ||
           (header[0] == 0x4D && header[1] == 0x4D && header[2] == 0x00 && header[3] == 0x2A) {
            return "image/tiff"
        }
        return "image/jpeg"
    }
}

// MARK: - AVMetadataItem data extraction (artwork as Data)
extension AVMetadataItem {
    var dataValue: Data? {
        guard let value = value else { return nil }
        if let data = value as? Data { return data }
        if let string = value as? String, let data = Data(base64Encoded: string) { return data }
        if let dict = value as? [String: Any], let data = dict["data"] as? Data { return data }
        return nil
    }
}
