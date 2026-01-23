package com.music_feature_analyzer

import android.content.Context
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class MusicFeatureAnalyzerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private val handler = Handler(Looper.getMainLooper())
    private val TAG = "MusicFeatureAnalyzer"
    private var applicationContext: Context? = null

    // Fixed: Add comprehensive loading mode detection
    enum class LoadingMode {
        PUBLISHED_PACKAGE,
        LOCAL_PATH,
        UNKNOWN
    }

    private fun detectLoadingMode(): LoadingMode {
        return try {
            // Check if we're in development (app running from IDE)
            val isDebuggable = (applicationContext?.applicationInfo?.flags ?: 0) and 
                               android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0
            
            // Check code source location
            val codeSource = this::class.java.protectionDomain?.codeSource?.location
            val path = codeSource?.path ?: ""
            
            Log.d(TAG, "Loading mode detection - Path: $path, Debuggable: $isDebuggable")
            
            // Check for published package indicators
            val isPublished = path.contains(".gradle") ||
                             path.contains("pub-cache") ||
                             path.contains(".pub-cache") ||
                             path.contains("/.pub-cache/") ||
                             path.contains("/flutter/.pub-cache/")
            
            return if (isPublished) {
                Log.i(TAG, "Loading mode: PUBLISHED_PACKAGE")
                LoadingMode.PUBLISHED_PACKAGE
            } else {
                Log.i(TAG, "Loading mode: LOCAL_PATH or DEVELOPMENT")
                LoadingMode.LOCAL_PATH
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not detect loading mode: ${e.message}")
            LoadingMode.UNKNOWN
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        try {
            applicationContext = flutterPluginBinding.applicationContext
            
            // Create method channel
            channel = MethodChannel(
                flutterPluginBinding.binaryMessenger,
                "com.music_feature_analyzer/audio_metadata"
            )
            channel.setMethodCallHandler(this)
            
            Log.i(TAG, "✅ MusicFeatureAnalyzerPlugin attached to engine")
            Log.d(TAG, "Loading mode detected: ${detectLoadingMode()}")
        } catch (e: Exception) {
            Log.e(TAG, "Error attaching plugin: ${e.message}", e)
            throw e
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        Log.i(TAG, "MusicFeatureAnalyzerPlugin detached from engine")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        // FIXED: Handle verifyConnection first
        if (call.method == "verifyConnection") {
            val loadingMode = detectLoadingMode()
            val response = mapOf(
                "connected" to true,
                "channelName" to "com.music_feature_analyzer/audio_metadata",
                "loadingMode" to loadingMode.name,
                "handlerSet" to ::channel.isInitialized,
                "platform" to "Android",
                "pluginVersion" to "1.0.1-beta-04"
            )
            result.success(response)
            Log.d(TAG, "verifyConnection response: $response")
            return
        }
        
        val path = call.argument<String>("path")
        if (path == null) {
            result.error("INVALID_ARGUMENT", "File path is required", null)
            return
        }

        when (call.method) {
            "getMetadata" -> getMetadata(path, result)
            "getAlbumArt" -> getAlbumArt(path, result)
            "getAlbumArtMimeType" -> getAlbumArtMimeType(path, result)
            else -> result.notImplemented()
        }
    }

    private fun getMetadata(filePath: String, result: Result) {
        Thread {
            val retriever = MediaMetadataRetriever()
            val metadata = mutableMapOf<String, Any?>()

            try {
                val file = File(filePath)
                if (file.exists()) {
                    val fileSizeLong = file.length()
                    metadata["fileSize"] = if (fileSizeLong > Int.MAX_VALUE) Int.MAX_VALUE else fileSizeLong.toInt()
                } else {
                    metadata["error"] = "File does not exist: $filePath"
                    handler.post { result.success(metadata) }
                    return@Thread
                }

                var dataSourceSet = false
                try {
                    retriever.setDataSource(filePath)
                    dataSourceSet = true
                } catch (e: IllegalArgumentException) {
                    try {
                        retriever.setDataSource(file.absolutePath)
                        dataSourceSet = true
                    } catch (e2: Exception) {
                        retriever.release()
                        metadata["error"] = "IllegalArgumentException in setDataSource: ${e2.message}"
                        metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                        handler.post { result.success(metadata) }
                        return@Thread
                    }
                } catch (e: RuntimeException) {
                    retriever.release()
                    metadata["error"] = "RuntimeException in setDataSource: ${e.message}"
                    metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                    handler.post { result.success(metadata) }
                    return@Thread
                }

                if (!dataSourceSet) {
                    retriever.release()
                    metadata["error"] = "Failed to set data source"
                    metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                    handler.post { result.success(metadata) }
                    return@Thread
                }

                try {
                    val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
                    metadata["title"] = if (title == null || title == "null") null else title
                    
                    val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
                    metadata["artist"] = if (artist == null || artist == "null") null else artist
                    
                    val album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
                    metadata["album"] = if (album == null || album == "null") null else album
                    
                    val albumArtist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)
                    metadata["albumArtist"] = if (albumArtist == null || albumArtist == "null") null else albumArtist
                    
                    val genre = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE)
                    metadata["genre"] = if (genre == null || genre == "null") null else genre
                    
                    val year = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)
                    metadata["year"] = if (year == null || year == "null") null else year
                    
                    val composer = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COMPOSER)
                    metadata["composer"] = if (composer == null || composer == "null") null else composer
                    
                    val writer = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_WRITER)
                    metadata["writer"] = if (writer == null || writer == "null") null else writer
                    
                    val trackNumber = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
                    metadata["trackNumber"] = if (trackNumber == null || trackNumber == "null") null else trackNumber
                    
                    val discNumber = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER)
                    metadata["discNumber"] = if (discNumber == null || discNumber == "null") null else discNumber

                    val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                    metadata["duration"] = durationStr?.toLongOrNull()

                    val bitrateStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
                    metadata["bitrate"] = bitrateStr?.toIntOrNull()

                    val mimeType = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)
                    metadata["mimeType"] = if (mimeType != null && mimeType != "null" && mimeType.isNotEmpty()) {
                        mimeType
                    } else {
                        getMimeTypeFromExtension(filePath)
                    }

                    val embeddedPicture = retriever.embeddedPicture
                    metadata["hasAlbumArt"] = embeddedPicture != null && embeddedPicture.isNotEmpty()
                } catch (e: Exception) {
                    metadata["error"] = "Exception during metadata extraction: ${e.message}"
                    metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                }

                retriever.release()
                handler.post { result.success(metadata) }
            } catch (e: Exception) {
                try {
                    retriever.release()
                } catch (ex: Exception) {
                }
                metadata["error"] = "Exception in getMetadata: ${e.javaClass.simpleName}: ${e.message}"
                if (!metadata.containsKey("mimeType")) {
                    metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                }
                handler.post { result.success(metadata) }
            }
        }.start()
    }

    private fun getMimeTypeFromExtension(filePath: String): String {
        val extension = filePath.substringAfterLast('.', "").lowercase()
        return when (extension) {
            "mp3" -> "audio/mpeg"
            "m4a", "m4p" -> "audio/mp4"
            "aac" -> "audio/aac"
            "wav" -> "audio/wav"
            "flac" -> "audio/flac"
            "ogg" -> "audio/ogg"
            "wma" -> "audio/x-ms-wma"
            "opus" -> "audio/opus"
            "aiff", "aif" -> "audio/aiff"
            "alac" -> "audio/alac"
            "m4b" -> "audio/mp4"
            "amr" -> "audio/amr"
            "3ga" -> "audio/3gpp"
            else -> "audio/mpeg" // Default fallback
        }
    }

    private fun getAlbumArt(filePath: String, result: Result) {
        Thread {
            val retriever = MediaMetadataRetriever()
            try {
                val file = File(filePath)
                if (!file.exists()) {
                    retriever.release()
                    handler.post { result.success(null) }
                    return@Thread
                }

                try {
                    retriever.setDataSource(filePath)
                } catch (e: Exception) {
                    retriever.release()
                    handler.post { result.success(null) }
                    return@Thread
                }
                
                val art = retriever.embeddedPicture
                if (art == null || art.isEmpty()) {
                    retriever.release()
                    handler.post { result.success(null) }
                    return@Thread
                }

                retriever.release()
                handler.post { result.success(art) }
            } catch (e: Exception) {
                try {
                    retriever.release()
                } catch (ex: Exception) {
                }
                handler.post { result.success(null) }
            }
        }.start()
    }

    private fun getAlbumArtMimeType(filePath: String, result: Result) {
        Thread {
            val retriever = MediaMetadataRetriever()
            try {
                val file = File(filePath)
                if (!file.exists()) {
                    retriever.release()
                    handler.post { result.success(null) }
                    return@Thread
                }
                
                try {
                    retriever.setDataSource(filePath)
                } catch (e: Exception) {
                    retriever.release()
                    handler.post { result.success(null) }
                    return@Thread
                }
                
                val art = retriever.embeddedPicture
                retriever.release()

                if (art != null && art.size >= 4) {
                    val mimeType = when {
                        art[0] == 0xFF.toByte() && art[1] == 0xD8.toByte() && art[2] == 0xFF.toByte() -> "image/jpeg"
                        art[0] == 0x89.toByte() && art[1] == 0x50.toByte() &&
                                art[2] == 0x4E.toByte() && art[3] == 0x47.toByte() -> "image/png"
                        art[0] == 0x47.toByte() && art[1] == 0x49.toByte() &&
                                art[2] == 0x46.toByte() && art[3] == 0x38.toByte() -> "image/gif"
                        art.size >= 12 && art[0] == 0x52.toByte() && art[1] == 0x49.toByte() &&
                                art[2] == 0x46.toByte() && art[3] == 0x46.toByte() &&
                                art[8] == 0x57.toByte() && art[9] == 0x45.toByte() &&
                                art[10] == 0x42.toByte() && art[11] == 0x50.toByte() -> "image/webp"
                        art[0] == 0x42.toByte() && art[1] == 0x4D.toByte() -> "image/bmp"
                        else -> "image/jpeg"
                    }
                    handler.post { result.success(mimeType) }
                } else {
                    handler.post { result.success(null) }
                }
            } catch (e: Exception) {
                try {
                    retriever.release()
                } catch (ex: Exception) {
                }
                handler.post { result.success(null) }
            }
        }.start()
    }
}
