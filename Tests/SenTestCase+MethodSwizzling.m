//
//  Created by azu on 12/11/07.
//


#import <objc/runtime.h>
#import "SenTestCase+MethodSwizzling.h"


// Workaround for change in imp_implementationWithBlock() with Xcode 4.5
// https://github.com/AFNetworking/AFNetworking/issues/417
#ifdef __IPHONE_6_0
#define CAST_TO_BLOCK id
#else
#define CAST_TO_BLOCK __bridge void *
#endif

@implementation SenTestCase (MethodSwizzling)

- (void)swizzleMethod:(SEL)aOriginalMethod
        inClass:(Class)aOriginalClass
        withMethod:(SEL)aNewMethod
        fromClass:(Class)aNewClass
        executeBlock:(void (^)(void))aBlock {
    Method originalMethod = class_getClassMethod(aOriginalClass, aOriginalMethod);
    Method mockMethod = class_getClassMethod(aNewClass, aNewMethod);
    method_exchangeImplementations(originalMethod, mockMethod);
    aBlock();
    method_exchangeImplementations(mockMethod, originalMethod);
}

- (void)swizzleMethod:(SEL)aOriginalMethod
        inClass:(Class)aOriginalClass
        withBlock:(block_t)aNewBlock
        executeBlock:(void (^)(void))aBlock {
    Method originalMethod = class_getClassMethod(aOriginalClass, aOriginalMethod);
    IMP imp_original = method_getImplementation(originalMethod);
    // exchange
    IMP imp_newBlock = imp_implementationWithBlock((CAST_TO_BLOCK) aNewBlock);
    method_setImplementation(originalMethod, imp_newBlock);
    aBlock();
    method_setImplementation(originalMethod, imp_original);
}
@end