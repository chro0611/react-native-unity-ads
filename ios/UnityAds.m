#import "UnityAds.h"
#import "ExUnversioned.h"

#import <React/RCTUtils.h>
#import <UnityAds/UnityAds.h>

@interface UnityAdsManager () <UnityAdsDelegate>

@property (nonatomic, strong) UIViewController *adViewController;
@property (nonatomic, strong) RCTPromiseResolveBlock showResolve;
@property (nonatomic, strong) RCTPromiseRejectBlock showReject;
@property (nonatomic, strong) RCTPromiseResolveBlock loadResolve;
@property (nonatomic, strong) RCTPromiseRejectBlock loadReject;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) bool loaded;
@property (nonatomic) bool isBackground;

@end

@implementation UnityAdsManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(UnityAds)

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidForeground:)
                                               name:EX_UNVERSIONED(@"EXKernelBridgeDidForegroundNotification")
                                             object:self.bridge];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(bridgeDidBackground:)
                                               name:EX_UNVERSIONED(@"EXKernelBridgeDidBackgroundNotification")
                                             object:self.bridge];
}

RCT_EXPORT_METHOD(
    loadAd:(NSString *)gameId
    placement:(NSString *)placementId 
    testMode:(BOOL)testMode
    loadResolver:(RCTPromiseResolveBlock)resolve
    loadRejector:(RCTPromiseRejectBlock)reject
){
    _loadResolve = resolve;
    _loadReject = reject;

    [UnityAds initialize:gameId delegate:self testMode:testMode];
    _placementId = placementId;
}

RCT_EXPORT_METHOD(
    isLoad:(RCTPromiseResolveBlock)resolve 
    isLoadRejector:(RCTPromiseRejectBlock)reject
){
    resolve(@(_loaded));
}

RCT_EXPORT_METHOD(
    showAd:(RCTPromiseResolveBlock)resolve 
    showAdRejector:(RCTPromiseRejectBlock)reject
){
    _showResolve = resolve;
    _showReject = reject;
    
    [UnityAds show:RCTPresentedViewController() placementId:_placementId];
}


- (void)unityAdsReady:(NSString *)placementId {
    _loaded = true;
    _loadResolve(@(_loaded));
}

- (void)unityAdsDidStart:(NSString *)placementId {
}

- (void)unityAdsDidFinish:(NSString *)placementId
withFinishState:(UnityAdsFinishState)state {
    NSString *result = [self convertToString:state];
    
    _showResolve(result);
    [self cleanUp];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    //_showReject(@"E_FAILED_TO_LOAD", [self convertToErrorString:error], nil);

    _showResolve(@"ERROR");
    [self cleanUp];
}

- (NSString*) convertToString:(UnityAdsFinishState) state {
    NSString *result = nil;
    switch(state) {
        case kUnityAdsFinishStateError:
            result = @"ERROR";
            break;
        case kUnityAdsFinishStateSkipped:
            result = @"SKIPPED";
            break;
        case kUnityAdsFinishStateCompleted:
            result = @"COMPLETED";
            break;
    }
    return result;
}

- (NSString*) convertToErrorString:(UnityAdsError) error {
    NSString *result = nil;

    switch(error) {
        case kUnityAdsErrorNotInitialized : result = @"kUnityAdsErrorNotInitialized"; break;
        case kUnityAdsErrorInitializedFailed : result = @"kUnityAdsErrorInitializedFailed"; break;
        case kUnityAdsErrorInvalidArgument : result = @"kUnityAdsErrorInvalidArgument"; break;
        case kUnityAdsErrorVideoPlayerError : result = @"kUnityAdsErrorVideoPlayerError"; break;
        case kUnityAdsErrorInitSanityCheckFail : result = @"kUnityAdsErrorInitSanityCheckFail"; break;
        case kUnityAdsErrorAdBlockerDetected : result = @"kUnityAdsErrorAdBlockerDetected"; break;
        case kUnityAdsErrorFileIoError : result = @"kUnityAdsErrorFileIoError"; break;
        case kUnityAdsErrorDeviceIdError : result = @"kUnityAdsErrorDeviceIdError"; break;
        case kUnityAdsErrorShowError : result = @"kUnityAdsErrorShowError"; break;
        case kUnityAdsErrorInternalError : result = @"kUnityAdsErrorInternalError"; break;
    }

    return result;
}

-(void)cleanUp{
    _showResolve = nil;
    _showReject = nil;
    _loaded = false;
}

- (void)bridgeDidForeground:(NSNotification *)notification{
    _isBackground = false;
  
    if (_adViewController) {
        [RCTPresentedViewController() presentViewController:_adViewController animated:NO completion:nil];
        _adViewController = nil;
    }
}

- (void)bridgeDidBackground:(NSNotification *)notification{
    _isBackground = true;
  
    if(_loaded)
    {
        _adViewController = RCTPresentedViewController();
        [_adViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
