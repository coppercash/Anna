//
//  ANAUITableView.m
//  Anna_iOS
//
//  Created by William on 2018/6/5.
//

#import "ANAUITableView.h"
#import <Anna/Anna-Swift.h>

@implementation ANAUITableView

- (void)reloadData
{
    [(UITableView *)self ana_reloadData];
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd);
}

- (void)reloadSections:(NSIndexSet *)sections
      withRowAnimation:(UITableViewRowAnimation)animation
{
   [(UITableView *)self ana_reloadSections:sections
                          withRowAnimation:animation];
    __auto_type
    superObj = (struct objc_super) {
        .super_class = class_getSuperclass(object_getClass(self)),
        .receiver = self,
    };
    __auto_type const
    objc_msgSendSuperCasted = (void (*)(struct objc_super *, SEL, NSIndexSet *, UITableViewRowAnimation))objc_msgSendSuper;
    objc_msgSendSuperCasted(&superObj, _cmd, sections, animation);
}

@end
