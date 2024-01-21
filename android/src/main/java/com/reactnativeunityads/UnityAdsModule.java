package com.reactnativeunityads;

import android.widget.Toast;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;

import com.unity3d.ads.IUnityAdsLoadListener;
import com.unity3d.ads.IUnityAdsShowListener;
import com.unity3d.ads.UnityAdsShowOptions;

import com.unity3d.ads.IUnityAdsInitializationListener;
import com.unity3d.ads.UnityAds;

import android.util.Log;

public class UnityAdsModule extends ReactContextBaseJavaModule {

  String unityGameID;
  boolean testMode = true;
  ReactApplicationContext reactContext;

  private void sendEvent(String eventName, WritableMap params) {
    reactContext
    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
    .emit(eventName, params);
  }

  // load listner.
  private IUnityAdsLoadListener loadListener = new IUnityAdsLoadListener() {

    @Override
    public void onUnityAdsAdLoaded(String placementId) {
      WritableMap params = Arguments.createMap();
      params.putString("adStatus", "adLoadComplete");
      sendEvent("AD_LOADED", params);
    }

    @Override
    public void onUnityAdsFailedToLoad(String placementId, UnityAds.UnityAdsLoadError error, String message) {
      WritableMap params = Arguments.createMap();
      Log.e("UnityAdsExample", "Unity Ads failed to load ad for " + placementId + " with error: [" + error + "] " + message);
      params.putString("adStatus", "adLoadFail");
      sendEvent("AD_LOADED", params);
    }
 };

 // show listner.
 private IUnityAdsShowListener showListener = new IUnityAdsShowListener() {

    @Override
    public void onUnityAdsShowFailure(String placementId, UnityAds.UnityAdsShowError error, String message) {
      WritableMap params = Arguments.createMap();
      Log.e("UnityAdsExample", "Unity Ads failed to show ad for " + placementId + " with error: [" + error + "] " + message);
      params.putString("adStatus", "adShowFail");
      sendEvent("AD_COMPLETED", params);
    }

    @Override
    public void onUnityAdsShowStart(String placementId) {
       Log.v("UnityAdsExample", "onUnityAdsShowStart: " + placementId);
    }

    @Override
    public void onUnityAdsShowClick(String placementId) {
       Log.v("UnityAdsExample", "onUnityAdsShowClick: " + placementId);
    }

    @Override
    public void onUnityAdsShowComplete(String placementId, UnityAds.UnityAdsShowCompletionState state) {
       Log.v("UnityAdsExample", "onUnityAdsShowComplete: " + placementId);
       if (state.equals(UnityAds.UnityAdsShowCompletionState.COMPLETED)) {
          // User seen full ad
          WritableMap params = Arguments.createMap();
          params.putString("adStatus", "fullComplete");
          sendEvent("AD_COMPLETED", params);
       } else {
          // User skipped the ad
          WritableMap params = Arguments.createMap();
          params.putString("adStatus", "partialComplete");
          sendEvent("AD_COMPLETED", params);
       }
    }
 };

  UnityAdsModule(ReactApplicationContext context){
    super(context);
    reactContext = context;
  }

  @Override
  public String getName(){
    return "UnityAdsModule";
  }

  // First user need to intialise the ad.
  @ReactMethod
  public void initializeAd(String gameId, Boolean test, Promise p){
    testMode = test;
    unityGameID = gameId;

    UnityAds.initialize(reactContext.getApplicationContext(), unityGameID, testMode, new IUnityAdsInitializationListener(){
      @Override
      public void onInitializationComplete(){
        p.resolve("SUCCESS");
      }

      @Override
      public void onInitializationFailed(UnityAds.UnityAdsInitializationError error, String message){
        p.reject("FAIL", "Unity Ads initialization failed with error: [" + error + "] " + message);
      }
    });
  }

  // after intialisation user can call loadAd and monitor events.
  @ReactMethod
  public void loadAd(String unityPlacementID, Promise p){
    if(UnityAds.isInitialized()){
      UnityAds.load(unityPlacementID, loadListener);
    }
  }

  @ReactMethod
  public void showAd(String unityPlacementID, Promise p){
    if(UnityAds.isInitialized()){
      UnityAds.show(getCurrentActivity(), unityPlacementID, new UnityAdsShowOptions(), showListener);
    }
  }
}
