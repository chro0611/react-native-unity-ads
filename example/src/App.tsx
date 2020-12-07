import * as React from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import UnityAds from 'react-native-unity-ads';

type FinishState = "ERROR" | "SKIPPED" | "COMPLETED" | "NOT_LOADED";

export default function App() {

  React.useEffect(() => {
    UnityAds.initialized('3923800', 'video', true);
  }, []);

  const showAd = async () => {
    //console.log(await UnityAds.showAd());

    console.log(await UnityAds.isLoad());

    // UnityAds.isLoad().then(isLoad=>{
    //   if(isLoad){
        UnityAds.showAd().then((result)=>{
          console.log(result);
        }).catch(error=>{
          console.log(error);
        });
    //   }
    // })
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
