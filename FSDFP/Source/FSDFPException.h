//
//  FSDFPException.h
//  FSDFP
//
//  Created by Dean Chang on 5/20/19.
//  Copyright © 2019 Freestar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FSRaiseException) {
    FSUndefinedException = 0,
    FSPrebidMissingFrameworkException = 1
};

@interface FSDFPException : NSException

+ (NSException *)exceptionWithName:(FSRaiseException)exceptionName;

@end

NS_ASSUME_NONNULL_END
