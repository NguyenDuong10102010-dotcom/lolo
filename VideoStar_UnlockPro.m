//
//  VideoStar_UnlockPro.m
//  Mã nguồn độc lập 1 file duy nhất để build VideoStar_UnlockPro.dylib
//  Mở khóa bản quyền VIP All-Access, 90 gói hiệu ứng Pro & Anti-Crash Sideload cho Video Star 15.3.3+
//  Hỗ trợ đầy đủ ESign, Scarlet, TrollStore, AltStore, Sideloadly trên iOS 15.0 đến iOS 18.x+.
//  Đã thay link Zalo bằng TikTok @painuzz và thêm intro dashboard overlay.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>

#define VdsLog(fmt, ...)    NSLog((@"[VdsUnlockPro] " fmt), ##__VA_ARGS__)
#define VdsLogOK(fmt, ...)  NSLog((@"[VdsUnlockPro] [OK] " fmt), ##__VA_ARGS__)
#define VdsLogErr(fmt, ...) NSLog((@"[VdsUnlockPro] [!] " fmt), ##__VA_ARGS__)

#pragma mark - Runtime Swizzle Helper

static inline void VdsSwizzleInstanceMethod(Class cls, SEL sel, IMP newImp, const char *types) {
    if (!cls || !sel || !newImp) return;
    Method origMethod = class_getInstanceMethod(cls, sel);
    if (origMethod) {
        method_setImplementation(origMethod, newImp);
    } else {
        class_addMethod(cls, sel, newImp, types);
    }
}

#pragma mark - 1. Safe Mock CloudKit (Chống văng app khi Sideload)

@interface VdsSafeCKDatabase : NSObject
@end

@implementation VdsSafeCKDatabase

- (void)addOperation:(id)operation {
}

- (void)performQuery:(id)query inZoneWithID:(id)zoneID completionHandler:(void(^)(NSArray *results, NSError *error))completionHandler {
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(@[], nil);
        });
    }
}

- (void)fetchAllRecordZonesWithCompletionHandler:(void(^)(NSArray *zones, NSError *error))completionHandler {
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(@[], nil);
        });
    }
}

- (void)saveRecord:(id)record completionHandler:(void(^)(id record, NSError *error))completionHandler {
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(record, nil);
        });
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
}

@end

@interface VdsSafeCKContainer : NSObject
@end

@implementation VdsSafeCKContainer

+ (id)defaultContainer {
    static VdsSafeCKContainer *inst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        inst = [[VdsSafeCKContainer alloc] init];
    });
    return inst;
}

+ (id)containerWithIdentifier:(id)ident {
    return [self defaultContainer];
}

- (id)publicCloudDatabase {
    return [[VdsSafeCKDatabase alloc] init];
}

- (id)privateCloudDatabase {
    return [[VdsSafeCKDatabase alloc] init];
}

- (id)sharedCloudDatabase {
    return [[VdsSafeCKDatabase alloc] init];
}

- (id)databaseWithDatabaseScope:(NSInteger)scope {
    return [[VdsSafeCKDatabase alloc] init];
}

- (void)accountStatusWithCompletionHandler:(void(^)(NSInteger accountStatus, NSError *error))completionHandler {
    if (completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(1 /* CKAccountStatusAvailable */, nil);
        });
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
}

@end

static void VdsInstallCloudKitSafeMock(void) {
    Class ckClass = objc_getClass("CKContainer");
    if (ckClass) {
        Method origDef = class_getClassMethod(ckClass, @selector(defaultContainer));
        Method safeDef = class_getClassMethod([VdsSafeCKContainer class], @selector(defaultContainer));
        if (origDef && safeDef) {
            method_setImplementation(origDef, method_getImplementation(safeDef));
        }

        Method origIdent = class_getClassMethod(ckClass, @selector(containerWithIdentifier:));
        Method safeIdent = class_getClassMethod([VdsSafeCKContainer class], @selector(containerWithIdentifier:));
        if (origIdent && safeIdent) {
            method_setImplementation(origIdent, method_getImplementation(safeIdent));
        }
        VdsLogOK(@"Đã kích hoạt Mock CKContainer an toàn chống văng app.");
    }
}

#pragma mark - 2. Dictionary Đa Năng Mở Khóa Mọi Gói Hiệu Ứng (Universal Owned Products)

@interface VdsOwnedProductsDict : NSDictionary
@end

