//
//  ANAPrefix.h
//  Anna
//
//  Created by William on 09/05/2017.
//
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(ANAPrefixProtocol)
@protocol ANAPrefix
@property (readonly, nonnull) void(^analyze)();
@end

//@protocol ANAAnalyzable;
//@interface ANAPrefix : NSObject <ANAPrefix>
//- (instancetype)initWithTarget:(id<ANAAnalyzable> __unsafe_unretained)target
//                      selector:(SEL)selector;
//@end
