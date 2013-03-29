//
//  Created by azu on 12/11/06.
//


#import "NotifyChangeLog.h"


NSString *const kChangeLogCurrentVersion = @"kChangeLogCurrentVersion";

@implementation NotifyChangeLog {

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
                                    objectForKey:@"CFBundleShortVersionString"];

    return version;
}

+ (BOOL)isFirstLaunchInCurrentVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedVersion = [defaults objectForKey:kChangeLogCurrentVersion];
    // first in all time or already launch(save) current version
    if (savedVersion == nil || [savedVersion compare:[self appVersion]
        options:NSNumericSearch] == NSOrderedSame){
        return NO;
    }
    return YES;
}

// get change log which match current app version
+ (NSString *)changeLogAtCurrent:(BOOL)force {
    if (!force && ![self isFirstLaunchInCurrentVersion]){
        return nil;
    }
    NSDictionary *changeLog = [self loadChangeLog];
    NSString *message = [changeLog objectForKey:[self appVersion]];
    if (message != nil && [message length] > 0){
        return message;
    }
    return nil;
}
+ (NSString *)changeLogAtCurrent {
    return [self changeLogAtCurrent:NO];
}

// showAndSave change log with alertView - with save launch version
+ (void)showAndSave {
    if ([self isFirstLaunchInCurrentVersion]){
        [self showDialog];
    }
    [self saveCurrentVersion];
}

+ (void)showDialog {
    NSString *message = [self changeLogAtCurrent];
    // guard
    if (message == nil || [message length] == 0){
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ChngeLog"
            message:message
            delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alert show];
    });
}

+ (void)saveCurrentVersion {
    NSString *version = [self appVersion];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:version forKey:kChangeLogCurrentVersion];
    [defaults synchronize];
}


@end