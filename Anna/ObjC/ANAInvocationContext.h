//
//  ANAInvocationContext.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

@interface ANAInvocationContext : NSObject
@property (unsafe_unretained, nonatomic, readonly) Class cls;
@property (unsafe_unretained, nonatomic, readonly) SEL selector;
- (instancetype)initWithClass:(Class)cls
                     selector:(SEL)selector;
@end

#pragma mark - ANAInvocationContext (Analyze)

@interface ANAInvocationContext (Analyze)
@property (readonly, nonatomic) void(^analyze)();
@end

#pragma mark - NSObject (ANAInvocationContext)

@interface NSObject (ANAInvocationContext)
@property (readonly, nonatomic) ANAInvocationContext *(^ana_context)(SEL selector);
@end

#define ana ana_context(_cmd)
