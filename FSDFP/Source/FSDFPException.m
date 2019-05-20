//
//  FSDFPException.m
//  FSDFP
//
//  Created by Dean Chang on 5/20/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

#import "FSDFPException.h"

@implementation FSDFPException

+ (NSException *)exceptionWithName:(FSRaiseException)exceptionName {
    switch (exceptionName) {
        case FSPrebidMissingFrameworkException:
            return ([super exceptionWithName:@"FSPrebidMissingFrameworkException" reason:@"PrebidFS Framework missing." userInfo:nil]);
            break;
        case FSUndefinedException:
        default:
            return ([super exceptionWithName:@"FSException" reason:@"Undefined." userInfo:nil]);
            break;
    }
}

+ (nonnull NSException *)initWithName:(nonnull NSString *)aName reason:(nullable NSString *)aReason userInfo:(nullable NSDictionary *)aUserInfo
{
    return ([super exceptionWithName:aName reason:aReason userInfo:aUserInfo]);
}

@end
