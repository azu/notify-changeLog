//
//  Created by azu on 12/11/07.
//


#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

@interface SenTestCase (MethodSwizzling)

typedef id (^block_t)(void);

- (void)swizzleMethod:(SEL)aOriginalMethod inClass:(Class)aOriginalClass withMethod:(SEL)aNewMethod
        fromClass:(Class)aNewClass executeBlock:(void (^)())aBlock;

- (void)swizzleMethod:(SEL)aOriginalMethod inClass:(Class)aOriginalClass withBlock:(block_t)aNewBlock
        executeBlock:(void (^)())aBlock;

@end