@implementation VdsOwnedProductsDict {
    NSArray *_cachedKeys;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cachedKeys = @[
            @"AllAccessPass", @"AllAccessPassMonth", @"AllAccessPassYear", @"AllAccessPass3Month",
            @"MonthlyUnlockVS", @"MonthlyUnlockVSWithTrialPeriod", @"OneYearUnlockVS", @"OneYearUnlockVSWithTrialPeriod", @"HalfYearUnlockVS",
            @"MultiLayer", @"MultiLayerPlus", @"MultiLayerAdvanced", @"MultiLayerText", @"MultiLayer3D",
            @"3DObjectPack", @"3DTextPack", @"3DShapesPack", @"3DAnimationPack", @"3DLightingPack",
            @"TrackingPack", @"MotionBlurPack", @"AutoTrackingPack", @"FaceTrackingPack",
            @"ColorLab", @"ColorLabPro", @"LUTsPack", @"ColorGradingPack", @"HDRColorPack",
            @"CinemaPack", @"VintageFilmPack", @"RetroVCRPack", @"GlitchPack", @"GlitchProPack",
            @"AudioFilters", @"AudioPitchPack", @"AudioEQPack", @"AudioVisualizerPack",
            @"TransitionPack1", @"TransitionPack2", @"TransitionPack3", @"TransitionPack4", @"TransitionPack5",
            @"TransitionPack6", @"TransitionPack7", @"TransitionPack8", @"TransitionPack9", @"TransitionPack10",
            @"WipeTransitions", @"ZoomTransitions", @"SpinTransitions", @"GlitchTransitions", @"FluidTransitions",
            @"ParticleLab", @"SmokeAndFirePack", @"SparklePack", @"LaserPack", @"RainAndSnowPack",
            @"DistortionPack", @"MorphPack", @"PixelArtPack", @"CartoonPack", @"ComicPack",
            @"TextAnimPack1", @"TextAnimPack2", @"TextAnimPack3", @"KineticTextPack", @"NeonTextPack",
            @"OverlayPack1", @"OverlayPack2", @"LightLeaksPack", @"LensFlaresPack", @"BokehPack",
            @"KeyframePack", @"CurveKeyframesPack", @"VelocityCurvesPack", @"SpeedRampPack",
            @"GreenScreenPack", @"ChromaKeyPro", @"RotoscopingPack", @"AutoMaskPack", @"ShapeMaskPack",
            @"SoundFXPack1", @"SoundFXPack2", @"BeatSyncPack", @"MusicSyncPro",
            @"PresetPackPro", @"VIPExclusiveFilters", @"ProGraphicsPack", @"TitleToolkit", @"BorderEffectsPack",
            @"PurchasedMultiLayer", @"PurchasedClipMix", @"PurchasedMadness", @"PurchasedReEffectinator",
            @"PurchaseClipTransformer", @"PurchaseEffectStyle", @"PurchaseVFXAudio", @"PurchasedAdvAS",
            @"BundleUnlocked", @"UnlockedVSP", @"AllAccess"
        ];
    }
    return self;
}

- (NSUInteger)count {
    return _cachedKeys.count;
}

- (id)objectForKey:(id)aKey {
    return @YES;
}

- (id)objectForKeyedSubscript:(id)key {
    return @YES;
}

- (NSEnumerator *)keyEnumerator {
    return [_cachedKeys objectEnumerator];
}

- (BOOL)containsObject:(id)anObject {
    return YES;
}

- (id)member:(id)anObject {
    return anObject;
}

- (NSArray *)allKeys {
    return _cachedKeys;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [_cachedKeys countByEnumeratingWithState:state objects:buffer count:len];
}

@end

#pragma mark - 3. Trình Quản Lý NSUserDefaults Offline Pro

static BOOL (*orig_NSUserDefaults_boolForKey)(id self, SEL _cmd, NSString *defaultName) = NULL;

