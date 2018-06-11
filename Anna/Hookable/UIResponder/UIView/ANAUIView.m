//
//  ANAUIView.m
//  Anna_iOS
//
//  Created by William on 2018/5/4.
//

#import "ANAUIView.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUIView

- (void)didMoveToWindow
{
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd);
    
    [self ana_forwardRecordingEventNamed:NSStringFromSelector(_cmd)
                          withProperties:nil];
}

- (void)didMoveToSuperview
{
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd);
    [self ana_forwardRecordingEventNamed:NSStringFromSelector(_cmd)
                          withProperties:nil];
}

@end
