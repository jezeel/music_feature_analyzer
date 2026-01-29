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
import java.util.concurrent.Executors

/** MusicFeatureAnalyzerPlugin */
class MusicFeatureAnalyzerPlugin : FlutterPlugin, MethodCallHandler {
    private val TAG = "MusicFeatureAnalyzerPlugin"
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executors.newCachedThreadPool()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine: Attaching MusicFeatureAnalyzerPlugin")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.music_feature_analyzer/audio_metadata")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        Log.i(TAG, "onAttachedToEngine: Channel initialized")
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "verifyConnection") {
            // Log that we received the verification call
            Log.i(TAG, "verifyConnection: Received verification request")
            
            val loadingMode = detectLoadingMode()
            val response = mapOf(
                "connected" to true,
                "channelName" to "com.music_feature_analyzer/audio_metadata",
                "loadingMode" to loadingMode.name,
                "handlerSet" to true,
                "platform" to "Android",
                "pluginVersion" to "1.0.1-beta-07"
            )
            result.success(response)
            Log.i(TAG, "verifyConnection: Responded success")
            return
        }

        val path = call.argument<String>("path")
        if (path == null) {
            result.error("INVALID_ARGUMENT", "File path is required", null)
            return
        }

        when (call.method) {
            "getMetadata" -> executor.execute { getMetadata(path, result) }
            "getAlbumArt" -> executor.execute { getAlbumArt(path, result) }
            "getAlbumArtMimeType" -> executor.execute { getAlbumArtMimeType(path, result) }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onDetachedFromEngine: Detaching MusicFeatureAnalyzerPlugin")
        channel.setMethodCallHandler(null)
    }

    private fun getMetadata(filePath: String, result: Result) {
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
                return
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
                    try {
                        retriever.release()
                    } catch (ignore: Exception) {}
                    metadata["error"] = "IllegalArgumentException in setDataSource: ${e2.message}"
                    metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                    handler.post { result.success(metadata) }
                    return
                }
            } catch (e: RuntimeException) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                metadata["error"] = "RuntimeException in setDataSource: ${e.message}"
                metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                handler.post { result.success(metadata) }
                return
            }

            if (!dataSourceSet) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                metadata["error"] = "Failed to set data source"
                metadata["mimeType"] = getMimeTypeFromExtension(filePath)
                handler.post { result.success(metadata) }
                return
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
                val date = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DATE)
                metadata["date"] = if (date == null || date == "null") null else date
                
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

                // METADATA_KEY_BITRATE is in bits/sec; convert to kbps for Dart contract
                val bitrateStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
                val bps = bitrateStr?.toLongOrNull()
                metadata["bitrate"] = if (bps != null && bps > 0) (bps / 1000).toInt() else null

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

            try {
                retriever.release()
            } catch (ignore: Exception) {}
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
        val retriever = MediaMetadataRetriever()
        try {
            val file = File(filePath)
            if (!file.exists()) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                handler.post { result.success(null) }
                return
            }

            try {
                retriever.setDataSource(filePath)
            } catch (e: Exception) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                handler.post { result.success(null) }
                return
            }
            
            val art = retriever.embeddedPicture
            if (art == null || art.isEmpty()) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                handler.post { result.success(null) }
                return
            }

            try {
                retriever.release()
            } catch (ignore: Exception) {}
            handler.post { result.success(art) }
        } catch (e: Exception) {
            try {
                retriever.release()
            } catch (ex: Exception) {
            }
            handler.post { result.success(null) }
        }
    }

    private fun getAlbumArtMimeType(filePath: String, result: Result) {
        val retriever = MediaMetadataRetriever()
        try {
            val file = File(filePath)
            if (!file.exists()) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                handler.post { result.success(null) }
                return
            }
            
            try {
                retriever.setDataSource(filePath)
            } catch (e: Exception) {
                try {
                    retriever.release()
                } catch (ignore: Exception) {}
                handler.post { result.success(null) }
                return
            }
            
            val art = retriever.embeddedPicture
            try {
                retriever.release()
            } catch (ignore: Exception) {}

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
    }
    
    // Enum for loading detection
    enum class LoadingMode {
        PUBLISHED_PACKAGE,
        LOCAL_PATH,
        UNKNOWN
    }
    
    private fun detectLoadingMode(): LoadingMode {
        // Simple placeholder as reliable detection is complex and not strictly necessary for functionality
        return LoadingMode.UNKNOWN
    }
}