static BOOL VdsHook_NSUserDefaults_boolForKey(id self, SEL _cmd, NSString *defaultName) {
    if ([defaultName isEqualToString:@"PurchasedMultiLayer"] ||
        [defaultName isEqualToString:@"PurchasedAdvAS"] ||
        [defaultName isEqualToString:@"PurchasedClipMix"] ||
        [defaultName isEqualToString:@"PurchasedMadness"] ||
        [defaultName isEqualToString:@"PurchasedReEffectinator"] ||
        [defaultName isEqualToString:@"PurchaseClipTransformer"] ||
        [defaultName isEqualToString:@"PurchaseEffectStyle"] ||
        [defaultName isEqualToString:@"PurchaseVFXAudio"] ||
        [defaultName isEqualToString:@"BundleUnlocked"] ||
        [defaultName isEqualToString:@"UnlockedVSP"] ||
        [defaultName isEqualToString:@"hasOwnedYearProWithTrial"] ||
        [defaultName isEqualToString:@"hasOwnedMonthProWithTrial"] ||
        [defaultName isEqualToString:@"hasHadTrial"] ||
        [defaultName isEqualToString:@"WxVds_IsVIPLifetime"] ||
        [defaultName isEqualToString:@"isBlackPassEnabled"]) {
        return YES;
    }
    if ([defaultName isEqualToString:@"cachedIsPastTrialPeriod"]) {
        return NO;
    }
    if (orig_NSUserDefaults_boolForKey) {
        return orig_NSUserDefaults_boolForKey(self, _cmd, defaultName);
    }
    return NO;
}

static void VdsSetUserDefaultsProKeys(void) {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *proKeys = @[
        @"PurchasedMultiLayer",
        @"PurchasedAdvAS",
        @"PurchasedClipMix",
        @"PurchasedMadness",
        @"PurchasedReEffectinator",
        @"PurchaseClipTransformer",
        @"PurchaseEffectStyle",
        @"PurchaseVFXAudio",
        @"BundleUnlocked",
        @"UnlockedVSP",
        @"hasOwnedYearProWithTrial",
        @"hasOwnedMonthProWithTrial",
        @"hasHadTrial",
        @"WxVds_IsVIPLifetime",
        @"isBlackPassEnabled"
    ];
    for (NSString *k in proKeys) {
        [defs setBool:YES forKey:k];
    }
    [defs setBool:NO forKey:@"cachedIsPastTrialPeriod"];
    [defs synchronize];
}

#pragma mark - 4. Các Hook Mở Khóa Toàn Diện StoreModel

static BOOL VdsHook_YES(id self, SEL _cmd) {
    return YES;
}

static BOOL VdsHook_YES_withArg(id self, SEL _cmd, id arg) {
    return YES;
}

static BOOL VdsHook_YES_withArg2(id self, SEL _cmd, id arg1, BOOL arg2) {
    return YES;
}

static BOOL VdsHook_NO(id self, SEL _cmd) {
    return NO;
}

static BOOL VdsHook_NO_withArg(id self, SEL _cmd, id arg) {
    return NO;
}

static NSInteger VdsHook_StoreModel_Count90(id self, SEL _cmd) {
    return 90;
}

static NSInteger VdsHook_StoreModel_numberOfTheseProductsOwned(id self, SEL _cmd, id products) {
    if ([products isKindOfClass:[NSArray class]]) {
        return [(NSArray *)products count];
    }
    return 90;
}

static NSDate *VdsHook_StoreModel_expirationDate(id self, SEL _cmd, NSString *subID) {
    return [NSDate dateWithTimeIntervalSince1970:4102444800]; // 2100-01-01
}

static NSString *VdsHook_StoreModel_expirationString(id self, SEL _cmd) {
    return @"2099-12-31T23:59:59Z";
}

static NSString *VdsHook_StoreModel_subIDLatest(id self, SEL _cmd) {
    return @"AllAccessPassYear";
}

static NSString *VdsHook_StoreModel_subGroup(id self, SEL _cmd) {
    return @"AllAccessPass";
}

static NSString *VdsHook_StoreModel_allAccessString(id self, SEL _cmd) {
    return @"AllAccessPassYear";
}

static NSDictionary *VdsHook_StoreModel_ownedProducts(id self, SEL _cmd) {
    static VdsOwnedProductsDict *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[VdsOwnedProductsDict alloc] init];
    });
    return dict;
}

static NSArray *VdsHook_StoreModel_ownedProductIDList(id self, SEL _cmd) {
    VdsOwnedProductsDict *d = (VdsOwnedProductsDict *)VdsHook_StoreModel_ownedProducts(self, _cmd);
    return [d allKeys];
}

static NSArray *VdsHook_emptyArray(id self, SEL _cmd) {
    return @[];
}

static NSDictionary *VdsHook_StoreModel_refundedProducts(id self, SEL _cmd) {
    return @{};
}

