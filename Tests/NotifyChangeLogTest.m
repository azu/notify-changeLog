#import <SenTestingKit/SenTestingKit.h>
#import "NotifyChangeLog.h"
#import "SenTestCase+MethodSwizzling.h"


@interface NotifyChangeLogTest : SenTestCase

@end

@implementation NotifyChangeLogTest

- (void)setUp {

}

- (void)tearDown {
    NSString *appDomain = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:appDomain];
    [defaults removeObjectForKey:kChangeLogCurrentVersion];
    [defaults synchronize];
}

// initial version is 1.0
- (void)testInitVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:kChangeLogCurrentVersion];
    assertThat(version, equalTo(@"1.0"));
}

// 1.0 -> 1.1
- (void)testIsUpdateVersion {
    [self swizzleMethod:@selector(appVersion) inClass:[NotifyChangeLog class] withBlock:(block_t) ^{
        return @"1.1";
    } executeBlock:^{
        // isFirstLaunchInCurrentVersion does not side effect.
        assertThatBool([NotifyChangeLog isFirstLaunchInCurrentVersion], equalToBool(YES));
        assertThatBool([NotifyChangeLog isFirstLaunchInCurrentVersion], equalToBool(YES));
    }];
}

// 1.0 -> 1.1
- (void)testShow {
    __block BOOL isShownDialog = NO;
    __weak NotifyChangeLogTest *test = self;
    [test swizzleMethod:@selector(appVersion) inClass:[NotifyChangeLog class] withBlock:(block_t) ^{
        return @"1.1";
    } executeBlock:^{
        [test swizzleMethod:@selector(showDialog) inClass:[NotifyChangeLog class] withBlock:^id {
            isShownDialog = YES;
            return nil;
        } executeBlock:^{
            // call + showDialog
            [NotifyChangeLog show];
            assertThatBool(isShownDialog, equalToBool(YES));
        }];
    }];
}

- (void)testChangeLog {
    NSDictionary *changeLog = @{
    @"1.1":@"change log 1.1\n message",
    @"1.2":@"change log 1.2\n message"
    };
    __weak NotifyChangeLogTest *test = self;
    [test swizzleMethod:@selector(loadChangeLog) inClass:[NotifyChangeLog class] withBlock:^id {
        return changeLog;
    } executeBlock:^{
        // ver 1.1
        [test swizzleMethod:@selector(appVersion) inClass:[NotifyChangeLog class] withBlock:(block_t) ^{
            return @"1.1";
        } executeBlock:^{
            // get 1.1 change log message
            NSString *message = [NotifyChangeLog changeLogAtCurrent];
            assertThat(message, equalTo([changeLog objectForKey:@"1.1"]));
            // changeLogAtCurrent does not side effect
            NSString *message_2 = [NotifyChangeLog changeLogAtCurrent];
            assertThat(message, equalTo([changeLog objectForKey:@"1.1"]));
            // save
            [NotifyChangeLog saveLaunchedVersion];
            NSString *message_nil = [NotifyChangeLog changeLogAtCurrent];
            assertThat(message_nil, nilValue());
        }];
        // ver 1.2
        [test swizzleMethod:@selector(appVersion) inClass:[NotifyChangeLog class] withBlock:(block_t) ^{
            return @"1.2";
        } executeBlock:^{
            // get 1.2 change log message
            NSString *message = [NotifyChangeLog changeLogAtCurrent];
            assertThat(message, equalTo([changeLog objectForKey:@"1.2"]));
        }];
        // not exist version
        [test swizzleMethod:@selector(appVersion) inClass:[NotifyChangeLog class] withBlock:(block_t) ^{
            return @"9.9";
        } executeBlock:^{
            // get nil
            NSString *message = [NotifyChangeLog changeLogAtCurrent];
            assertThat(message, nilValue());
        }];
    }];
}
@end