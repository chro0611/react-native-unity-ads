import { NativeModules } from 'react-native';

type UnityAdsType = {
  multiply(a: number, b: number): Promise<number>;
};

const { UnityAds } = NativeModules;

export default UnityAds as UnityAdsType;
