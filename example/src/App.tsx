import * as React from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import UnityAds from 'react-native-unity-ads';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  React.useEffect(() => {
    UnityAds.initialized('3923800', 'video', true)
  }, []);

  const showAd = () => {

    UnityAds.adShow().then(result=>{
      console.log(result);
    }).catch(error=>{
      console.log(error);
    });

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
