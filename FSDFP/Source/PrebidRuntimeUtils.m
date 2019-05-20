//
//  PrebidRuntimeUtils.m
//  FSDFP
//
//  Created by Dean Chang on 5/20/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

#import "PrebidRuntimeUtils.h"
#import "FSDFPException.h"

typedef NS_ENUM(NSInteger, PBAdUnitType) {
    PBAdUnitTypeBanner,
    PBAdUnitTypeInterstitial,
    PBAdUnitTypeNative
};

@protocol PBAdUnitProtocol <NSObject>

@property (nonatomic, strong) NSString *__nullable configId;
@property (nonatomic, strong) NSString *__nullable identifier;
@property (nonatomic, strong) NSArray<NSValue*> *__nullable adSizes;
@property (nonatomic, assign) PBAdUnitType adType;
@property (nonatomic, assign) NSTimeInterval adRefreshRate;

- (nonnull instancetype)initWithAdUnitIdentifier:(nonnull NSString *)identifier;

@end

@protocol PBBidManagerProtocol

+ (instancetype _Nonnull )sharedInstance;
- (id<PBAdUnitProtocol>)adUnitByIdentifier:(NSString *_Nullable)identifier;
- (nullable NSDictionary<NSString *, NSString *> *)keywordsForWinningBidForAdUnit:(nonnull id<PBAdUnitProtocol>)adUnit;

@end

@implementation PrebidRuntimeUtils

+ (Class)prebidBannerAdUnitClass {
    Class<PBAdUnitProtocol> bannerAdUnitClass = NSClassFromString(@"PBBannerAdUnit");
    if (bannerAdUnitClass == nil) {
        @throw [FSDFPException exceptionWithName:FSPrebidMissingFrameworkException];
    }
    return bannerAdUnitClass;
}

+ (Class)prebidBidManagerClass {
    Class bidManagerClass = NSClassFromString(@"PBBidManager");
    if (bidManagerClass == nil) {
        @throw [FSDFPException exceptionWithName:FSPrebidMissingFrameworkException];
    }
    return bidManagerClass;
}

+ (NSDictionary*)keywordsWithIdentifier:(NSString*)identifier {
    Class<PBBidManagerProtocol> bidManagerClass = [self prebidBidManagerClass];
    __autoreleasing id<PBAdUnitProtocol> adUnit = [[bidManagerClass sharedInstance] adUnitByIdentifier:identifier];
    if (adUnit) {
        NSDictionary *keywords = [[bidManagerClass sharedInstance] keywordsForWinningBidForAdUnit:adUnit];
        if (keywords) {
            return keywords;
        }
    }
    return nil;
}

@end
