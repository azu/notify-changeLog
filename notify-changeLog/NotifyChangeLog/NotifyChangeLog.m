//
//  Created by azu on 12/11/06.
//


#import "NotifyChangeLog.h"


NSString *const kChangeLogCurrentVersion = @"kChangeLogCurrentVersion";

@implementation NotifyChangeLog {

}

+ (void)initialize {
    [super initialize];

    // initial version
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
    kChangeLogCurrentVersion : @"1.0"
    }];
}

// load form ChangeLog.plist
+ (NSDictionary *)loadChangeLog {
    NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"ChangeLog" ofType:@"plist"];
    NSDictionary *changeLog = [[NSDictionary alloc] initWithContentsOfFile:path];
    return changeLog;
}

// current app's version
+ (NSString *)appVersion {
    NSString *version = [[[NSBundle bundleForClass:self] infoDictionary]
                                    objectForKey:(NSString *) kCFBundleVersionKey];

    return version;
}

+ (BOOL)isFirstLaunchInCurrentVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedVersion = [defaults objectForKey:kChangeLogCurrentVersion];
    if ([savedVersion compare:[self appVersion]
        options:NSNumericSearch] == NSOrderedSame){
        return NO;
    }
    return YES;
}

// get change log which match current app version
+ (NSString *)changeLogAtCurrent {
    if (![self isFirstLaunchInCurrentVersion]){
        return nil;
    }
    NSDictionary *changeLog = [self loadChangeLog];
    NSString *message = [changeLog objectForKey:[self appVersion]];
    if (message != nil && [message length] > 0){
        return message;
    }
    return nil;
}

// show change log with alertView - with save launch version
+ (void)show {
    if ([self isFirstLaunchInCurrentVersion]){
        [self showDialog];
    }
    [self saveLaunchedVersion];
}

+ (void)showDialog {
    NSString *message = [self changeLogAtCurrent];
    // guard
    if (message == nil || [message length] == 0){
        return; nil;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ChngeLog"
        message:message
        delegate:nil cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [alert show];
}

+ (void)saveLaunchedVersion {
    NSString *version = [self appVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:kChangeLogCurrentVersion];
    [defaults synchronize];
}


@end