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

}
