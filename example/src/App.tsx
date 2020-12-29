import React, { useEffect } from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import UnityAds from 'react-native-unity-ads';

type FinishState = "ERROR" | "SKIPPED" | "COMPLETED" | "NOT_LOADED";

export default function App() {

  useEffect(() => {
    console.log("load challenge");
    UnityAds.loadAd('3873164', 'video', __DEV__);
  }, []);

  const showAd = async () => {
      if(await UnityAds.isLoad()){
        let result = await UnityAds.showAd();
        console.log(result);
      }
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
