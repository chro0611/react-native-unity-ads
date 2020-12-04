import { NativeModules } from 'react-native';

type UnityAdsType = {
  multiply(a: number, b: number): Promise<number>;
  initialized(gameId : string, placementId : string, test : boolean) : void;
  isLoad() : Promise<boolean>;
  showAd() : Promise<any>;

};

const { UnityAds } = NativeModules;

export default UnityAds as UnityAdsType;
