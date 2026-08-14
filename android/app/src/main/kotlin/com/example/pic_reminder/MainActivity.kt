package com.example.pic_reminder

import android.content.Intent
import android.net.Uri
import android.webkit.MimeTypeMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
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
        if (intent?.action != Intent.ACTION_SEND) {
            return null
        }

        val type = intent.type ?: return null
        if (!type.startsWith("image/")) {
            return null
        }

        val imageUri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM) ?: return null
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
            } ?: return null

            outputFile.absolutePath
        } catch (_: Exception) {
            null
        }
    }
}