static id VdsHook_nilReturn_withArg(id self, SEL _cmd, id arg) {
    return nil;
}

static id VdsHook_nilReturn_demo(id self, SEL _cmd, id img, id pid, BOOL anim) {
    return nil;
}

#pragma mark - 5. Hook QRCodeManager (Mở Khóa Quét QR Preset Độc Quyền)

static BOOL VdsHook_QRCodeManager_valid(id self, SEL _cmd, id code) {
    return YES;
}

#pragma mark - 6. Chặn Lỗi Gói Đăng Ký (Subscription Error Mitigation Khi Sideload)

static void (*orig_presentViewController)(id self, SEL _cmd, UIViewController *vc, BOOL animated, void (^completion)(void)) = NULL;

static void VdsHook_presentViewController(UIViewController *self, SEL _cmd, UIViewController *vc, BOOL animated, void (^completion)(void)) {
    if ([vc isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alert = (UIAlertController *)vc;
        NSString *title = alert.title ?: @"";
        NSString *msg = alert.message ?: @"";
        if ([title isEqualToString:@"Subscription Error"] ||
            [title isEqualToString:@"Lỗi gói đăng ký"] ||
            [msg containsString:@"subscription options"] ||
            [msg containsString:@"tùy chọn gói đăng ký"] ||
            [msg containsString:@"Subscription Error"]) {
            VdsLog(@"[INTERCEPT] Đã chặn hiển thị popup lỗi gói đăng ký: '%@' - '%@'", title, msg);
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UIView *sub in self.view.subviews) {
                    if ([sub isKindOfClass:[UIActivityIndicatorView class]]) {
                        sub.hidden = YES;
                        [(UIActivityIndicatorView *)sub stopAnimating];
                    }
                }
            });
            if (completion) {
                completion();
            }
            return;
        }
    }
    
    if (orig_presentViewController) {
        orig_presentViewController(self, _cmd, vc, animated, completion);
    }
}

static void VdsHook_SGD_determineSubscriptionGroup(id self, SEL _cmd, void (^completion)(NSInteger group, id error)) {
    VdsLogOK(@"determineSubscriptionGroup hooked! Trả về nhóm gói 1 hợp lệ.");
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(1, nil);
        });
    }
}

static void VdsHook_SGD_checkSubscriptionGroup(id self, SEL _cmd) {
}

static void VdsHook_SGD_prepareToCheckSubscriptionGroup(id self, SEL _cmd) {
}

static BOOL VdsHook_SubVC_isShowingSubscriptionErrorPopup(id self, SEL _cmd) {
    return NO;
}

static void VdsHook_SubVC_setIsShowingSubscriptionErrorPopup(id self, SEL _cmd, BOOL val) {
}

static BOOL VdsHook_SubVC_isRefreshingSubscription(id self, SEL _cmd) {
    return NO;
}

static void (*orig_SubVC_viewWillAppear)(id self, SEL _cmd, BOOL animated) = NULL;
static void VdsHook_SubVC_viewWillAppear(UIViewController *self, SEL _cmd, BOOL animated) {
    if (orig_SubVC_viewWillAppear) {
        orig_SubVC_viewWillAppear(self, _cmd, animated);
    }
    
    @try {
        [self setValue:@(NO) forKey:@"waitingForPriceUpdates"];
        [self setValue:@(NO) forKey:@"isShowingSubscriptionErrorPopup"];
        [self setValue:@(NO) forKey:@"isRefreshingSubscription"];
    } @catch (NSException *e) {}

    __weak UIViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *strongSelf = weakSelf;
        if (!strongSelf || !strongSelf.isViewLoaded) return;
        
        for (UIView *sub in strongSelf.view.subviews) {
            if ([sub isKindOfClass:[UIActivityIndicatorView class]]) {
                sub.hidden = YES;
                [(UIActivityIndicatorView *)sub stopAnimating];
            }
        }
        SEL selVisuals = @selector(updateSubscriptionVisuals);
        if ([strongSelf respondsToSelector:selVisuals]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [strongSelf performSelector:selVisuals];
#pragma clang diagnostic pop
        }
    });
}

#pragma mark - 7. Cài Đặt Toàn Bộ Hook Unlock Pro

static BOOL s_hookedStore = NO;
static BOOL s_hookedVideoPreview = NO;
static BOOL s_hookedQR = NO;
static BOOL s_hookedSub = NO;
static BOOL s_hookedUserDefaults = NO;

