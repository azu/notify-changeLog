//
//  Created by azu on 12/11/06.
//


#import <Foundation/Foundation.h>

extern NSString *const kChangeLogCurrentVersion;

@interface NotifyChangeLog : NSObject

+ (BOOL)isFirstLaunchInCurrentVersion;

+ (NSString *)changeLogAtCurrent;

+ (void)show; // with save

+ (void)saveLaunchedVersion;


@end