package com.gozy.app


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.content.pm.PackageManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.KeyData.CHANNEL
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.GeneratedPluginRegistrant
import org.json.JSONObject


class MainActivity: FlutterFragmentActivity(){
    private var context: Context? = null
    private var thisActivity: Activity? = null
    private var _result: Result? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        thisActivity = this@MainActivity
        flutterEngine?.let {
            MethodChannel(
                it.dartExecutor,
                "ConstantValues"
            ).setMethodCallHandler { call, result ->
                if (call.method == "getmapkey") {
                    result.success("")
                } else if (call.method == "setMapKey") {
                    val mapKey = call.argument<String>("key")
                    mapKey?.let {
                        setMapKey(it)
                    }
                }

                else if(call.method == "getsecuritykey"){
                    result.success(baseContext.getString(R.string.SECURE_API_KEY))
                }else if(call.method == "getsdkversion"){
                    result.success(Build.VERSION.SDK_INT)
                }else if (call.method == "appversion") {
                    applicationContext
                    val packageManager = applicationContext!!.packageManager
                    val info = packageManager.getPackageInfo(applicationContext!!.packageName, 0)
                    result.success(info.versionName)
                }
            }
        }
        installSplashScreen()
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    private fun setMapKey(mapKey: String) {
        try {

            val applicationInfo = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            applicationInfo.metaData.putString("com.google.android.geo.API_KEY", mapKey)
            applicationInfo.apply {
                metaData.putString("com.google.android.geo.API_KEY", mapKey)
            }


        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }

}