static void VdsInstallProUnlockHooks(void) {
    if (!s_hookedUserDefaults) {
        VdsSetUserDefaultsProKeys();
        Method mBoolForKey = class_getInstanceMethod([NSUserDefaults class], @selector(boolForKey:));
        if (mBoolForKey) {
            orig_NSUserDefaults_boolForKey = (BOOL (*)(id, SEL, NSString *))method_getImplementation(mBoolForKey);
            method_setImplementation(mBoolForKey, (IMP)VdsHook_NSUserDefaults_boolForKey);
        }
        s_hookedUserDefaults = YES;
        VdsLogOK(@"Đã hook NSUserDefaults mở khóa Offline Pro.");
    }

    if (!s_hookedStore) {
        Class storeCls = objc_getClass("StoreModel");
        if (storeCls) {
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"activeSubscription"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(subscriptionActive), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"proFeaturesUnlocked"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(autoRenewON), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(boughtProduct:), (IMP)VdsHook_YES_withArg, "B@:@");
            VdsSwizzleInstanceMethod(storeCls, @selector(buyProduct:inPlace:), (IMP)VdsHook_YES_withArg2, "B@:@B");
            VdsSwizzleInstanceMethod(storeCls, @selector(ownsProduct:), (IMP)VdsHook_YES_withArg, "B@:@");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"ownsAutoStopPack"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"isBlackPassEnabled"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"testActiveSubscription"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"hasOwnedSubscription:"), (IMP)VdsHook_YES_withArg, "B@:@");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"hadSubscriptionOnce"), (IMP)VdsHook_YES, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"isSubscriptionProduct:"), (IMP)VdsHook_YES_withArg, "B@:@");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"isPaidProduct:"), (IMP)VdsHook_YES_withArg, "B@:@");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"canBuyProduct:"), (IMP)VdsHook_YES_withArg, "B@:@");

            VdsSwizzleInstanceMethod(storeCls, @selector(numberOfTheseProductsOwned:), (IMP)VdsHook_StoreModel_numberOfTheseProductsOwned, "q@:@");
            VdsSwizzleInstanceMethod(storeCls, @selector(numberOfPacksOwned), (IMP)VdsHook_StoreModel_Count90, "q@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(purchasedCount), (IMP)VdsHook_StoreModel_Count90, "q@:");

            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"allAccessPassString"), (IMP)VdsHook_StoreModel_allAccessString, "@@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(expirationDateForSubscriptionID:), (IMP)VdsHook_StoreModel_expirationDate, "@@:@");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"subscriptionExpirationDateIA5String"), (IMP)VdsHook_StoreModel_expirationString, "@@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"subscriptionIDWithLatestExpirationDate"), (IMP)VdsHook_StoreModel_subIDLatest, "@@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"subscriptionGroupToShow"), (IMP)VdsHook_StoreModel_subGroup, "@@:");

            VdsSwizzleInstanceMethod(storeCls, @selector(ownedProducts), (IMP)VdsHook_StoreModel_ownedProducts, "@@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(ownedProductIDList), (IMP)VdsHook_StoreModel_ownedProductIDList, "@@:");
            VdsSwizzleInstanceMethod(storeCls, @selector(refundedProducts), (IMP)VdsHook_StoreModel_refundedProducts, "@@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"unownedPacks"), (IMP)VdsHook_emptyArray, "@@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"unpurchasedPacks"), (IMP)VdsHook_emptyArray, "@@:");

            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"isFreeTrial"), (IMP)VdsHook_NO, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"freeTrial"), (IMP)VdsHook_NO, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"yearPassOnSale"), (IMP)VdsHook_NO, "B@:");
            VdsSwizzleInstanceMethod(storeCls, NSSelectorFromString(@"showUnlockableProductDialog:"), (IMP)VdsHook_nilReturn_withArg, "@@:@");

            s_hookedStore = YES;
            VdsLogOK(@"Đã hook StoreModel mở khóa All-Access Pass và toàn bộ 90 Packs.");
        }
    }

    if (!s_hookedVideoPreview) {
        Class vpCls = objc_getClass("VideoPreviewVC");
        if (vpCls) {
            VdsSwizzleInstanceMethod(vpCls, NSSelectorFromString(@"showDemoViewWithButtonImage:productID:animated:"), (IMP)VdsHook_nilReturn_demo, "@@:@@B");
            VdsSwizzleInstanceMethod(vpCls, NSSelectorFromString(@"showDemoViewForStyle:animated:"), (IMP)VdsHook_nilReturn_withArg, "@@:@B");
            VdsSwizzleInstanceMethod(vpCls, NSSelectorFromString(@"showDemoView:"), (IMP)VdsHook_nilReturn_withArg, "@@:@");
            s_hookedVideoPreview = YES;
            VdsLogOK(@"Đã hook VideoPreviewVC chặn popup demo.");
        }
    }

    if (!s_hookedQR) {
        Class qrCls = objc_getClass("QRCodeManager");
        if (qrCls) {
            VdsSwizzleInstanceMethod(qrCls, @selector(validQRCheck:), (IMP)VdsHook_QRCodeManager_valid, "B@:@");
            VdsSwizzleInstanceMethod(qrCls, @selector(validCode:), (IMP)VdsHook_QRCodeManager_valid, "B@:@");
            VdsSwizzleInstanceMethod(qrCls, @selector(setQRCodeUsed:), (IMP)VdsHook_QRCodeManager_valid, "B@:@");
            s_hookedQR = YES;
            VdsLogOK(@"Đã hook QRCodeManager mở khóa Preset QR Code.");
        }
    }

    if (!s_hookedSub) {
        static dispatch_once_t onceSub;
        dispatch_once(&onceSub, ^{
            Method mPresent = class_getInstanceMethod([UIViewController class], @selector(presentViewController:animated:completion:));
            if (mPresent) {
                orig_presentViewController = (void (*)(id, SEL, UIViewController *, BOOL, void (^)(void)))method_getImplementation(mPresent);
                method_setImplementation(mPresent, (IMP)VdsHook_presentViewController);
                VdsLogOK(@"Đã hook UIViewController presentViewController chặn popup lỗi.");
            }

            Class sgdCls = objc_getClass("_TtC10Video_Star27SubscriptionGroupDeterminer");
            if (sgdCls) {
                SEL selDet = @selector(determineSubscriptionGroupObjCWithCompletion:);
                VdsSwizzleInstanceMethod(sgdCls, selDet, (IMP)VdsHook_SGD_determineSubscriptionGroup, "v@:@?");
                VdsSwizzleInstanceMethod(sgdCls, @selector(checkSubscriptionGroup), (IMP)VdsHook_SGD_checkSubscriptionGroup, "v@:");
                VdsSwizzleInstanceMethod(sgdCls, @selector(prepareToCheckSubscriptionGroup), (IMP)VdsHook_SGD_prepareToCheckSubscriptionGroup, "v@:");
            }

            Class subVCCls = objc_getClass("_TtC10Video_Star15SubscriptionsVC");
            if (subVCCls) {
                VdsSwizzleInstanceMethod(subVCCls, @selector(isShowingSubscriptionErrorPopup), (IMP)VdsHook_SubVC_isShowingSubscriptionErrorPopup, "B@:");
                VdsSwizzleInstanceMethod(subVCCls, @selector(setIsShowingSubscriptionErrorPopup:), (IMP)VdsHook_SubVC_setIsShowingSubscriptionErrorPopup, "v@:B");
                VdsSwizzleInstanceMethod(subVCCls, @selector(isRefreshingSubscription), (IMP)VdsHook_SubVC_isRefreshingSubscription, "B@:");

                Method mVWA = class_getInstanceMethod(subVCCls, @selector(viewWillAppear:));
                if (mVWA) {
                    orig_SubVC_viewWillAppear = (void (*)(id, SEL, BOOL))method_getImplementation(mVWA);
                    method_setImplementation(mVWA, (IMP)VdsHook_SubVC_viewWillAppear);
                } else {
                    class_addMethod(subVCCls, @selector(viewWillAppear:), (IMP)VdsHook_SubVC_viewWillAppear, "v@:B");
                }
            }
            s_hookedSub = YES;
        });
    }
}

