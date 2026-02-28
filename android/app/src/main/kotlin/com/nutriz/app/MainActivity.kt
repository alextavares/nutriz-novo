package com.nutriz.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  companion object {
    private const val CHANNEL_NAME = "com.nutriz.app/notifications"
    private const val SHARE_CHANNEL = "com.nutriz.app/share"
    private const val REQUEST_CODE_NOTIFICATIONS = 7451
  }

  private var pendingPermissionResult: MethodChannel.Result? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "requestPermission" -> requestNotificationsPermission(result)
          else -> result.notImplemented()
        }
      }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL)
      .setMethodCallHandler { call, result ->
        val text = call.argument<String>("text") ?: ""
        when (call.method) {
          "shareText" -> {
            result.success(shareText(text))
          }
          "shareWhatsApp" -> {
            result.success(shareWhatsApp(text))
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun requestNotificationsPermission(result: MethodChannel.Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
      result.success(true)
      return
    }

    val granted = ContextCompat.checkSelfPermission(
      this,
      Manifest.permission.POST_NOTIFICATIONS
    ) == PackageManager.PERMISSION_GRANTED

    if (granted) {
      result.success(true)
      return
    }

    if (pendingPermissionResult != null) {
      result.success(false)
      return
    }

    pendingPermissionResult = result
    ActivityCompat.requestPermissions(
      this,
      arrayOf(Manifest.permission.POST_NOTIFICATIONS),
      REQUEST_CODE_NOTIFICATIONS
    )
  }

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<String>,
    grantResults: IntArray
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    if (requestCode != REQUEST_CODE_NOTIFICATIONS) return

    val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
    pendingPermissionResult?.success(granted)
    pendingPermissionResult = null
  }

  private fun shareText(text: String): Boolean {
    if (text.isBlank()) return false

    return try {
      val sendIntent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_TEXT, text)
      }
      val chooser = Intent.createChooser(sendIntent, "Compartilhar")
      startActivity(chooser)
      true
    } catch (e: Exception) {
      false
    }
  }

  private fun shareWhatsApp(text: String): Boolean {
    if (text.isBlank()) return false

    val packages = listOf("com.whatsapp", "com.whatsapp.w4b")
    val chosen = packages.firstOrNull { pkg ->
      try {
        packageManager.getPackageInfo(pkg, 0)
        true
      } catch (_: Exception) {
        false
      }
    } ?: return false

    return try {
      val sendIntent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_TEXT, text)
        setPackage(chosen)
      }
      startActivity(sendIntent)
      true
    } catch (e: Exception) {
      false
    }
  }
}
