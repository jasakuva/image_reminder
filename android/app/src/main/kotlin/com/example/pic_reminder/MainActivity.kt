package com.example.pic_reminder

import android.content.Intent
import android.net.Uri
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "ImageReminderShare"
    }

    private val sharedImageChannelName = "com.example.pic_reminder/shared_images"
    private var sharedImageChannel: MethodChannel? = null
    private var pendingSharedImagePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sharedImageChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            sharedImageChannelName
        )

        sharedImageChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharedImage" -> {
                    val imagePath = pendingSharedImagePath ?: extractSharedImagePath(intent)
                    pendingSharedImagePath = null
                    result.success(imagePath)
                }
                else -> result.notImplemented()
            }
        }

        pendingSharedImagePath = extractSharedImagePath(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val sharedImagePath = extractSharedImagePath(intent)
        if (sharedImagePath == null) {
            return
        }

        pendingSharedImagePath = sharedImagePath
        sharedImageChannel?.invokeMethod("sharedImageReceived", sharedImagePath)
    }

    private fun extractSharedImagePath(intent: Intent?): String? {
        if (intent == null ||
            (intent.action != Intent.ACTION_SEND && intent.action != Intent.ACTION_SEND_MULTIPLE)
        ) {
            return null
        }

        val type = intent.type?.takeIf { it.startsWith("image/") } ?: "image/*"
        val imageUri = when (intent.action) {
            Intent.ACTION_SEND -> intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
                ?: intent.clipData?.getItemAt(0)?.uri
            Intent.ACTION_SEND_MULTIPLE -> intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
                ?.firstOrNull()
                ?: intent.clipData?.getItemAt(0)?.uri
            else -> null
        }

        if (imageUri == null) {
            Log.w(TAG, "Share intent did not contain an image URI: action=${intent.action}, type=${intent.type}")
            return null
        }

        // Copy immediately while the sender's temporary read permission is valid.
        Log.d(TAG, "Received shared image URI: $imageUri, type=$type")
        return copySharedImageToAppStorage(imageUri, type)
    }

    private fun copySharedImageToAppStorage(uri: Uri, mimeType: String): String? {
        return try {
            val extension = MimeTypeMap.getSingleton()
                .getExtensionFromMimeType(mimeType)
                ?.takeIf { it.isNotBlank() }
                ?: "jpg"
            val sharedImagesDir = File(filesDir, "shared_images")
            if (!sharedImagesDir.exists()) {
                sharedImagesDir.mkdirs()
            }
            val outputFile = File(
                sharedImagesDir,
                "shared_image_${System.currentTimeMillis()}.$extension"
            )

            contentResolver.openInputStream(uri)?.use { inputStream ->
                FileOutputStream(outputFile).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            } ?: return null.also {
                Log.w(TAG, "Could not open shared image URI: $uri")
            }

            Log.d(TAG, "Copied shared image to: ${outputFile.absolutePath}")
            outputFile.absolutePath
        } catch (error: Exception) {
            Log.e(TAG, "Failed to copy shared image URI: $uri", error)
            null
        }
    }
}