#pragma mark - 8. Intro Dashboard Overlay + TikTok @painuzz

static UIWindow *VdsGetAppWindow(void) {
    id app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(delegate)]) {
        id del = [app delegate];
        if ([del respondsToSelector:@selector(window)] && [del window]) {
            return [del window];
        }
    }
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow || w.rootViewController) {
            return w;
        }
    }
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow || w.rootViewController) {
                    return w;
                }
            }
        }
    }
    return nil;
}

static UIViewController *VdsGetTopViewController(void) {
    UIWindow *win = VdsGetAppWindow();
    if (!win) return nil;
    UIViewController *top = win.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    return top;
}

static UIView *VdsIntroStatView(NSString *value, NSString *label) {
    UIView *v = [[UIView alloc] init];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    v.layer.cornerRadius = 14.0;
    v.layer.masksToBounds = YES;

    UILabel *val = [[UILabel alloc] init];
    val.translatesAutoresizingMaskIntoConstraints = NO;
    val.text = value;
    val.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    val.textColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    val.textAlignment = NSTextAlignmentCenter;
    [v addSubview:val];

    UILabel *lab = [[UILabel alloc] init];
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    lab.text = label;
    lab.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
    lab.textColor = [UIColor colorWithWhite:0.45 alpha:1.0];
    lab.textAlignment = NSTextAlignmentCenter;
    [v addSubview:lab];

    [NSLayoutConstraint activateConstraints:@[
        [val.centerXAnchor constraintEqualToAnchor:v.centerXAnchor],
        [val.centerYAnchor constraintEqualToAnchor:v.centerYAnchor constant:-8],
        [lab.centerXAnchor constraintEqualToAnchor:v.centerXAnchor],
        [lab.topAnchor constraintEqualToAnchor:val.bottomAnchor constant:2]
    ]];
    return v;
}

