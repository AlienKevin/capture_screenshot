package li.kevinx.capture_screenshot

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.annotation.RequiresApi
import im.zego.media_projection_creator.MediaProjectionCreatorCallback
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong


/** MediaProjectionScreenshotPlugin */
class CaptureScreenshotPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var methodChannel: MethodChannel
  private lateinit var context: Context
  private var events: EventChannel.EventSink? = null

  private var mediaProjection: MediaProjection? = null

  private var mVirtualDisplay: VirtualDisplay? = null
  private var mImageReader: ImageReader? = null

  companion object {
    const val LOG_TAG = "MP_SCREENSHOT"
    const val CAPTURE_SINGLE = "MP_CAPTURE_SINGLE"
    const val METHOD_CHANNEL_NAME = "li.kevinx.capture_screenshot/method"
    const val EVENT_CHANNEL_NAME = "li.kevinx.capture_screenshot/event"
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
    methodChannel.setMethodCallHandler(this)

    EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME).setStreamHandler(this)

    context = flutterPluginBinding.applicationContext

    RequestMediaProjectionPermissionManager.getInstance().setRequestPermissionCallback(mediaProjectionCreatorCallback)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "captureScreenshot" -> {
        captureImage(call, result)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
  }


  override fun onListen(arguments: Any?, es: EventChannel.EventSink?) {
    events = es
  }

  override fun onCancel(arguments: Any?) {}

  private val mediaProjectionCreatorCallback = MediaProjectionCreatorCallback { projection, errorCode ->
    when (errorCode) {
      RequestMediaProjectionPermissionManager.ERROR_CODE_SUCCEED -> {
        Log.i(LOG_TAG, "Create media projection succeeded!")
        mediaProjection = projection
      }

      RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_USER_CANCELED -> {
        Log.e(LOG_TAG, "Create media projection failed because can not get permission")
      }

      RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW -> {
        Log.e(LOG_TAG, "Create media projection failed because system api level is lower than 21")
      }
    }
  }

  @SuppressLint("WrongConstant")
  private fun captureImage(call: MethodCall, result: Result) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      result.error(LOG_TAG, "Create media projection failed because system api level is lower than 21", null)
      return
    }

    if (mediaProjection == null) {
      result.error(LOG_TAG, "Must request permission before take capture", null)
      return
    }

    val metrics = Resources.getSystem().displayMetrics
    val width = metrics.widthPixels
    val height = metrics.heightPixels

    val imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 5)

    mediaProjection?.createVirtualDisplay(
      CAPTURE_SINGLE,
      width,
      height,
      1,
      DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
      imageReader.surface,
      null,
      null,
    )

    val delayInMilliseconds = call.argument<Int>("delayInMilliseconds") ?: 100;

    Handler(Looper.getMainLooper()).postDelayed({
      val image = imageReader.acquireLatestImage() ?: return@postDelayed

      val planes = image.planes
      val buffer = planes[0].buffer
      val pixelStride = planes[0].pixelStride
      val rowStride = planes[0].rowStride
      val rowPadding = rowStride - pixelStride * width
      val padding = rowPadding / pixelStride

      var bitmap = Bitmap.createBitmap(width + padding, height, Bitmap.Config.ARGB_8888)
      bitmap.copyPixelsFromBuffer(buffer)

      image.close()
      mVirtualDisplay?.release()

      val outputStream = ByteArrayOutputStream()
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)

      val byteArray = outputStream.toByteArray()
      // val b64 = "data:image/png;base64," + Base64.encodeToString(byteArray, Base64.NO_WRAP)
      // Log.i(LOG_TAG, "base64 = $b64")

      result.success(
        byteArray
      )
    }, delayInMilliseconds.toLong())
  }
}
