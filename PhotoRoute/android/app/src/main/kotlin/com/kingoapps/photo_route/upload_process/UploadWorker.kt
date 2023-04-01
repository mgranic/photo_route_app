package com.kingoapps.photo_route.upload_process

//import com.google.common.util.concurrent.ListenableFuture
//import com.google.common.util.concurrent.ResolvableFuture

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.provider.MediaStore
import androidx.concurrent.futures.*
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.android.volley.Request
import com.android.volley.Response
import com.android.volley.toolbox.HurlStack
import com.android.volley.toolbox.JsonObjectRequest
import com.android.volley.toolbox.Volley
import com.google.common.util.concurrent.*
import java.io.IOException
import java.net.HttpURLConnection
import java.net.MalformedURLException
import java.net.URL
import java.security.SecureRandom
import java.security.cert.X509Certificate
import javax.net.ssl.*


const val KEY_X_ARG = "X"

// TODO: try with ListenableWorker
// https://github.com/fluttercommunity/flutter_workmanager/blob/main/android/src/main/kotlin/be/tramckrijte/workmanager/BackgroundWorker.kt
public class UploadWorker(appContext: Context, workerParams: WorkerParameters):
        Worker(appContext, workerParams) {
        //ListenableWorker(appContext, workerParams) {

    // https://stackoverflow.com/questions/61347243/how-do-i-call-dart-code-from-android-service
    // https://testfairy.com/blog/native-communication-with-a-callback-in-flutter/
    // https://jike.in/?qa=664816/dart-how-to-schedule-background-tasks-in-flutter
    // https://medium.com/flutter/executing-dart-in-the-background-with-flutter-plugins-and-geofencing-2b3e40a1a124
    // https://medium.com/@chetan882777/initiating-calls-to-dart-from-the-native-side-in-the-background-with-flutter-plugin-7d46aed32c47#:~:text=The%20callback%20dispatcher%20works%20as,expected%2C%20for%20the%20most%20part.
    // https://github.com/bkonyi/FlutterGeofencing
    override fun doWork(): Result {
        println("Hello battery background starts");
        

        val x = inputData.getLong("KEY_X_ARG", 0);
        val y = inputData.getString("KEY_Y_STR");
        val z = inputData.getInt("KEY_Z_INT", 1);
        println(x)
        println(y)
        println(z)

        postRequest();
        println("Hello battery background ends");
        // Indicate whether the work finished successfully with the Result
        return Result.success()
    }

    private fun getHttpStack(urlToValidate: String): HurlStack? {
        var url: URL? = null
        try {
            url = URL(urlToValidate)
        } catch (e: MalformedURLException) {
            e.printStackTrace()
        }
        val baseUrl: String = url!!.getAuthority()
        return object : HurlStack() {
            @Throws(IOException::class)
            override fun createConnection(url: URL): HttpURLConnection {
                val httpsURLConnection: HttpsURLConnection = super
                    .createConnection(url) as HttpsURLConnection
                try {
                    httpsURLConnection
                        .setSSLSocketFactory(handleSSLHandshake(httpsURLConnection))
                    httpsURLConnection.setHostnameVerifier(object : HostnameVerifier {
                        override fun verify(hostname: String?, session: SSLSession?): Boolean {
                            //return true;
                            val hv: HostnameVerifier =
                                HttpsURLConnection.getDefaultHostnameVerifier()
                            return hv.verify(baseUrl, session)
                        }
                    })
                } catch (e: java.lang.Exception) {
                    e.printStackTrace()
                }
                return httpsURLConnection
            }
        }
    }

    @SuppressLint("TrulyRandom")
    fun handleSSLHandshake(connection: HttpsURLConnection): SSLSocketFactory? {
        try {
            val trustAllCerts: Array<TrustManager> =
                arrayOf<TrustManager>(object : X509TrustManager {
                    val acceptedIssuers: Array<Any?>?
                        get() = arrayOfNulls(0)

                    override fun checkClientTrusted(certs: Array<X509Certificate?>?, authType: String?) {}
                    override fun checkServerTrusted(certs: Array<X509Certificate?>?, authType: String?) {}
                    override fun getAcceptedIssuers(): Array<X509Certificate> {
                        TODO("Not yet implemented")
                    }
                })
            val sc: SSLContext = SSLContext.getInstance("SSL")
            sc.init(null, trustAllCerts, SecureRandom())
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory())
            HttpsURLConnection.setDefaultHostnameVerifier(object : HostnameVerifier {
                override fun verify(arg0: String?, arg1: SSLSession?): Boolean {
                    println("test RETURN TRUE: ")
                    return true
                }
            })
            sc.init(null, trustAllCerts, SecureRandom())
            val newFactory: SSLSocketFactory = sc.getSocketFactory()
            connection.setSSLSocketFactory(newFactory)
        } catch (ignored: java.lang.Exception) {
        }
        return connection.getSSLSocketFactory()
    }


    // TODO: mategr ovo se poziva i radi
    private fun postRequest() {
        println("send post request");
        // Instantiate the RequestQueue.
        val url = "https://localhost:7081/WeatherForecast/GetWeatherForecast/radiiiii"
        val queue = Volley.newRequestQueue(FlutterTask.ctx, getHttpStack(url))

        // Request a string response from the provided URL.
        val stringRequest = JsonObjectRequest(
            Request.Method.GET, url, null, //Request.Method.GET,
                Response.Listener { response ->
                    println("Response is: ${response.toString()}")
                },
                Response.ErrorListener { error ->
                    //textView.text = "That didn't work!"
                    println("Greška pri slanju post requesta ${error.message}")
                })

        // Add the request to the RequestQueue.
        queue.add(stringRequest)
    }
}