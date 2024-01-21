
Import the module
```
import UnityAdsModule from 'react-native-unity-ads-moon';
```

Initialize Ads - somewhere early in your app
```
/* Initialize Unity -> add correct ad id and mobile id here */
const unityRewardedAd = await UnityAdsModule.initializeAd('5261111', true);
console.log("INITIALIZE UNITY ADS -> " + unityRewardedAd)
```


Load Ads
```
UnityAdsModule.loadAd(); // unity ad load
```

Using Hooks with Unity Ads
```
/* this hook take care for unity ad call backs */
React.useEffect(async() => {

  const loadEventEmitter = new NativeEventEmitter();
  const showEventEmitter = new NativeEventEmitter();

  const loadEventListener = loadEventEmitter.addListener(
    'AD_LOADED', 
    (event) => {
      console.log("Unity Ad loading complete")
      console.log(event.adStatus) // "someValue"
      UnityAdsModule.showAd(); // show unity ad
  });

  const showEventListener = showEventEmitter.addListener(
    'AD_COMPLETED', 
    (event) => {
      console.log("Unity Ad showing complete")
      console.log(event.adStatus) // "someValue"

      if(event.adStatus == "fullComplete"){
        // do something once ad completes
      }
  });

  /* Unsubscribe from events on unmount */
  return () => {
    loadEventListener.remove();
    showEventListener.remove();
  };

}, []);
```