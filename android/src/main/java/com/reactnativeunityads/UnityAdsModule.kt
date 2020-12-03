package com.reactnativeunityads

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

import android.app.Activity
import android.content.Intent
import android.util.Log

import com.unity3d.ads.IUnityAdsListener
import com.unity3d.ads.UnityAds

import android.widget.Toast

class UnityAdsModule : ReactContextBaseJavaModule {

    constructor(context: ReactApplicationContext){
      reactContext = context
    }

    inner class UnityAdsListener : IUnityAdsListener {
      override fun onUnityAdsReady(placementId: String){
        Toast.makeText(reactContext, "test3", 2000).show()

        isReady = true
      }

      override fun onUnityAdsStart(placementId: String){
        Toast.makeText(reactContext, "test2", 2000).show()

      }

      override fun onUnityAdsFinish(placementId: String, finishState: UnityAds.FinishState ){
        (showPromise as Promise).resolve(finishState)
        clear()
      }

      override fun onUnityAdsError(error: UnityAds.UnityAdsError, message: String){
        Toast.makeText(reactContext, "test", 2000).show()

        (showPromise as Promise).reject("E_FAILED_TO_LOAD", message)
        clear()
      }
    }


    override fun getName(): String {
        return "UnityAds"
    }

    // Example method
    // See https://facebook.github.io/react-native/docs/native-modules-android
    @ReactMethod
    fun multiply(a: Int, b: Int, promise: Promise) {
      promise.resolve(a * b)
    }

    var reactContext : ReactApplicationContext

    var unityGameID = ""
    var unityPlacementID = ""
    var testMode = true
    var isReady = false
    var showPromise : Promise? = null
    var loadPromise : Promise? = null

    @ReactMethod
    fun initialized(gameId : String, placementId : String, test : Boolean){
      testMode = test
      unityGameID = gameId
      unityPlacementID = placementId

      val adListener : UnityAdsListener = UnityAdsListener()
      UnityAds.addListener(adListener)
      UnityAds.initialize(reactContext, unityGameID, testMode)
    }

    @ReactMethod
    fun isLoad(p:Promise){
      p.resolve(isReady)
    }

    @ReactMethod
    fun adShow(p:Promise){

      showPromise = p

      if(UnityAds.isReady(unityPlacementID)){
        UnityAds.show(reactContext.getCurrentActivity(), unityPlacementID)
      }
    }

    fun clear(){
      isReady = false
      showPromise = null
    }

}