@interface VdsIntroViewController : UIViewController
@property (nonatomic, copy) void (^onFinish)(void);
@end

@implementation VdsIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = self.view.bounds;
    bg.colors = @[
        (id)[UIColor colorWithWhite:0.10 alpha:1.0].CGColor,
        (id)[UIColor colorWithWhite:0.01 alpha:1.0].CGColor
    ];
    bg.startPoint = CGPointMake(0.0, 0.0);
    bg.endPoint = CGPointMake(1.0, 1.0);
    [self.view.layer insertSublayer:bg atIndex:0];

    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.96];
    card.layer.cornerRadius = 24.0;
    card.layer.masksToBounds = YES;
    [self.view addSubview:card];

    UILabel *badge = [[UILabel alloc] init];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.text = @"VIDEO STAR PRO";
    badge.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    badge.textColor = [UIColor colorWithWhite:0.35 alpha:1.0];
    badge.textAlignment = NSTextAlignmentCenter;
    [card addSubview:badge];

    UILabel *title = [[UILabel alloc] init];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    title.text = @"Dashboard Mở Khóa";
    title.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    title.textColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    title.textAlignment = NSTextAlignmentCenter;
    [card addSubview:title];

    UILabel *sub = [[UILabel alloc] init];
    sub.translatesAutoresizingMaskIntoConstraints = NO;
    sub.text = @"All-Access Pass • 90 Packs • QR Preset";
    sub.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    sub.textColor = [UIColor colorWithWhite:0.45 alpha:1.0];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.numberOfLines = 0;
    [card addSubview:sub];

    UIView *stats = [[UIView alloc] init];
    stats.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stats];

    UIView *s1 = VdsIntroStatView(@"90", @"PACKS");
    UIView *s2 = VdsIntroStatView(@"VIP", @"ACTIVE");
    UIView *s3 = VdsIntroStatView(@"QR", @"PRESET");
    [stats addSubview:s1];
    [stats addSubview:s2];
    [stats addSubview:s3];

    UIButton *start = [UIButton buttonWithType:UIButtonTypeSystem];
    start.translatesAutoresizingMaskIntoConstraints = NO;
    [start setTitle:@"Bắt Đầu" forState:UIControlStateNormal];
    [start setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    start.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    start.backgroundColor = [UIColor colorWithWhite:0.06 alpha:1.0];
    start.layer.cornerRadius = 14.0;
    [start addTarget:self action:@selector(vdsFinish) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:start];

    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [card.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.88],

        [badge.topAnchor constraintEqualToAnchor:card.topAnchor constant:28],
        [badge.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [badge.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],

        [title.topAnchor constraintEqualToAnchor:badge.bottomAnchor constant:10],
        [title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],

        [sub.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8],
        [sub.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [sub.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],

        [stats.topAnchor constraintEqualToAnchor:sub.bottomAnchor constant:24],
        [stats.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [stats.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [stats.heightAnchor constraintEqualToConstant:92],

        [s1.topAnchor constraintEqualToAnchor:stats.topAnchor],
        [s1.bottomAnchor constraintEqualToAnchor:stats.bottomAnchor],
        [s1.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [s1.widthAnchor constraintEqualToAnchor:stats.widthAnchor multiplier:0.31],

        [s2.topAnchor constraintEqualToAnchor:stats.topAnchor],
        [s2.bottomAnchor constraintEqualToAnchor:stats.bottomAnchor],
        [s2.leadingAnchor constraintEqualToAnchor:s1.trailingAnchor constant:10],
        [s2.widthAnchor constraintEqualToAnchor:s1.widthAnchor],

        [s3.topAnchor constraintEqualToAnchor:stats.topAnchor],
        [s3.bottomAnchor constraintEqualToAnchor:stats.bottomAnchor],
        [s3.leadingAnchor constraintEqualToAnchor:s2.trailingAnchor constant:10],
        [s3.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor],

        [start.topAnchor constraintEqualToAnchor:stats.bottomAnchor constant:24],
        [start.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [start.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [start.heightAnchor constraintEqualToConstant:52],
        [start.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-24]
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    for (CALayer *l in self.view.layer.sublayers) {
        if ([l isKindOfClass:[CAGradientLayer class]]) {
            l.frame = self.view.bounds;
        }
    }
}

- (void)vdsFinish {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.onFinish) {
            self.onFinish();
        }
    }];
}

@end

static void VdsPresentTikTokAlert(void) {
    UIViewController *topVC = VdsGetTopViewController();
    if (!topVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            VdsPresentTikTokAlert();
        });
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🎉 Video Star VIP Pro"
                                                                   message:@"Chào mừng bạn đến với Video Star Pro!\nTheo dõi TikTok @painuzz để nhận cập nhật hiệu ứng mới, preset QR độc quyền và hỗ trợ kỹ thuật."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *joinAction = [UIAlertAction actionWithTitle:@"Mở TikTok"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:@"https://www.tiktok.com/@painuzz?_r=1&_t=ZS-9BXqaRHzKzt"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Để Sau"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:joinAction];
    [alert addAction:cancelAction];

    [topVC presentViewController:alert animated:YES completion:nil];
    VdsLogOK(@"Đã hiển thị thông báo TikTok @painuzz.");
}

static BOOL s_introShown = NO;

static void VdsShowIntroIfNeeded(void) {
    if (s_introShown) return;

    UIViewController *topVC = VdsGetTopViewController();
    if (!topVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            VdsShowIntroIfNeeded();
        });
        return;
    }

    s_introShown = YES;

    VdsIntroViewController *intro = [[VdsIntroViewController alloc] init];
    intro.modalPresentationStyle = UIModalPresentationOverFullScreen;
    intro.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    intro.onFinish = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            VdsPresentTikTokAlert();
        });
    };

    [topVC presentViewController:intro animated:YES completion:nil];
    VdsLogOK(@"Đã hiển thị intro dashboard.");
}

