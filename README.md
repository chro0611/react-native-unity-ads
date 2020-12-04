# Unity Ads

Unity Ads는 initialize 호출한 이후 로드가 자동으로 되며, isLoad로 로드가 되었는지 확인 후 adShow를 호출하여 광고를 불러올 수 있습니다. adShow 이후에도 따로 로드없이 자동으로 광고가 로드되며, 이때 역시 isLoad로 광고가 제대로 로드되었는지 확인할 수 있습니다

# Example

```tsx
import * as React from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import UnityAds from 'react-native-unity-ads';

type FinishState = "ERROR" | "SKIPPED" | "COMPLETED" | "NOT_LOADED";

export default function App() {

  React.useEffect(() => {
    UnityAds.initialized('3873165', 'video', __DEV__)
  }, []);

  const showAd = async () => {
    UnityAds.isLoad().then(isLoad=>{
      if(isLoad){
        UnityAds.showAd().then((result: FinishState)=>{
          console.log(result);
        }).catch(error=>{
          console.log(error);
        });
      }
    })
  }

  return (
    <View style={styles.container}>
      <Button onPress={showAd} title={"test"} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
```

# Reference

## methods

```jsx
initialized(gameID : String, placementID : String, test : boolean) : void
```

광고 초기화. 초기화에 gameID와 placementID가 필요하며 test광고인지 를 통해 광고를 초기화 시킨다

```jsx
isLoad() : Promise<boolean>
```

광고가 로드되었는지 확인하는 함수

```jsx
showAd() : Promise<FinishState>
```

광고를 보여주는 함수. 완료시에 ERROR, SKIPPED, COMPLETED 값 중 하나를 넘겨주며, 광고가 로드되지 않았을시에는 NOT_LOADED 값을 넘겨준다
