package com.kingoapps.photo_route

import io.flutter.embedding.android.FlutterActivity

import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Application
import android.content.Context
import android.os.BatteryManager;

import androidx.work.WorkRequest;
import com.kingoapps.photo_route.upload_process.UploadWorker;
import com.kingoapps.photo_route.upload_process.FlutterTask;
import 	androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager;

import androidx.work.Data

import io.flutter.view.FlutterMain;
import io.flutter.embedding.engine.dart.DartExecutor;

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.kingoapps.photo_route/background"
     private var mCallbackDispatcherHandle: Long = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->
            if (call.method == "executeBackgroundTask_native") {

                    val args = arrayListOf<Long>();
                args.addAll(call.arguments());
                val callBackHandle = args[0];
                mCallbackDispatcherHandle = callBackHandle;

                val flutterTask : FlutterTask = FlutterTask("ovo je nativ battery parametar", result::success);

                FlutterTask.initializeTask(result::success);
                FlutterTask.initCtx(this);

                
                val myData: Data = androidx.work.workDataOf("KEY_X_ARG" to callBackHandle,
                "KEY_Y_STR" to "string param", "KEY_Z_INT" to 11);

                // todo: mategr
                // try this https://developer.android.com/guide/background/persistent#kotlin
                val uploadWorkRequest: WorkRequest =
                        OneTimeWorkRequestBuilder<UploadWorker>()
                                .setInputData(myData)
                                .build()

                WorkManager
                        .getInstance(this)  // this is Context
                        .enqueue(uploadWorkRequest)

                // return result to the main app
                // 27 is just arbitrary number
                result.success(27)
            } else {
                result.notImplemented()
            }
        }
    }
}