#pragma mark - Hook UIViewController viewDidAppear để bắt chắc chắn lúc UI lên màn hình

static void (*orig_VC_viewDidAppear)(id self, SEL _cmd, BOOL animated) = NULL;
static void VdsHook_VC_viewDidAppear(UIViewController *self, SEL _cmd, BOOL animated) {
    if (orig_VC_viewDidAppear) {
        orig_VC_viewDidAppear(self, _cmd, animated);
    }
    VdsInstallProUnlockHooks();
    VdsShowIntroIfNeeded();
}

#pragma mark - 9. Constructor & Lifecycle Orchestrator

__attribute__((constructor))
static void VideoStar_UnlockPro_Init(void) {
    VdsInstallCloudKitSafeMock();

    VdsLogOK(@"Khởi động VideoStar_UnlockPro Dylib (PID: %d)", getpid());

    VdsInstallProUnlockHooks();

    Method mVDA = class_getInstanceMethod([UIViewController class], @selector(viewDidAppear:));
    if (mVDA) {
        orig_VC_viewDidAppear = (void (*)(id, SEL, BOOL))method_getImplementation(mVDA);
        method_setImplementation(mVDA, (IMP)VdsHook_VC_viewDidAppear);
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        VdsInstallProUnlockHooks();
        VdsShowIntroIfNeeded();
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        VdsInstallProUnlockHooks();
        VdsShowIntroIfNeeded();
    }];
}
