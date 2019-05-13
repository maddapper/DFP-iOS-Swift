//
//  FSDFPInterstitial.m
//  FSDFP
//
//  Created by Dean Chang on 5/6/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

#import "FSDFPInterstitial.h"

typedef void (^FSAdEventHandler)(NSString *__nonnull methodName, NSDictionary<NSString*, id> *__nonnull params);

@interface FSDFPInterstitial()

@property (nonatomic, strong) FSAdEventHandler fsEventHandler;

@end

@implementation FSDFPInterstitial

- (instancetype)initWithEventHandler:(void(^)(NSString *__nonnull methodName, NSDictionary<NSString*, id> *__nonnull params))eventHandler
                            adUnitId:(NSString* _Nonnull)adUnitId
{
    NSParameterAssert(adUnitId);
    if (self = [self initWithAdUnitID:adUnitId]) {
        self.delegate = self;
        _fsEventHandler = eventHandler;
    }
    return self;
}

///MARK: GADInterstitialDelegate

/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(DFPInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"error" : error, @"interstitial" : ad });
    }
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(DFPInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

/// Tells the delegate that an interstitial failed to be presented.
- (void)interstitialDidFailToPresentScreen:(nonnull GADInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(DFPInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(DFPInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(DFPInterstitial *)ad {
    if (_fsEventHandler) {
        _fsEventHandler(NSStringFromSelector(_cmd), @{ @"interstitial" : ad });
    }
}

@end

