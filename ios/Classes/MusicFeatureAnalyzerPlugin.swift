import Flutter
import UIKit
import AVFoundation

/// MusicFeatureAnalyzerPlugin - Automatic registration for metadata extraction
public class MusicFeatureAnalyzerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.music_feature_analyzer/audio_metadata",
                                          binaryMessenger: registrar.messenger())
        let instance = MusicFeatureAnalyzerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "verifyConnection" {
            result([
                "connected": true,
                "channelName": "com.music_feature_analyzer/audio_metadata",
                "loadingMode": "PUBLISHED_PACKAGE",
                "handlerSet": true
            ])
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let filePath = args["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
            return
        }

        switch call.method {
        case "getMetadata":
            getMetadata(filePath: filePath, result: result)
        case "getAlbumArt":
            getAlbumArt(filePath: filePath, result: result)
        case "getAlbumArtMimeType":
            getAlbumArtMimeType(filePath: filePath, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getMetadata(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            var metadata: [String: Any?] = [:]
            
            if FileManager.default.fileExists(atPath: filePath) {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? UInt64 {
                    let sizeInt64 = Int64(fileSize)
                    metadata["fileSize"] = sizeInt64 > Int.max ? Int.max : Int(sizeInt64)
                }
            } else {
                metadata["error"] = "File does not exist: \(filePath)"
                metadata["mimeType"] = getMimeTypeFromExtension(URL(fileURLWithPath: filePath).pathExtension.lowercased())
                DispatchQueue.main.async {
                    result(metadata)
                }
                return
            }
            
            let url = URL(fileURLWithPath: filePath)
            let audioAsset = AVAsset(url: url)
            
            let pathExtension = url.pathExtension.lowercased()
            metadata["mimeType"] = getMimeTypeFromExtension(pathExtension)
            
            guard audioAsset.isReadable else {
                metadata["error"] = "Asset is not readable: \(filePath)"
                DispatchQueue.main.async {
                    result(metadata)
                }
                return
            }

            for item in audioAsset.metadata {
                guard let key = item.commonKey?.rawValue,
                      let value = item.value else { continue }

                switch key {
                case "title":
                    metadata["title"] = value as? String
                case "artist":
                    metadata["artist"] = value as? String
                case "albumName":
                    metadata["album"] = value as? String
                case "albumArtist":
                    metadata["albumArtist"] = value as? String
                case "type":
                    metadata["genre"] = value as? String
                case "creationDate":
                    if let date = value as? Date {
                        let year = Calendar.current.component(.year, from: date)
                        metadata["year"] = String(year)
                    }
                case "composer":
                    metadata["composer"] = value as? String
                case "writer":
                    metadata["writer"] = value as? String
                default:
                    break
                }
            }

            if let trackNumber = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == "trackNumber" })?.value as? NSNumber {
                metadata["trackNumber"] = trackNumber.stringValue
            }

            if let discNumber = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == "discNumber" })?.value as? NSNumber {
                metadata["discNumber"] = discNumber.stringValue
            }

            let duration = audioAsset.duration
            let durationSeconds = CMTimeGetSeconds(duration)
            if durationSeconds.isFinite && durationSeconds > 0 {
                metadata["duration"] = Int(durationSeconds * 1000)
            }

            let artwork = audioAsset.metadata.first(where: { $0.commonKey?.rawValue == "artwork" })
            metadata["hasAlbumArt"] = artwork != nil

            DispatchQueue.main.async {
                result(metadata)
            }
        }
    }
    
    private func getMimeTypeFromExtension(_ extension: String) -> String {
        switch extension {
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
        case "wma":
            return "audio/x-ms-wma"
        case "opus":
            return "audio/opus"
        case "aiff", "aif":
            return "audio/aiff"
        case "alac":
            return "audio/alac"
        case "amr":
            return "audio/amr"
        case "3ga":
            return "audio/3gpp"
        default:
            return "audio/mpeg" // Default fallback
        }
    }

    private func getAlbumArt(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard FileManager.default.fileExists(atPath: filePath) else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            let url = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: url)
            
            guard asset.isReadable else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }

            guard let artwork = asset.metadata.first(where: { $0.commonKey?.rawValue == "artwork" }),
                  let imageData = artwork.value as? Data else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }

            DispatchQueue.main.async {
                result(FlutterStandardTypedData(bytes: imageData))
            }
        }
    }

    private func getAlbumArtMimeType(filePath: String, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard FileManager.default.fileExists(atPath: filePath) else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            let url = URL(fileURLWithPath: filePath)
            let asset = AVAsset(url: url)
            
            guard asset.isReadable else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }

            guard let artwork = asset.metadata.first(where: { $0.commonKey?.rawValue == "artwork" }),
                  let imageData = artwork.value as? Data else {
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }

            var mimeType: String = "image/jpeg"
            if imageData.count >= 4 {
                let bytes = [UInt8](imageData.prefix(12))
                if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
                    mimeType = "image/jpeg"
                } else if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
                    mimeType = "image/png"
                } else if bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x38 {
                    mimeType = "image/gif"
                } else if bytes.count >= 12 && bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
                    bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50 {
                    mimeType = "image/webp"
                } else if bytes[0] == 0x42 && bytes[1] == 0x4D {
                    mimeType = "image/bmp"
                }
            }
            
            DispatchQueue.main.async {
                result(mimeType)
            }
        }
    }
}
