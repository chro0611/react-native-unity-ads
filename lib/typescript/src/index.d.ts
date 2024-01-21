declare type UnityAdsType = {
    loadAd(gameId: string, placementId: string, test: boolean): Promise<boolean>;
    isLoad(): Promise<boolean>;
    showAd(): Promise<string>;
};
declare const _default: UnityAdsType;
export default _default;
