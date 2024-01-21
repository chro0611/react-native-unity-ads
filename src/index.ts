import { NativeModules } from 'react-native';

type UnityAdsType = {
  initializeAd(gameId : string, test : boolean) : Promise<boolean>;
  loadAd(placementId : string) : Promise<boolean>;
  showAd(placementId : string) : Promise<boolean>;
};

const { UnityAdsModule } = NativeModules;

export default UnityAdsModule as UnityAdsType;