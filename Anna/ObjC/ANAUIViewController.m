//
//  ANAUIViewController.m
//  Anna_iOS_Tests
//
//  Created by William on 2018/5/4.
//

#import "ANAUIViewController.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUIViewController

- (void)viewDidAppear:(BOOL)animated {
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL, BOOL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd, animated);
    [self ana_forwardRecordingEventNamed:NSStringFromSelector(_cmd)
                          withProperties:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL, BOOL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd, animated);
    [self ana_forwardRecordingEventNamed:NSStringFromSelector(_cmd)
                          withProperties:nil];
}

@end
