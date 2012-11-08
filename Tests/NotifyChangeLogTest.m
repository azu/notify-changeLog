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

// 1.0を初期値として保存する
- (void)setDefaultVersion {
    [NotifyChangeLog saveCurrentVersion];
}

// initial version is 1.0
- (void)testInitVersion {

    [self setDefaultVersion];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:kChangeLogCurrentVersion];
    assertThat(version, equalTo(@"1.0"));
}
// アプリをインストールしてから初めての起動した時
- (void)testLaunchAtAllTheFirstTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:kChangeLogCurrentVersion];
    // まだ現在のバージョンは保存されてないのでnil
    assertThat(version, nilValue());
    // 一番最初に更新履歴は出したくないので、Noが帰る
    assertThatBool([NotifyChangeLog isFirstLaunchInCurrentVersion], equalToBool(NO));
}
// 1.0 -> 1.1
- (void)testIsUpdateVersion {

    [self setDefaultVersion];

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

    [self setDefaultVersion];

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
            [NotifyChangeLog showAndSave];
            assertThatBool(isShownDialog, equalToBool(YES));
        }];
    }];
}

- (void)testChangeLog {
    [self setDefaultVersion];
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
            assertThat(message_2, equalTo([changeLog objectForKey:@"1.1"]));
            // save
            [NotifyChangeLog saveCurrentVersion];
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

// 初めてインストールしたのが1.1で初回の起動時
- (void)testChangeLogAtAllTheFirstTime{
    NSDictionary *changeLog = @{
    @"1.1":@"change log 1.1\n message"
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
            assertThat(message , nilValue());
        }];
    }];
}
@end