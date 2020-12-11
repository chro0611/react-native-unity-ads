import { NativeModules } from 'react-native';

type UnityAdsType = {
  loadAd(gameId : string, placementId : string, test : boolean) : Promise<boolean>;
  isLoad() : Promise<boolean>;
  showAd() : Promise<string>;

};

const { UnityAds } = NativeModules;

export default UnityAds as UnityAdsType;
