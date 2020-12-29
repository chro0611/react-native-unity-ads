#import "UnityAds.h"
#import "ExUnversioned.h"

#import <React/RCTUtils.h>
#import <UnityAds/UnityAds.h>
#import <React/RCTRootView.h>

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
    loadAdResolver:(RCTPromiseResolveBlock)loadResolve
    loadAdRejector:(RCTPromiseRejectBlock)loadReject
){
    if(_loadResolve == nil)
    {
        _loadResolve = loadResolve;
        _loadReject = loadReject;
    }

    if(!UnityAds.isInitialized)
    {
        [UnityAds initialize:gameId testMode:testMode];
    }
    [UnityAds addDelegate:self];
    
    _placementId = placementId;
}

RCT_EXPORT_METHOD(
    isLoad:(RCTPromiseResolveBlock)isLoadresolve 
    isLoadRejector:(RCTPromiseRejectBlock)isLoadreject
){
    @try{
        isLoadresolve(@(UnityAds.isReady));
    }@catch(NSException *e) {
        isLoadreject(@"getLoad_failed", @"load error", nil);
    }
}

RCT_EXPORT_METHOD(
    showAd:(RCTPromiseResolveBlock)showResolve 
    showAdRejector:(RCTPromiseRejectBlock)showReject
){
    _showResolve = showResolve;
    _showReject = showReject;

    __block NSString *placementId = _placementId;
    
    void (^runShow)(void) = ^(void) {
        [UnityAds show:RCTPresentedViewController() placementId:placementId];
    };
    
    dispatch_async(dispatch_get_main_queue(), runShow);
}

- (void)unityAdsReady:(NSString *)placementId {
    _loaded = true;
    if(_loadResolve != nil)
    {
        @try{
            _loadResolve(@(UnityAds.isReady));
            _loadResolve = nil;
        }@catch(NSException *e){
            
        }
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
}

- (void)unityAdsDidFinish:(NSString *)placementId
withFinishState:(UnityAdsFinishState)state {
    NSString *result = [self convertToString:state];
     
    if(_showResolve != nil)
    {
        _showResolve(result);
    }

    [self cleanUp];
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    _showReject(@"E_FAILED_TO_LOAD", [self convertToErrorString:error], nil);

//    if(_showResolve != nil)
//    {
//        _showResolve(@(false));
//    }

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

- (CGFloat)statusBarHeight {
    // TODO: It would be better to use sharedApplication.statusBarFrame.size.height,
    // but it has unexpected value at this time.
    return 20.0f;
}

@end
